import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  //singleton pattern
  static NotificationHelper? _instance;

  NotificationHelper._internal() {
    _instance = this;
  }

  factory NotificationHelper() => _instance ?? NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('Notifikasi tidak diizinkan oleh user.');
    } else {
      print('Notifikasi diizinkan: ${settings.authorizationStatus}');
    }

    const String iconNotification = '@mipmap/launcher_icon';

    const initializationSettingsAndroid =
        AndroidInitializationSettings(iconNotification);
    const initializationSettingsIos = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestAlertPermission: false,
      requestBadgePermission: false,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIos,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print('APNs Token: $apnsToken');

    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $fcmToken');

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print("Pesan diterima (foreground): ${message.data}");
    //   showNotifications(message);
    // });

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print("User klik notifikasi: ${message.data}");
    //   showNotifications(message);
    // });
  }

  final AndroidNotificationDetails _androidNotificationDetails =
      const AndroidNotificationDetails(
    'channel ID',
    'channel name',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
    // color: Color(0xff000000),
  );

  final DarwinNotificationDetails _darwinNotificationDetails =
      const DarwinNotificationDetails(
    presentAlert: true,
    presentSound: true,
    presentBadge: true,
    sound: 'sound.aiff',
  );

  Future<void> showNotifications(RemoteMessage message) async {
    if (message.notification != null) {
      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: _androidNotificationDetails,
          iOS: _darwinNotificationDetails,
        ),
      );
    } else {
      await flutterLocalNotificationsPlugin.show(
        0,
        message.data['action'],
        '',
        NotificationDetails(
          android: _androidNotificationDetails,
          iOS: _darwinNotificationDetails,
        ),
      );
    }
  }

  void selectNotification(String? payload) async {
    //handle your logic here
  }
}
