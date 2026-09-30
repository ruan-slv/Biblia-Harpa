import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Serviço de notificações locais.
///
/// Agenta uma notificação de leitura a cada 17 horas. Ao tocar na
/// notificação, o aplicativo é aberto.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const int _notificationId = 1;
  static const String _nextNotificationKey = 'next_reading_notification_time';

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    } catch (_) {
      // Fallback: mantém o timezone padrão do pacote.
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    final InitializationSettings settings;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      // O plugin de notificações para Windows pode não estar disponível
      // nesta versão; usa settings vazios para não quebrar a inicialização.
      settings = const InitializationSettings();
    } else {
      settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
    }

    // Permissões de notificação (Android 13+).
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        debugPrint('Notificação recebida: ${notificationResponse.payload}');
      },
    );
    _initialized = true;
  }

  /// Agenda a próxima notificação de leitura (a cada 17 horas).
  ///
  /// Deve ser chamado toda vez que o aplicativo for aberto. Se já houver uma
  /// notificação agendada para o futuro, ela é mantida; caso contrário, uma
  /// nova é agendada para 17 horas a partir de agora.
  static Future<void> scheduleReadingNotification() async {
    try {
      await initialize();
    } catch (e) {
      debugPrint('Falha ao inicializar notificações: $e');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final nextTime = prefs.getInt(_nextNotificationKey) ?? 0;

    // Já existe uma notificação agendada para o futuro? Mantém.
    if (nextTime > now.millisecondsSinceEpoch) {
      return;
    }

    final scheduled = now.add(const Duration(hours: 17));
    final scheduledTZ = tz.TZDateTime.from(scheduled, tz.local);

    try {
      // Cancela qualquer agendamento anterior para evitar duplicatas.
      await _plugin.cancel(_notificationId);

      await _plugin.zonedSchedule(
        _notificationId,
        'Hora de ler!',
        'Não esqueça de ler a Palavra de Deus hoje. Toque para abrir o app.',
        scheduledTZ,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_channel',
            'Leituras',
            channelDescription: 'Lembrete de leitura da Bíblia e Harpa',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      await prefs.setInt(_nextNotificationKey, scheduled.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Falha ao agendar notificação: $e');
    }
  }
}
