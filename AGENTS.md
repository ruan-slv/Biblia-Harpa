# Tarefas

## [CONCLUÍDA] Corrigir erro de build release

**Erro original:**
```
FAILURE: Build failed with an exception.
* What went wrong:
  Execution failed for task ':app:packageRelease'.
> SigningConfig "release" is missing required property "storeFile".
```

**Causa:** O arquivo `key.properties` não existia no projeto, mas o `build.gradle`
tentava configurar o signing obrigatoriamente para o build release.

**Correção:** Tornar o signing condicional - só aplicar se `key.properties` existir:

```gradle
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
```

**Resultado:** Build concluído com sucesso em ~98s. APK gerado em:
`build/app/outputs/flutter-apk/app-release.apk` (32.7MB)

**Nota:** A warning sobre Kotlin Gradle Plugin (KGP) permanece, mas é apenas um aviso
sobre futuras versões do Flutter. Não afeta o build atual.