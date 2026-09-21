import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const int _notificationId = 1;
  static const String _lastNotificationKey = 'last_reading_notification';

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> scheduleReadingNotification() async {
    await initialize();

    final prefs = await SharedPreferences.getInstance();
    final lastNotification = prefs.getInt(_lastNotificationKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 17 hours in milliseconds
    const int seventeenHours = 17 * 60 * 60 * 1000;

    if (now - lastNotification >= seventeenHours) {
      // Schedule notification for 17 hours from now
      final DateTime scheduledTime =
          DateTime.now().add(const Duration(hours: 17));
      final tz.TZDateTime scheduledTZ =
          tz.TZDateTime.from(scheduledTime, tz.local);

      await _plugin.zonedSchedule(
        _notificationId,
        'Hora de ler!',
        'Não esqueça de ler a Palavra de Deus hoje.',
        scheduledTZ,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_channel',
            'Leituras',
            channelDescription: 'Notificações de leitura',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );

      // Store when we scheduled this notification
      await prefs.setInt(_lastNotificationKey, now);
    }
  }

  static Future<void> showImmediateNotification() async {
    await initialize();

    await _plugin.show(
      _notificationId,
      'Bem-vindo à Bíblia e Harpa!',
      'Que a Palavra de Deus te abençoe.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reading_channel',
          'Leituras',
          channelDescription: 'Notificações de leitura',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}