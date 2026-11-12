import 'dart:async';

import 'package:biblia_e_harpa/src/services/app_audio_handler.dart';
import 'package:biblia_e_harpa/src/database/app_database.dart';
import 'package:biblia_e_harpa/src/l10n/app_localizations.dart';
import 'package:biblia_e_harpa/src/utils/theme.dart';
import 'package:biblia_e_harpa/src/view/home_view.dart';
import 'package:biblia_e_harpa/src/view/component/language_gate.dart';
import 'package:biblia_e_harpa/src/view/component/mini_player.dart';
import 'package:biblia_e_harpa/src/view/component/started_access_on.dart';
import 'package:biblia_e_harpa/src/controllers/settings_controller.dart';
import 'package:biblia_e_harpa/src/controllers/bible_providers_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

/// Controlador de preferências (tema/tamanho de fonte).
///
/// Fica como campo de nível superior para ser reutilizado pelo aquecimento em
/// paralelo e pelo [MultiProvider].
final SettingsController settingsController = SettingsController();

/// Aquece as dependências pesadas SEM bloquear o primeiro frame.
///
/// Banco SQLite, preferências salvas, variáveis de suporte (.env) e a
/// orientação da tela são carregados em paralelo e com tolerância a falhas:
/// um erro em uma tarefa (ex.: sem permissão, sem rede) nunca impede o app de
/// abrir. Cada tela consome o que precisa quando o usuário realmente chega a
/// ela, então nenhum destes resultados precisa estar pronto antes do [runApp].
Future<void> _warmUp() async {
  final tasks = <Future<void>>[
    // Abre o banco (e a pasta de documentos) já no início, em segundo plano.
    AppDatabase.instance.initialize(),
    // Carrega o tema e o tamanho de fonte salvos.
    settingsController.initialize(),
    // Carrega as variáveis de suporte usadas na tela de configurações.
    dotenv.load(fileName: ".env"),
  ];

  if (!kIsWeb) {
    // Mantém o app apenas em retrato.
    tasks.add(
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]));
  }

  await Future.wait(tasks);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // O modo contínuo do player global acompanha a preferência do usuário.
  AppAudioHandler.continuousResolver =
      () => settingsController.continuousPlayback;

  // Inicialização do player de áudio. Em Android/iOS é um no-op síncrono
  // (o just_audio usa o player nativo); só registra o MediaKit em desktop.
  JustAudioMediaKit.ensureInitialized(windows: true);

  // Dispara o aquecimento em paralelo, sem aguardar, para que o primeiro
  // frame seja desenhado imediatamente (reduz o tempo de inicialização em
  // aparelhos de entrada, ex.: GPU Mali G52 / CPU Cortex-A55).
  unawaited(_warmUp());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsController),
        ...BibleProvidersController.build(),
      ],
      child: const MyApp(),
    ),
  );

  // Registra a sessão de áudio depois do runApp para preservar o primeiro
  // frame. O handler é aguardado pelas telas via `ensureAudioHandler()`.
  unawaited(ensureAudioHandler());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, _) {
        // Mantém os serviços/controladores (fora da árvore de widgets) no
        // idioma atual para mensagens e notificações.
        AppLocalizations.currentLanguage = settings.language;
        final upgraderMessages =
            UpgraderMessages(code: settings.language.upgraderCode);
        return MaterialApp(
          onGenerateTitle: (context) => context.l10n.t('Bíblia e Harpa'),
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          navigatorKey: appNavigatorKey,
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: settings.themeMode,
          debugShowCheckedModeBanner: false,
          home: LanguageGate(
            child: UpgradeAlert(
              upgrader: Upgrader(
                debugLogging: false,
                messages: upgraderMessages,
              ),
              child: const StartupGate(child: HomeView()),
            ),
          ),
        );
      },
    );
  }
}
