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
        "ya29.c.c0ASRK0GYHbz8wK4ltOqydErJMIN2onbECziOKu1-ckPm1FJT0s8gDzJS2mfHSSi0XaxQqNeSbYY-ht4UYgWdxxVq8oRXssWoBNzEU_a-tzsM5Zcb-P7cd-vfnEJnI92PBuXfuHm0eKdi5rjMqmzZaoYYYUW5ax2KFCCqFcJrF3_tsKkLSo1kWzOt-wDuz8FpIQjMUzmd6DRkJoqxm7xGdhfjIHbR40GKVUNRNMds6Q-HtTCrWTfO-KNnxN8BxCr1XGq1xwayH99tyHJvkurx0su2olTNCq9zI--2Otr-vLkNYl9wUFbFQgtQYWPUBXTR4o9oQ1PcMsZMLlDBx6lsZrM2F9jcxhYVBQqNGax0DLaIVYr-wyrTtK3MN384Co_ga67aFuOh-0M_I3iowjtrf06R8eXdQWM1oWBJ9ppemifrprFdwcZlpWXuk8nZczdBMwcyg1iyjOMOufVMBdZ_nU9I56v_6RnqZe0SspyIrQSFUlV5um9UvaRz9UXSZ5YRSee9wezkFIvSFh0BI-_f_h7ucrneMt5Yb4Jdm98SznoraauJVgqkFOOYuwx59g48OkYlq9yVqXg0eO1f_srcU9_3VQnpbJsIg_55_5whZO34Vw5-p4Rk7OFQzvgs_9e-4qXiMiliUU3Rysw_WBnsboSoeuRMmg3atziv6lmI6ZOvRivmlgf-pXzOuqRfpkqJ9Be9jUQygewF4n663cRUI3OtgeypisQhj3t3MpswS-2jz-n9jxQS_s-7mow037pZSkvMW84thk9xSxZuJcusw3oXz8-dRo4S-OzWIuOQy3a4U743jIeBj2wnszfXa9nnWO6rgjnxIdYf9JfalOxccnvVbd6cjblF6IXOUrhnfSSqj6YQttQoMl-RBmcluQa04Js-_I1gRVodM8YbjgaRBa27kmtSgUerWOlitl7YqayeF0Fx_tkws4esamOqkOjmRafSf5utQWFfkw3ZqwBZ69Xjex6R_7f3s698IaamnZ78_7fQBYQqZ6xY";
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
        "ya29.c.c0ASRK0GYHbz8wK4ltOqydErJMIN2onbECziOKu1-ckPm1FJT0s8gDzJS2mfHSSi0XaxQqNeSbYY-ht4UYgWdxxVq8oRXssWoBNzEU_a-tzsM5Zcb-P7cd-vfnEJnI92PBuXfuHm0eKdi5rjMqmzZaoYYYUW5ax2KFCCqFcJrF3_tsKkLSo1kWzOt-wDuz8FpIQjMUzmd6DRkJoqxm7xGdhfjIHbR40GKVUNRNMds6Q-HtTCrWTfO-KNnxN8BxCr1XGq1xwayH99tyHJvkurx0su2olTNCq9zI--2Otr-vLkNYl9wUFbFQgtQYWPUBXTR4o9oQ1PcMsZMLlDBx6lsZrM2F9jcxhYVBQqNGax0DLaIVYr-wyrTtK3MN384Co_ga67aFuOh-0M_I3iowjtrf06R8eXdQWM1oWBJ9ppemifrprFdwcZlpWXuk8nZczdBMwcyg1iyjOMOufVMBdZ_nU9I56v_6RnqZe0SspyIrQSFUlV5um9UvaRz9UXSZ5YRSee9wezkFIvSFh0BI-_f_h7ucrneMt5Yb4Jdm98SznoraauJVgqkFOOYuwx59g48OkYlq9yVqXg0eO1f_srcU9_3VQnpbJsIg_55_5whZO34Vw5-p4Rk7OFQzvgs_9e-4qXiMiliUU3Rysw_WBnsboSoeuRMmg3atziv6lmI6ZOvRivmlgf-pXzOuqRfpkqJ9Be9jUQygewF4n663cRUI3OtgeypisQhj3t3MpswS-2jz-n9jxQS_s-7mow037pZSkvMW84thk9xSxZuJcusw3oXz8-dRo4S-OzWIuOQy3a4U743jIeBj2wnszfXa9nnWO6rgjnxIdYf9JfalOxccnvVbd6cjblF6IXOUrhnfSSqj6YQttQoMl-RBmcluQa04Js-_I1gRVodM8YbjgaRBa27kmtSgUerWOlitl7YqayeF0Fx_tkws4esamOqkOjmRafSf5utQWFfkw3ZqwBZ69Xjex6R_7f3s698IaamnZ78_7fQBYQqZ6xY";
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
