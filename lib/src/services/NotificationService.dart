import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Inicializa Timezones
    tz.initializeTimeZones();

    // Configuração Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuração Geral
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Solicitar permissão para Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> agendarNotificacaoParaAmanha() async {
    // Agenda para 24 horas a partir de agora (ou defina um horário fixo)
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(days: 1));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID da notificação
      'Nova Palavra do Dia!', // Título
      'Abra o app para visualizar a nova palavra do dia', // Corpo
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_word_channel', // ID do canal
          'Palavra do Dia', // Nome do canal
          channelDescription: 'Notificações diárias da palavra do dia',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ... (código anterior)

  Future<void> enviarNotificacaoImediata({required String titulo, required String corpo}) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'avisos_channel', // ID diferente para avisos
      'Novos Avisos',
      channelDescription: 'Notificações de novos avisos e informações',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    // ID aleatório para não sobrescrever notificações anteriores de avisos
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      titulo,
      corpo,
      notificationDetails,
    );
  }
}
