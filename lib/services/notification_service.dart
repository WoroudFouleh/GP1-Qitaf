import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:login_page/main.dart';
import 'package:login_page/screens/dashboard.dart';
import 'package:login_page/screens/welcome_screen.dart';
import 'package:login_page/widgets/welcome_button.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessegingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlitterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  final _messaging = FirebaseMessaging.instance;
  final _localNotification = FlutterLocalNotificationsPlugin();
  bool isFlutterLocationNotificationInitialized = false;
  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessegingBackgroundHandler);
    await _requestPermission();
    await _setupMessageHandler();
    await setupFlitterNotifications();

    final token = await _messaging.getToken();
    print("FCM TOKEN: $token");

    subscribeToTopic('all_devices');
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false);
    print("permission status: ${settings.authorizationStatus}");
  }

  Future<void> setupFlitterNotifications() async {
    if (isFlutterLocationNotificationInitialized) {
      return;
    }
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      " High Importance Notifications",
      description: 'This channel is used for important notifications',
      importance: Importance.high,
    );
    await _localNotification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload == 'chat') {
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => dashboard(),
          ));
        }
      },
    );
    isFlutterLocationNotificationInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
              'high_importance_channel', " High Importance Notifications",
              channelDescription:
                  'This channel is used for important notifications',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher'),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandler() async {
    //foreground
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    //background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroungMessage);
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroungMessage(initialMessage);
    }
  }

  void _handleBackgroungMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => dashboard(),
      ));
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print("cubscribed to: $topic");
  }
}
