// notification_screen.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late FirebaseMessaging _messaging;

  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  void _setupFCM() async {
    _messaging = FirebaseMessaging.instance;

    // Request permission for iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not granted permission');
    }

    // Get the device token
    String? token = await _messaging.getToken();
    print('Device Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Notification title: ${message.notification?.title}');
        print('Notification body: ${message.notification?.body}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('FCM Notifications Example')),
    );
  }
}
