# Assinatura de Release — Bíblia e Harpa

> **⚠️ SEGURANÇA** — Os arquivos `.keystore`, `.jks`, `release_key.pem` e o
> `key.properties` contêm a **chave privada** do app. **NUNCA** faça commit deles
> no repositório (já estão no `.gitignore` do `android/`) e **NUNCA** os compartilhe
> publicamente. Sem essa chave, o app não pode ser atualizado na Play Store.
>
> Faça backup desses arquivos em pelo menos 2 locais seguros (nuvem pessoal +
> pen drive). Se a chave for perdida, será necessário reinstalar o app do zero
> (novos usuários, perdem reviews e dados).

## 1. Arquivos gerados

Local: `android/keystore/`

| Arquivo | Descrição | Compartilhar? |
|---|---|---|
| `release.keystore` | Keystore principal (formato **PKCS12**, padrão atual do Android) | ❌ Nunca |
| `release.jks` | Mesma chave no formato **JKS** legado (compatibilidade antiga) | ❌ Nunca |
| `release_cert.pem` | **Certificado público** (sem segredo) — útil para registrar no Play Console | ✅ Pode |
| `release_key.pem` | **Chave privada** em PEM — backup extra da chave | ❌ Nunca |
| `generate_release_key.bat` / `.ps1` | Scripts que geraram a assinatura (re-executáveis se necessário) | ✅ Pode |

Além disso, o arquivo `android/key.properties` foi atualizado com os dados de
assinatura (usado pelo `build.gradle` para assinar os builds de release).

## 2. Dados da assinatura (documentar/guardar)

| Campo | Valor |
|---|---|
| **Arquivo do keystore** | `android/keystore/release.keystore` |
| **Formato** | PKCS12 (e cópia JKS em `release.jks`) |
| **Alias da chave** | `release` |
| **Senha do keystore (storePassword)** | `9VPkimztXaCKWfMELYmtdTAh` |
| **Senha da chave (keyPassword)** | `9VPkimztXaCKWfMELYmtdTAh` |
| **Tipo de chave** | RSA 4096 bits |
| **Algoritmo de assinatura** | SHA384withRSA |
| **Distinguished Name (DN)** | `CN=Ruan Gustavo Soares, OU=Desenvolvimento, O=Ruan Gustavo Soares, L=Sao Paulo, ST=SP, C=BR` |
| **Nº de série** | `c326ace411bdb3a1` |
| **Válido de** | 07/10/2026 |
| **Válido até** | 22/02/2054 (~27 anos) |
| **Impressão digital SHA1** | `BD:53:9C:25:91:ED:1E:BE:D5:68:E5:EE:6B:B6:82:AD:37:FD:69:A3` |
| **Impressão digital SHA256** | `60:A2:A6:1D:CF:D4:FD:19:C6:C8:70:59:A2:EE:FE:B7:D6:36:6F:69:B7:32:9B:5D:9E:57:91:76:52:43:CF:7F` |

> As senhas de keystore e de chave são **idênticas** por convenção.
> A senha é aleatória de 24 caracteres (sem caracteres ambíguos: I, l, O, 0, 1).

## 3. Configuração no `android/key.properties`

```properties
storeFile=../keystore/release.keystore
storePassword=9VPkimztXaCKWfMELYmtdTAh
keyAlias=release
keyPassword=9VPkimztXaCKWfMELYmtdTAh
```

> O `key.properties` já está no `.gitignore` do `android/` — não vai para o
> repositório. Para builds CI (GitHub Actions, etc.), defina essas variáveis
> como *secrets* no lugar do arquivo.

## 4. Como assinar o APK/AAB

O `build.gradle` do app já lê o `key.properties`. Para gerar o bundle de release:

```
flutter build appbundle --release
flutter build apk --release
```

O `android/app/build.gradle` **já** lê o `key.properties` e aplica a assinatura
no build de release (nenhuma mudança necessária). Detalhe importante: o
campo `storeFile` é relativo a `android/app/` (onde o `build.gradle` mora),
por isso usa `../keystore/release.keystore`.

```gradle
// (já presente no projeto — mostrado para referência)
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            if (keystoreProperties.size() > 0) {
                storeFile file(keystoreProperties['storeFile'])
                storePassword keystoreProperties['storePassword']
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
            }
        }
    }
    buildTypes {
        release {
            if (keystoreProperties.size() > 0) {
                signingConfig = signingConfigs.release
            }
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

## 5. Registrar no Google Play Console

1. Vá em **Play Console → Configurações do app → Chaves de app** (ou
   *App integrity → App signing*).
2. Ao publicar a primeira versão, o Google oferece o **App Signing** (o Google
   guarda uma chave de assinatura e você mantém a *upload key*).
3. Cole a **impressão digital SHA256** (e/ou SHA1) acima onde o console pedir
   para confirmar a chave de upload.
4. Guarde o `release_cert.pem` — é o certificado público que o Play Console
   usa para validar que o AAB enviado corresponde à chave registrada.

## 6. Regenerar (apenas se necessário)

> **Só execute isso se você quiser uma chave NOVA** — a chave atual será
> descartada e o app precisará ser re-publicado do zero.

```
android\keystore\generate_release_key.bat
```

O script gera uma nova senha aleatória, recria todos os arquivos e atualiza o
`key.properties` automaticamente.
