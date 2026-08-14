# Bíblia e Harpa

Aplicativo Flutter para leitura da Bíblia, consulta à Harpa Cristã, devocionais
e conteúdos em áudio. O projeto prioriza uma experiência simples, acessível e
útil mesmo sem conexão: os textos principais são distribuídos como assets do
aplicativo e os conteúdos escolhidos pelo usuário podem ser mantidos no
dispositivo.

## Recursos

- Leitura de versões bíblicas incluídas no aplicativo, com busca por livro e
  capítulo.
- Harpa Cristã com pesquisa, favoritos e letras dos hinos.
- Devocionais, palavra do dia e acompanhamento do progresso de leitura.
- Quiz bíblico com perguntas armazenadas localmente.
- Áudios bíblicos e hinos, com reprodução, download opcional, exclusão e
  compartilhamento.
- Playlist local para músicas selecionadas pelo usuário.
- Ajustes de tema e tamanho de fonte, além do recurso de continuar lendo.

## Privacidade e sustentabilidade

Este projeto assume os seguintes compromissos:

- Não contém telemetria, rastreamento comportamental, SDKs de analytics ou
  coleta de perfil de uso.
- Não exibe anúncios e não oferece planos, recursos ou produtos pagos.
- Não exige conta de usuário para a leitura e o uso dos recursos locais.
- Seu sustento é feito exclusivamente por doações voluntárias. A contribuição
  é opcional e não libera nem restringe funcionalidades do aplicativo.

As preferências de leitura, tema, favoritos, histórico, progresso e playlist
são armazenados localmente com `SharedPreferences` e Hive. Conexões podem ser
necessárias para baixar ou reproduzir áudios, verificar atualizações, abrir
links externos de suporte ou compartilhar conteúdos; essas ações não têm a
finalidade de criar perfis de usuários.

## Tecnologias

- [Flutter](https://flutter.dev/) e Dart (SDK `^3.5.4`)
- `provider` para gerenciamento de estado
- Hive e `SharedPreferences` para armazenamento local
- `just_audio` e `audio_service` para reprodução de áudio
- `dio` e `http` para downloads e acesso a conteúdos remotos

O projeto possui estrutura para Android, iOS, Linux, macOS, Windows e Web.

## Estrutura do projeto

```text
lib/
├── main.dart              # Inicialização do aplicativo e provedores
└── src/
    ├── model/             # Modelos de domínio e persistência
    ├── services/          # Serviços legados de acesso a dados
    ├── view/              # Telas e componentes da interface atual
    ├── view_model/        # Estado e regras de apresentação
    ├── screens/           # Telas legadas mantidas no projeto
    ├── controllers/       # Controladores de preferências e leitura
    └── theme/             # Temas e persistência de aparência
assets/
├── images/                # Imagens e ícones
└── json/                  # Textos bíblicos, hinos, devocionais e quiz
```

## Como executar

### Pré-requisitos

- Flutter compatível com Dart `^3.5.4`.
- Ambiente configurado para a plataforma desejada. Consulte
  [`flutter doctor`](https://docs.flutter.dev/reference/flutter-cli#flutter-doctor)
  para verificar os requisitos locais.

### Configuração

1. Clone o repositório e entre na pasta do projeto.
2. Crie o arquivo de configuração local a partir do exemplo:

   ```bash
   cp .env.example .env
   ```

3. Preencha, se necessário, as variáveis de suporte no `.env`:

   ```dotenv
   PIX_KEY=
   APOIASE_URL=
   SUPPORT_EMAIL=
   PLAYSTORE_URL=
   ```

   O `.env` é ignorado pelo Git e também é declarado como asset no
   `pubspec.yaml`; ele deve existir antes de executar ou gerar o aplicativo.

4. Instale as dependências e execute:

   ```bash
   flutter pub get
   flutter run
   ```

## Qualidade e builds

Execute as verificações locais antes de enviar alterações:

```bash
flutter analyze
flutter test
```

Exemplos de builds de distribuição:

```bash
flutter build apk --release
flutter build appbundle
flutter build linux
flutter build windows
flutter build web
```

O script [`flutter_runner.sh`](flutter_runner.sh) reúne opções interativas de
limpeza e build para as plataformas suportadas.

## Contribuições

Contribuições são bem-vindas. Ao abrir uma alteração, mantenha os dados de
usuário no dispositivo, não introduza telemetria, publicidade ou cobrança por
recursos e documente APIs públicas com Dartdoc.

## Licença

Ainda não há uma licença declarada para o projeto. Antes de reutilizar ou
distribuir o código, entre em contato com os responsáveis pelo repositório.
