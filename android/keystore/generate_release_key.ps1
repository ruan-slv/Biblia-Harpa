# ============================================================
# Gera a assinatura de release do aplicativo (Biblia e Harpa)
#
# Produz, em android/keystore:
#   - release.keystore  (arquivo de assinatura, formato PKCS12)
#   - release.jks       (mesma chave, formato JKS legado)
#   - release_cert.pem  (certificado publico)
#   - release_key.pem   (chave privada - NUNCA compartilhar)
# E atualiza android/key.properties automaticamente.
#
# Uso:  .\generate_release_key.ps1
#
# A senha e o caminho do arquivo temporario sao mantidos fora da
# linha de comando (keytool/openssl leem via ":file"), para que
# nao haja ambiguidade de parsing entre cmd e PowerShell.
# ============================================================
$ErrorActionPreference = 'Stop'

$Dir      = $PSScriptRoot
$Keystore = Join-Path $Dir 'release.keystore'
$Jks      = Join-Path $Dir 'release.jks'
$Cert     = Join-Path $Dir 'release_cert.pem'
$Key      = Join-Path $Dir 'release_key.pem'
$PassFile = Join-Path $Dir '.passfile'
$Props    = Join-Path $Dir '..\key.properties'
$Alias    = 'release'
$Dn       = 'CN=Ruan Gustavo Soares, OU=Desenvolvimento, O=Ruan Gustavo Soares, L=Sao Paulo, ST=SP, C=BR'

$Keytool = 'C:\Program Files\Java\jdk-21.0.12.1\bin\keytool.exe'
$OpenSsl = 'C:\Program Files\Git\usr\bin\openssl.exe'

if (-not (Test-Path $Keytool)) { throw "keytool não encontrado em $Keytool" }
if (-not (Test-Path $OpenSsl)) { throw "openssl não encontrado em $OpenSsl" }
if (Test-Path $Keystore) { throw "$Keystore já existe. Apague-o para gerar uma chave nova." }

# [1/5] Senha aleatória de 24 caracteres (sem ambiguidade: sem I, l, O, 0, 1)
$chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789'
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$pass = -join (1..24 | ForEach-Object {
    $bytes = New-Object byte[] 4
    $rng.GetBytes($bytes)
    $chars[([BitConverter]::ToInt32($bytes, 0) -band 0x7FFFFFFF) % $chars.Length]
})
# Grava a senha em arquivo temporário (sem quebra de linha) para keytool/openssl
$pass | Out-File -FilePath $PassFile -Encoding ascii -NoNewline

try {
    # [2/5] Par de chaves RSA 4096, validade 10000 dias (~27 anos)
    Write-Host "[2/5] Gerando par de chaves RSA 4096 (validade 10000 dias ~ 27 anos)..."
    & $Keytool -genkeypair -v -alias $Alias -keyalg RSA -keysize 4096 -validity 10000 `
        -keystore $Keystore -storetype PKCS12 `
        -storepass:file $PassFile -keypass:file $PassFile -dname $Dn
    if ($LASTEXITCODE -ne 0) { throw "keytool -genkeypair falhou (exit $LASTEXITCODE)" }

    # [3/5] Conversão para JKS legado (senha na linha de comando é segura:
    # sem caracteres especiais, e o JKS é só uma cópia do par de chaves)
    Write-Host "[3/5] Convertendo para JKS legado..."
    & $Keytool -importkeystore -srckeystore $Keystore -srcstoretype PKCS12 -srcstorepass $pass `
        -destkeystore $Jks -deststoretype JKS -deststorepass $pass -destkeypass $pass
    if ($LASTEXITCODE -ne 0) { throw "keytool -importkeystore falhou (exit $LASTEXITCODE)" }

    # [4/5] Certificado público (PEM) e chave privada (PEM)
    Write-Host "[4/5] Extraindo certificado público e chave privada em PEM..."
    & $Keytool -exportcert -alias $Alias -keystore $Keystore -storetype PKCS12 `
        -storepass:file $PassFile -rfc -file $Cert
    if ($LASTEXITCODE -ne 0) { throw "keytool -exportcert falhou (exit $LASTEXITCODE)" }

    & $OpenSsl pkcs12 -in $Keystore -nocerts -nodes -passin file:$PassFile -out $Key
    if ($LASTEXITCODE -ne 0) { throw "openssl pkcs12 -in falhou (exit $LASTEXITCODE)" }

    # [5/5] Atualiza android/key.properties
    Write-Host "[5/5] Atualizando key.properties..."
    @"
storeFile=../keystore/release.keystore
storePassword=$pass
keyAlias=$Alias
keyPassword=$pass
"@ | Out-File -FilePath $Props -Encoding ascii

    # Verificação final: lista o certificado para confirmar a integridade
    $certInfo = & $Keytool -list -v -keystore $Keystore -storetype PKCS12 -storepass $pass
    if ($LASTEXITCODE -ne 0) { throw "keytool -list (verificação) falhou (exit $LASTEXITCODE)" }

    Write-Host ""
    Write-Host "============================================================"
    Write-Host " ASSINATURA DE RELEASE GERADA COM SUCESSO"
    Write-Host " Arquivo : $Keystore"
    Write-Host " Alias   : $Alias"
    Write-Host " Senha   : $pass"
    Write-Host " DN      : $Dn"
    Write-Host " (senha também gravada em android\key.properties)"
    Write-Host "============================================================"
    Write-Host ""
    Write-Host "Resumo do certificado:"
    Write-Host ($certInfo -join "`n")
}
finally {
    Remove-Item $PassFile -ErrorAction SilentlyContinue
}
