# Tarefas

## ✅ Concluído — Área "Segundo plano" no Bottom Navigation e remoção do card flutuante

* **Demanda:** No `bottomNavigationBar` da tela inicial, criar uma nova área chamada
  "Segundo plano" para centralizar as execuções de segundo plano (como áudios em
  reprodução e status de serviços). Mover o card de execução para essa nova área e
  remover o card flutuante fixado sobre as telas.
* **Correção aplicada:**
  * `lib/main.dart` → removeu o `builder` com o card fixo `MiniPlayer`, liberando
    as telas da sobreposição do card flutuante na parte inferior.
  * `lib/src/view/background_tasks_view.dart` → nova tela dedicada com:
    * Card de áudio ativo: título, artista, status de reprodução ("Em reprodução" /
      "Pausado"), indicador de faixa na fila, slider de progresso interativo com
      duração e tempo decorrido, controles completos (anterior, -10s, play/pause,
      +10s, próximo e botão de encerrar áudio), além do switch direto para o
      modo contínuo ("Tocar sem parar").
    * Estado vazio quando não houver áudio tocando, com botão de atalho para a
      tela de áudios.
    * Card de serviços em segundo plano: status do serviço de áudio persistente,
      dos lembretes de leitura e do suporte offline.
  * `lib/src/view/home_view.dart` → `NavigationBar` atualizado com a aba
    "Segundo plano" entre "Início" e "Configurações", com badge dinâmico no ícone
    quando houver reprodução ativa e atualização do título da `CustomAppBar`.
  * `lib/src/services/notification_service.dart` → adicionada checagem
    `_isSupportedPlatform` para evitar exceção de inicialização no Windows e Web.

## ✅ Concluído — Palavra do Dia / Devocional do Dia em um único card

* **Demanda:** na tela inicial, o card "Palavra do Dia" ganha um botão que
  alterna para o "Devocional diário"; a lógica de negócio vai para o card e o
  card separado "Devocional do Dia" deixa de existir.
* **Correção aplicada:**
  * `lib/src/view/component/daily_word_card.dart` → agora é autossuficiente:
    cria e descarta `DailyWordController` e `DevotionalOfTheDayController`,
    carrega os dois conteúdos e alterna entre eles pelo botão de troca
    (`Icons.change_circle`), com estado de carregamento/vazio.
  * Compartilhamento (texto, imagem da galeria e captura do card) usa o
    conteúdo ativo (palavra ou devocional), inclusive nos títulos e no nome do
    arquivo gerado.
  * `lib/src/view/home_view.dart` → removeu os controllers de nível de tela, o
    `Consumer` e o card de devocional; a home apenas renderiza
    `const DailyWordCard()`.
  * `lib/src/view/component/devotional_of_the_day_card.dart` → removido (sem
    uso após a unificação).
  * Corrigido também o cabeçalho do card: ao gerar a imagem de compartilhamento
    as ações (troca e compartilhar) ficam ocultas juntas.

## ✅ Concluído — Áudio em segundo plano (Bíblia e Harpa)

* **Objetivo:** todos os áudios do aplicativo (Bíblia e Harpa) devem continuar
  tocando quando o usuário navega entre as telas, minimiza o app ou bloqueia a
  tela, sem perder o contexto do que está sendo ouvido.
* **Problema atual:** cada tela instancia o seu próprio `AudioPlayer` e o
  descarta no `dispose()`. Ao voltar para a Home, trocar de tela ou colocar o
  app em segundo plano, o áudio para. O `audio_service` está no `pubspec.yaml`,
  mas o `audioHandler` em `lib/main.dart` nunca é inicializado e o serviço de
  áudio em `android/app/src/main/AndroidManifest.xml` está comentado.
* **Requisitos:**
  * Criar um **player global único** (serviço com `AudioHandler` do
    `audio_service`) compartilhado por Bíblia, Harpa e "Outros", sobrevivendo à
    navegação e ao ciclo de vida do app.
  * Uma única reprodução ativa por vez: iniciar um áudio deve pausar/parar o
    outro (evitar dois players tocando juntos).
  * Notificação de mídia (Android) com play/pause, próximo/anterior, seek e o
    título do que está tocando; integrar com tela de bloqueio e fones
    (`audio_service` + `audio_session`).
  * Manter o **modo contínuo** já existente (Harpa: hino → próximo hino; Bíblia
    em áudio: capítulo → próximo capítulo) dentro do player global, inclusive
    com a tela apagada ou o app em segundo plano.
  * Manter o suporte a áudio **offline** (arquivos baixados) e online, com os
    mesmos fallbacks/mensagens de erro de hoje.
  * Mini-player / indicador de "tocando agora" dentro do app, para o usuário
    voltar ao áudio em execução a partir de qualquer tela.
  * Encerrar/pausar corretamente ao fim da fila quando o modo contínuo estiver
    desligado e liberar os recursos no `dispose` do serviço.
  * Preservar os ganhos de inicialização (não bloquear o primeiro frame nem
    inicializar o player antes do `runApp`).
* **Locais impactados (levantamento):**
  * `lib/main.dart` → inicializar o `AudioHandler` e registrar o serviço.
  * `android/app/src/main/AndroidManifest.xml` → habilitar/configurar o
    `AudioService` e a permissão de foreground service.
  * `lib/src/view/harp_audio_view.dart` e `lib/src/view/harp_content_view.dart`
    → consumir o player global em vez do `AudioPlayer` local.
  * `lib/src/controllers/audio_book_chapters_controller.dart` e
    `lib/src/controllers/bible_content_controller.dart` → idem para os áudios
    da Bíblia.
  * `lib/src/view/playlist_view.dart` e `lib/src/view/harp_file_view.dart`
    → idem para "Outros" e para o player de hino (hoje sem uso).
  * `lib/src/view/component/bible_audio_player_card.dart` → refletir o estado
    do player global.
* **Critérios de aceite:**
  * Tocar um hino/capítulo e navegar para outra tela ou aba → o áudio continua.
  * Minimizar o app ou bloquear a tela → o áudio continua e aparece a
    notificação de mídia.
  * Controles da notificação e dos fones funcionam (play/pause, anterior/próximo).
  * O modo contínuo continua avançando hinos/capítulos em segundo plano.
  * Nenhum áudio duplicado ou dois players tocando ao mesmo tempo.
* **Riscos/observações:** no iOS é necessário configurar
  `UIBackgroundModes: audio` no `Info.plist`; validar o impacto no tempo de
  inicialização (vitals da Play Store) e no consumo de bateria; testar em
  Android 13+ (permissão `POST_NOTIFICATIONS`, já declarada no manifest).
* **Correção aplicada:**
  * `lib/src/services/app_audio_handler.dart` → player global único
    (`AppAudioHandler` + `AppAudioTrack`) com fila, índice, modo contínuo,
    avanço automático, anterior/próximo, seek, metadados da notificação,
    tratamento de interrupções/fone desconectado, fallback offline
    (`localPath` antes da URL) e `dispose()` liberando as assinaturas e o
    `AudioPlayer`.
  * `lib/main.dart` → `ensureAudioHandler()` inicializado **depois** do
    `runApp` (sem bloquear o primeiro frame), modo contínuo ligado à
    preferência do usuário e mini-player registrado no `MaterialApp.builder`.
  * `android/app/src/main/AndroidManifest.xml` → `WAKE_LOCK` adicionada
    (serviço e `FOREGROUND_SERVICE_MEDIA_PLAYBACK` já existiam).
  * `android/app/src/main/kotlin/.../MainActivity.kt` → passa a estender
    `AudioServiceActivity`, compartilhando o engine com o serviço de mídia.
  * `ios/Runner/Info.plist` → `UIBackgroundModes: audio`.
  * `lib/src/view/component/mini_player.dart` → cartão persistente com
    "tocando agora", play/pause, parar e folha com slider, anterior/próximo,
    avançar/voltar 10s e stop.
  * `lib/src/view/harp_audio_view.dart`, `harp_content_view.dart`,
    `harp_file_view.dart`, `playlist_view.dart`,
    `lib/src/controllers/audio_book_chapters_controller.dart` e
    `bible_content_controller.dart` → deixam de criar/descartar players
    locais, entregam a fila ao handler, sincronizam o item atual com o
    avanço da notificação/fones e cancelam as assinaturas no `dispose`.
  * `lib/src/view/harp_content_view.dart` → acompanha o avanço automático
    trocando o texto do hino sem reiniciar o áudio e só inicia a fila quando
    o usuário toca em play (não interrompe a Harpa/Outros ao abrir o texto).
  * `lib/src/controllers/bible_content_controller.dart` → áudio do capítulo
    da Bíblia em texto também publica título/artista no player global, carrega
    a faixa sob demanda (para não interromper a Harpa/Outros só por abrir um
    capítulo) e o cartão do player usa `play`/`stop` do serviço.
  * `androidStopForegroundOnPause: false` no `AudioServiceConfig` → mantém o
    serviço em primeiro plano na pausa, evitando
    `ForegroundServiceStartNotAllowedException` (Android 12+) ao retomar pela
    notificação/fone.

## ✅ Concluído — Modo contínuo de áudio ("passar os hinos da Harpa sem parar")

* **Demanda (suporte):** "Tinha que ter um modo para o aplicativo passar os
  hinos da harpa sem parar".
* **Diagnóstico:** o player da aba *Áudios > Harpa* já auto-avançava, mas parava
  no último hino, não tinha controle visível de "sem parar" e a tela do hino
  (`HarpContentView`) encerrava a reprodução ao final, sem seguir para o
  próximo. O player de texto da Bíblia e o da aba "Outros" não foram alterados.
* **Correção aplicada:**
  * `lib/src/controllers/settings_controller.dart` → preferência persistida
    `continuousPlayback` (modo "sem parar", ativada por padrão).
  * `lib/src/view/settings_view.dart` → cartão "Reprodução contínua" com switch.
  * `lib/src/view/harp_audio_view.dart` → repetição ao chegar no fim da lista,
    botões de hino anterior/próximo, ícone de repetição e correção do índice
    atual quando a busca filtra a lista.
  * `lib/src/view/harp_content_view.dart` → ao terminar o áudio, avança
    automaticamente para o próximo hino que possui áudio (com `autoPlay`),
    recomeçando a lista no fim e mantendo a reprodução ao navegar entre hinos.
  * `lib/src/view/harp_audio_wrapper.dart` → `AutomaticKeepAliveClientMixin`
    para a aba de áudio não ser descartada ao trocar de aba.
  * `test/settings_controller_test.dart` → testes da preferência.
* **Limitação conhecida:** cada tela cria o seu próprio `AudioPlayer`, então ao
  sair da rota (ex.: voltar para a Home) ou colocar o app em segundo plano o
  áudio para. Para tocar em segundo plano seria necessário um player global +
  `audio_service` — tratado na demanda **"Áudio em segundo plano (Bíblia e
  Harpa)"** acima.

## ✅ Concluído — Alerta de performance da Play Store (inicialização lenta)

* **Problema:** taxa de "inicialização com estado salvo lenta" alta em dispositivos
  de entrada — GPU **ARM Mali G52** (24,20%) e CPU **ARM Cortex-A55** (28,20%).
* **Causa raiz:** o `main()` aguardava (`await`) em série I/O pesado (abrir o banco
  SQLite, `path_provider`, `SharedPreferences`, `.env`/dotenv, orientação) **antes**
  do `runApp()`, e o `StartupGate` agendava notificações no primeiro frame.
  Assim, o primeiro quadro só era desenhado depois de toda essa cadeia terminar —
  o que, em aparelhos fracos, ultrapassa o limite do vitals.
* **Correção aplicada:**
  * `lib/main.dart` → `main()` agora é **não-bloqueante**: o `runApp()` roda
    imediatamente e um `_warmUp()` dispara em paralelo (`unawaited`) o banco,
    as preferências, o `.env` e a orientação, com tolerância a falhas.
  * `lib/src/view/component/started_access_on.dart` → o agendamento de
    notificação do `StartupGate` passa a ser `unawaited` (sem bloquear o frame).
  * `lib/src/view/settings_view.dart` → os valores do `.env` deixam de ser
    `static final` (avaliados uma única vez) e passam a ser lidos a cada
    construção, refletindo o carregamento em paralelo.

## Tarefas anteriores

* ~~Verifique o alerta de performance dada pela Playstore abaixo:~~

A taxa de inicialização com estado salvo lenta de 7 dias está alta em dispositivos com GPU: ARM Mali G52

Nos últimos 7 dias, os dispositivos com GPU: ARM Mali G52 tiveram uma taxa de inicialização com estado salvo lenta de 24,20%. Esse valor é significativamente mais alto do que sua taxa geral de inicialização com estado salvo lenta (11,34%). Esses dispositivos representam 25% das instalações totais. Reduza as inicializações com estado salvo lentas nesses aparelhos para melhorar a taxa geral.
A taxa de inicialização com estado salvo lenta de 7 dias está alta em dispositivos com CPU: ARM Cortex-A55

Nos últimos 7 dias, os dispositivos com CPU: ARM Cortex-A55 tiveram uma taxa de inicialização com estado salvo lenta de 28,20%. Esse valor é significativamente mais alto do que sua taxa geral de inicialização com estado salvo lenta (11,34%). Esses dispositivos representam 5% das instalações totais. Reduza as inicializações com estado salvo lentas nesses aparelhos para melhorar a taxa geral.
``

Faça os ajustes para atender as necessidades da playstore.
`` 