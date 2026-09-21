# Bíblia e Harpa Cristã

Aplicativo multiplataforma desenvolvido com Flutter que reúne ferramentas essenciais para a vida cristã. Projetado para funcionar principalmente offline, garantindo acesso contínuo aos conteúdos mais importantes mesmo sem conexão com a internet.

## Recursos Principais

### Leitura Bíblica
- Diversas versões da Bíblia disponíveis em múltiplos idiomas (Português, Inglês, Espanhol, Alemão, Francês, Russo, Chinês, entre outros)
- Navegação intuitiva por livros e capítulos
- Busca de textos bíblicos
- Ajuste de tamanho de fonte para maior conforto na leitura
- Sistema de "continuar lendo" para retomar onde você parou
- Compartilhamento de versículos

### Harpa Cristã
- Mais de 640 hinos da Harpa Cristã
- Pesquisa por título ou letra dos hinos
- Sistema de favoritos para acessar hinos preferidos rapidamente
- Reprodução de áudios dos hinos

### Devocionais e Palavra do Dia
- Devocionais diários para reflexão
- Palavra do dia com versículos inspiradores
- Acompanhamento do progresso de leitura

### Quiz Bíblico
- Perguntas sobre a Bíblia para testar seus conhecimentos
- Conteúdo armazenado localmente para uso offline

### Áudios e Músicas
- Reprodução de áudios bíblicos e hinos
- Download opcional de conteúdos para uso offline
- Criação de playlists pessoais
- Compartilhamento de músicas
- Player com suporte a notificações

### Personalização
- Temas claro e escuro
- Ajuste de tamanho de fonte
- Preferências de leitura salvas localmente

## Privacidade e Sustentabilidade

O aplicativo respeita sua privacidade:

- **Sem telemetria ou rastreamento de uso** — não coleta dados, não envia analytics e não cria perfis de usuário.
- **Sem anúncios** — nenhuma publicidade ou banners.
- **Sem necessidade de conta de usuário** — todos os recursos locais funcionam sem cadastro.
- **Dados armazenados apenas no seu dispositivo** — preferências de leitura, favoritos, histórico, progresso e playlist ficam salvos localmente no aparelho.
- **Sustentado exclusivamente por doações voluntárias** — a contribuição é opcional e não libera nem restringe funcionalidades.

Conexões à internet podem ser necessárias para baixar ou reproduzir áudios, verificar atualizações, abrir links externos de suporte ou compartilhar conteúdos, mas essas ações não têm a finalidade de coletar dados ou criar perfis de usuários.

## Plataformas Suportadas

O aplicativo está disponível para:
- Android
- iOS
- Windows
- Linux
- macOS
- Web

## Tecnologias Utilizadas

- [Flutter](https://flutter.dev/) e Dart (SDK `^3.5.4`)
- `provider` para gerenciamento de estado
- `sqflite` e `SharedPreferences` para armazenamento local
- `just_audio` e `audio_service` para reprodução de áudio
- `dio` e `http` para downloads e acesso a conteúdos remotos

## Estrutura do Projeto

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

## Como Executar

### Pré-requisitos

- Flutter compatível com Dart `^3.5.4`.
- Ambiente configurado para a plataforma desejada. Consulte [`flutter doctor`](https://docs.flutter.dev/reference/flutter-cli#flutter-doctor) para verificar os requisitos locais.

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

   O `.env` é ignorado pelo Git e também é declarado como asset no `pubspec.yaml`; ele deve existir antes de executar ou gerar o aplicativo.

4. Instale as dependências e execute:

   ```bash
   flutter pub get
   flutter run
   ```

## Qualidade e Builds

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

O script [`flutter_runner.sh`](flutter_runner.sh) reúne opções interativas de limpeza e build para as plataformas suportadas.

## Contribuições

Contribuições são bem-vindas! Ao contribuir, mantenha os princípios do projeto:

- Dados do usuário permanecem no dispositivo
- Sem telemetria, publicidade ou cobrança por recursos
- Documente APIs públicas com Dartdoc

## Licença

Para informações sobre a licença, entre em contato com os responsáveis pelo repositório.

---

Feito com fé e código.