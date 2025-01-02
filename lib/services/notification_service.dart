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
        "ya29.c.c0ASRK0GYpl9Pqeas1YpN5S2b7GPMp6leeOJc6ONfUJqsYS_x_ykB_9XEXsuKyyRn970RWzR5zScYmYD858biIJbuMOFW5skMsSJuhhlay1Cwgu-4fVqj4HYk2HctiLNaOC1473TSBrAUL74cmR9WRjxplWLMH1ZRmAaOwFOG2cMy7doWLjVwKS8Ti1939QxRRlrm1cajE_yFhrjaC7fmqoQxZRmEwruR4R_LjSuYCCO6rTANg0qRZnd3U7kJWYIzpQmNS-UcplC0efBXpB0rdg_aVfGooms0EQjhh1NGiv3fXSnx4KLIu_OupWCxfWdYeuzWFB6vI9D4IxMnbrtr_JDnqjrGgi6z8rCkrL3vHDA4oojyNja1POP8N384CmMQt4eipFz1pM-mxk-en0VJk557qRh2Xxu_u7Ovt6ix81qjYUqxbk3ojcX7JcUmR8ygzqakdk6uujV6_4mvl179sj4XvwxR7SIvc5fZS8Osvc1kmffrbOb6Zb5M61QVIfun1p5hVfV5rSx0Sxyi6B2VVW6jf__O8Fn3nVY_h9IrXolrdFxn57Zgvfyg2St-4uo2buZZs67aizUU8fwS9VgInzewsnssct5_UQlxjbfzbVup0UZhUZ-VIROfhwxwRegFt9g3qSrFlvzmcOj1sfZpbd2o18RldXvfod7pY43i1sV-Qt1fnadRJUw_9rMbVrfkv9yvfV7w39fdOzfVut3j8U1kazv0vkQ_s4FnJ4toqJlf5Z9YlXIjBVrVywvh7RnygSpx_d2VIcunbhSsf9URvURYu9c3fenMRe6af39ssMktgwbnqOsg4h-MaVc459l_b36-dzenUUds51fc9jSzlxrxcmp604B-sW1-W0Os1Z9O1efsWpVy3_6VpUOYQdU8437UJ5Bxlvow3Qapidr9tRzSjRdQyamW50SlhrfdBsFx3gycSxp6t1BxJgldhbiyFYx5hn6xZ8t0BR6aVfhQJRm9r3tYZZhk24yJuuVZ6XUyv8pdsXh9Y-eu";
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
        "ya29.c.c0ASRK0GYpl9Pqeas1YpN5S2b7GPMp6leeOJc6ONfUJqsYS_x_ykB_9XEXsuKyyRn970RWzR5zScYmYD858biIJbuMOFW5skMsSJuhhlay1Cwgu-4fVqj4HYk2HctiLNaOC1473TSBrAUL74cmR9WRjxplWLMH1ZRmAaOwFOG2cMy7doWLjVwKS8Ti1939QxRRlrm1cajE_yFhrjaC7fmqoQxZRmEwruR4R_LjSuYCCO6rTANg0qRZnd3U7kJWYIzpQmNS-UcplC0efBXpB0rdg_aVfGooms0EQjhh1NGiv3fXSnx4KLIu_OupWCxfWdYeuzWFB6vI9D4IxMnbrtr_JDnqjrGgi6z8rCkrL3vHDA4oojyNja1POP8N384CmMQt4eipFz1pM-mxk-en0VJk557qRh2Xxu_u7Ovt6ix81qjYUqxbk3ojcX7JcUmR8ygzqakdk6uujV6_4mvl179sj4XvwxR7SIvc5fZS8Osvc1kmffrbOb6Zb5M61QVIfun1p5hVfV5rSx0Sxyi6B2VVW6jf__O8Fn3nVY_h9IrXolrdFxn57Zgvfyg2St-4uo2buZZs67aizUU8fwS9VgInzewsnssct5_UQlxjbfzbVup0UZhUZ-VIROfhwxwRegFt9g3qSrFlvzmcOj1sfZpbd2o18RldXvfod7pY43i1sV-Qt1fnadRJUw_9rMbVrfkv9yvfV7w39fdOzfVut3j8U1kazv0vkQ_s4FnJ4toqJlf5Z9YlXIjBVrVywvh7RnygSpx_d2VIcunbhSsf9URvURYu9c3fenMRe6af39ssMktgwbnqOsg4h-MaVc459l_b36-dzenUUds51fc9jSzlxrxcmp604B-sW1-W0Os1Z9O1efsWpVy3_6VpUOYQdU8437UJ5Bxlvow3Qapidr9tRzSjRdQyamW50SlhrfdBsFx3gycSxp6t1BxJgldhbiyFYx5hn6xZ8t0BR6aVfhQJRm9r3tYZZhk24yJuuVZ6XUyv8pdsXh9Y-eu";
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
