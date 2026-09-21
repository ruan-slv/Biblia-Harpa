# Adicionar arquivos JSON aos Assets no pubspec.yaml

O objetivo é atualizar o arquivo `pubspec.yaml` para incluir corretamente todos os arquivos `.json` localizados na pasta `assets`. Atualmente, o projeto possui subpastas organizadas dentro de `assets/json/` que não estão totalmente cobertas ou estão com caminhos incorretos.

## Mudanças Propostas

### Flutter Configuration

#### [MODIFY] [pubspec.yaml](file:///C:/Users/ruang/OneDrive/Documentos/Projetos/Biblia-Harpa/pubspec.yaml)

Vou atualizar a seção `assets` do `pubspec.yaml` para:
1. Remover entradas individuais de arquivos `.json` que estão com caminhos incompletos ou redundantes.
2. Adicionar as pastas `assets/json/bible/` e `assets/json/outros/` para garantir que todos os arquivos JSON nessas pastas sejam incluídos no build do Flutter.

## Plano de Verificação

### Verificação Manual
- Após a alteração, o desenvolvedor deve executar `flutter pub get` para validar a sintaxe do arquivo.
- Verificar se os arquivos JSON podem ser carregados via `rootBundle` no código Dart.
