# Tarefas

## ✅ Concluído — Versão da Bíblia acompanha o idioma escolhido

* **Demanda:** ao escolher o idioma (ex.: russo), o aplicativo deve selecionar
  automaticamente a versão da Bíblia daquele idioma. No Brasil, onde há três
  versões, a padrão deve ser a NVI.
* **Correção aplicada:**
  * `lib/src/utils/bible_version_defaults.dart` → mapeamento centralizado
    idioma → arquivo da Bíblia:
    * `pt` → `nvi.json` (NVI), `en` → `en_kjv.json`, `es` → `es_rvr.json`,
      `de` → `de_schlachter.json`, `fr` → `fr_apee.json`,
      `ru` → `ru_synodal.json`, `zh` → `zh_cuv.json`, `ko` → `ko_ko.json`,
      `vi` → `vi_vietnamese.json`, `el` → `el_greek.json`,
      `ro` → `ro_cornilescu.json`, `eo` → `eo_esperanto.json`,
      `ar` → `ar_svd.json`, `fi` → `fi_finnish.json`.
    * Conversão entre chave do seletor e arquivo (`NVI` ↔ `nvi.json`), chave de
      preferência e fallback para o padrão do português.
  * `settings_controller.dart` → ao trocar o idioma, também persiste a versão
    da Bíblia correspondente em `selectedVersion`.
  * `bible_version_controller.dart` → passa a usar o mapeamento central e tem a
    NVI como fallback (antes era ACF).
  * `bible_list_controller.dart` → usa o mapeamento (remove switches
    duplicados), expõe `setVersionForLanguage()` e escuta o
    `SettingsController` para recarregar a Bíblia quando o idioma muda com o
    app aberto.
  * `bible_providers_controller.dart` → injeta o `SettingsController` no
    `BibleListController`.
  * `database_export_controller.dart` → usa a mesma chave/constantes e o mesmo
    fallback NVI na exportação.
* **Comportamento:** a escolha manual de versão continua sendo respeitada
  enquanto o idioma não mudar; ao trocar o idioma, a versão padrão daquele
  idioma é aplicada novamente.
* **Testes:**
  * `test/bible_version_defaults_test.dart` → todos os idiomas apontam para
    arquivos existentes, português usa NVI, russo usa Synodal e conversões
    chave/arquivo.
  * `test/settings_controller_test.dart` → escolher russo/português/trocar de
    idioma atualiza `selectedVersion`.
  * `test/widget_test.dart` → escolher russo no popup persiste a Bíblia russa.
  * `flutter analyze` e `flutter test` sem erros.

## ✅ Concluído — Seleção de idioma no primeiro acesso e interface traduzida

* **Demanda:** ao abrir o aplicativo pela primeira vez, exibir um popup para o
  usuário escolher o idioma, reutilizando as bandeiras da lista de versões da
  Bíblia. A escolha deve ser salva e restaurar o idioma nas próximas aberturas,
  traduzindo toda a interface (ex.: Português do Brasil e Russo).
* **Correção aplicada:**
  * `lib/src/l10n/` → nova camada de internacionalização sem codegen:
    * `app_localizations.dart` com 14 idiomas (`pt`, `en`, `es`, `de`, `fr`,
      `ru`, `zh`, `ko`, `vi`, `el`, `ro`, `eo`, `ar`, `fi`), bandeiras, nomes
      nativos, locale, delegate e o atalho `context.l10n` / `tr(...)`.
    * Chaves de tradução são os próprios textos em português, com fallback:
      idioma escolhido → dicionário comum do idioma → inglês → dicionário
      comum em inglês → texto original em português. O português retorna a
      própria chave (sem cair no inglês).
    * Dicionários completos em `translations_en/es/ru.dart`, dicionários
      essenciais nos demais arquivos e `translations_common.dart` para chaves
      pontuais (áudio, devocionais, cores, notificações, exportação etc.).
  * `settings_controller.dart` → preferência persistida `app_language`, com
    normalização de códigos (`pt-BR` → `pt`), `initialized`,
    `hasSelectedLanguage`, `language`, `locale` e `setLanguage()`.
  * `language_selection_dialog.dart` → popup com bandeiras, nomes nativos e
    marcação do idioma atual; modo de primeiro acesso não dispensável.
  * `language_gate.dart` → aguarda o carregamento das preferências e exibe o
    popup apenas quando ainda não há idioma salvo, reagendando caso seja
    fechado sem escolha.
  * `main.dart` → `locale`, `supportedLocales`, delegates do
    `flutter_localizations`, título gerado por idioma, mensagens do Upgrader e
    `LanguageGate` envolvendo o app.
  * `settings_view.dart` → novo cartão de idioma com "Alterar idioma".
  * Telas, controladores e serviços (Bíblia, Harpa, áudios, notas, quiz,
    devocionais, compartilhamento, segundo plano etc.) passaram a usar
    `context.l10n.t(...)`/`tr(...)`.
* **Testes:**
  * `test/settings_controller_test.dart` → idioma padrão, persistência,
    normalização e fallback de código desconhecido.
  * `test/widget_test.dart` → popup no primeiro acesso, escolha persistida e
    ausência do popup quando o idioma já foi escolhido.
  * `flutter analyze` e `flutter test` sem erros.

## ✅ Concluído — Versão do aplicativo e Agradecimentos nas Configurações

* **Demanda:** Na tela de "Configurações", criar uma seção informando a versão de
  atualização do app com o sufixo estável `stable 1.0` (ex: `1.1.4 - stable 1.0`) e
  botão para abrir a Play Store. Também criar uma seção para "Agradecimentos"
  contendo os contribuidores:
  * "Ruan Gustavo Soares da Silva - Criador do projeto e desenvolvedor"
  * "Glaucia Iara Nascimento Soares - Criadora da nova logo e publicidade"
  * "Hyago dos Santos - Idealizador da Palavra do Dia"
* **Correção aplicada:**
  * `lib/src/view/settings_view.dart`:
    * Atualizado o card de atualização para "Versão do aplicativo", exibindo a
      versão lida dinamicamente via `package_info_plus` (com fallback) formatada
      como `1.1.4 - stable 1.0` dentro de uma tag/chip com ícone de verificação
      (`Icons.verified_rounded`) e botão para verificar novidades na Play Store.
    * Adicionada nova seção "Agradecimentos" (`Icons.volunteer_activism_rounded`)
      com cartões visuais para cada contribuinte, com avatar estilizado, nome
      em destaque e descrição da contribuição.

## ✅ Concluído — Caixa de seleção de ações no AppBar (Bíblia e Harpa)

* **Demanda:** No `AppBar` onde carregam os conteúdos (`BibleContentView` e `HarpContentView`),
  havia múltiplos botões de ação ocupando muito espaço, encurtando o título (ex.: "Deuteronô...")
  e confundindo o usuário. Substituir o excesso de botões por uma caixa de seleção/menu
  de opções onde o usuário clica e escolhe o que deseja fazer.
* **Correção aplicada:**
  * `lib/src/view/bible_content_view.dart`:
    * Substituiu os 3 botões avulsos de ação (`IconButton` de leitura automática,
      destaque e compartilhar) por um `PopupMenuButton` único com `Icons.more_vert`.
    * A caixa de seleção exibe itens com ícone, título descritivo e estado atual:
      * **Leitura automática:** status "Ativada" / "Desativada" e diálogo de confirmação.
      * **Modo destaque:** status "Ativado" / "Desativado" com feedback.
      * **Compartilhar:** indicação de capítulo completo ou quantidade de versículos selecionados.
      * **Limpar seleção:** opção rápida para desmarcar versículos quando houver seleção ativa.
    * Mantido badge com contagem de versículos selecionados no ícone do menu.
  * `lib/src/view/harp_content_view.dart`:
    * Adicionada a mesma caixa de seleção/menu no `AppBar` com:
      * **Compartilhar hino:** compartilha a letra completa do hino (título, versos e coro).
      * **Tocar sem parar / Reprodução contínua:** alternador do modo contínuo com indicador de status.
      * **Reproduzir / Pausar / Parar áudio:** controles rápidos de áudio diretamente no menu quando houver faixa disponível.
  * `lib/src/view/component/app_bar_component.dart`:
    * Adicionados `maxLines: 1` e `overflow: TextOverflow.ellipsis` no título do `CustomAppBar`
      para garantir tratamento gracioso de títulos longos em qualquer densidade de tela.

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