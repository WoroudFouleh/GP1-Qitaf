import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
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
            //icon: 'icon_notification'
            largeIcon: DrawableResourceAndroidBitmap('adminn'),
          ),
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

  Future<void> sendNotification(String title, String body) async {
    String accessToken =
        "ya29.c.c0ASRK0GaZ1Lo3_hpZku-wCvWAfFDBTsuPur-PNSzbQYC8HpAsJV4Mj35iNK8pdTlGaujgnkqly4VMeztpYr7_mrqL6bhTkAYy004Ly3tDhJjryUZhJRhLFLFL92xkTMblJz9TgoTQpN8IdeMcD_VCZjPQIL8vHNnD0maopz9QLJJ-8FLUoagAYqtKLMzKeE49BFLJ4saUYVzWOLTa-hIv7v50y7_DCd1DMCAy8lJeOxhEFJh-oO-xeLCUU_fbb0YmZ-AWbCjrzL4QAwWLxzMDl9MRR-bfeUfZJSp-X2bOZX_klNgc5hXUX_tRGF5Fdzjbw-JZmLY17r-5AcfsjEe0UNa6zVdltLlddqgUQp_nUC4FD9PayqDohd0G384ConuS4yqOk_ax8ep6x4Mx44SkW2Z0rF_1qfBWpUZMg8YdF_aMn34flJ-I-YeJVi8Wtbd_R6sdvBQXgqv8OFZ4Q2y6-26MFfnm-_fmdsJaFo-V29JxZZ6cpWpV5Z2Q_SUpW6S052ltU3r_kOoifhv1vm9ssY3BrR1pOupi5U1j6ZJ5lc3OlbtVWecR7dbxItuweoYyd974lqc7bUWFMW0r30lisU7-0hgSz2gq9neOYq7qrarvmtrWl9uoQgajFvd9R7U9zR2RU6toY4U_xku8cX0wOInrwy3qoy45xuO-jqbIrVdrRrr2hnuFa84ih5eut2ockwgay9Q65pOM7Ihix5byJ_q-iwgsg_mkZcZusuM-oQ1soF9RBjU_s9ba1aImvzvRlI7it935ywaUJfwSe4XIazJ4dR2ceWVYaVwF240VqUWMF40qBug0g7dej6wFOg_uIsOw5e4i0osa9ucSIWpaXgQy2OMWB9_Uz6Rdblx9fYFp8B5i64RZ5hJrpq0ok4UdYI09X7ilJWoO6In7z2sIdVczVjR-8V-lpkbIXMiu8z8q85e4Y72hrccq5f6dt5z_la01bigoZ19z2BBgFBVVd1d1Q5JJ45Q4owMxtknS4J_YooFQY3uFWpe";
    var messagePayload = {
      'message': {
        'topic': "all_devices",
        'notification': {'title': title, 'body': body},
        'data': {'type': 'chat'},
        'android': {
          'priority': "high",
          'notification': {'channel_id': "high_importance_channel"}
        }
      }
    };
    final url =
        'https://fcm.googleapis.com/v1/projects/messageapp-75f3c/messages:send';
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-type': 'application/json'
    };
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(messagePayload),
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Error sending notification: ${response.body}');
    }
  }

  Future<void> sendNotificationToSpecific(
      String? target, String title, String body) async {
    String accessToken =
        "ya29.c.c0ASRK0GaZ1Lo3_hpZku-wCvWAfFDBTsuPur-PNSzbQYC8HpAsJV4Mj35iNK8pdTlGaujgnkqly4VMeztpYr7_mrqL6bhTkAYy004Ly3tDhJjryUZhJRhLFLFL92xkTMblJz9TgoTQpN8IdeMcD_VCZjPQIL8vHNnD0maopz9QLJJ-8FLUoagAYqtKLMzKeE49BFLJ4saUYVzWOLTa-hIv7v50y7_DCd1DMCAy8lJeOxhEFJh-oO-xeLCUU_fbb0YmZ-AWbCjrzL4QAwWLxzMDl9MRR-bfeUfZJSp-X2bOZX_klNgc5hXUX_tRGF5Fdzjbw-JZmLY17r-5AcfsjEe0UNa6zVdltLlddqgUQp_nUC4FD9PayqDohd0G384ConuS4yqOk_ax8ep6x4Mx44SkW2Z0rF_1qfBWpUZMg8YdF_aMn34flJ-I-YeJVi8Wtbd_R6sdvBQXgqv8OFZ4Q2y6-26MFfnm-_fmdsJaFo-V29JxZZ6cpWpV5Z2Q_SUpW6S052ltU3r_kOoifhv1vm9ssY3BrR1pOupi5U1j6ZJ5lc3OlbtVWecR7dbxItuweoYyd974lqc7bUWFMW0r30lisU7-0hgSz2gq9neOYq7qrarvmtrWl9uoQgajFvd9R7U9zR2RU6toY4U_xku8cX0wOInrwy3qoy45xuO-jqbIrVdrRrr2hnuFa84ih5eut2ockwgay9Q65pOM7Ihix5byJ_q-iwgsg_mkZcZusuM-oQ1soF9RBjU_s9ba1aImvzvRlI7it935ywaUJfwSe4XIazJ4dR2ceWVYaVwF240VqUWMF40qBug0g7dej6wFOg_uIsOw5e4i0osa9ucSIWpaXgQy2OMWB9_Uz6Rdblx9fYFp8B5i64RZ5hJrpq0ok4UdYI09X7ilJWoO6In7z2sIdVczVjR-8V-lpkbIXMiu8z8q85e4Y72hrccq5f6dt5z_la01bigoZ19z2BBgFBVVd1d1Q5JJ45Q4owMxtknS4J_YooFQY3uFWpe";
    var messagePayload = {
      'message': {
        'token': target,
        'notification': {'title': title, 'body': body},
        'data': {'type': 'chat'},
        'android': {
          'priority': "high",
          'notification': {'channel_id': "high_importance_channel"}
        }
      }
    };
    final url =
        'https://fcm.googleapis.com/v1/projects/messageapp-75f3c/messages:send';
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-type': 'application/json'
    };
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(messagePayload),
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully');
      //saveNotificationToFirebase(target, title, body, userId, page);
    } else {
      print('Error sending notification: ${response.body}');
    }
  }

  Future<void> saveNotificationToFirebase(String? target, String title,
      String body, String userId, String page) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'userId': userId,
      'page': page
    });
    print('Notification saved successfully');
  }
}
