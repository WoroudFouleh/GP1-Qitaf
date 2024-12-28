import 'dart:convert';
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
        "ya29.c.c0ASRK0GaK7n7hz9kYiGQvqvH1ZUUcGQjQ7fhUNuLSlOBRoI74MhGnbUqUQu3jgq_-Ll6KYqdrmYyAaD3H82fsrgz1G8VhdIeO7M5lUECJi4GwuIKcuISsiWokY39TtUwYyZpaM6harX2mHfDMxahxd5i4r50kgCZvYda9i2o6bIKn0YzBUvWHAA6Q3y6yr0GetSdxd5vO9hEJV1qQf-oRvVW5atp3tO_ssF_vxz8VA3flVM6y5NEYpeHFerFrnmz9SwKIHhNN7GZdMYoXv7QUoBRjZfNbupbS1bLlZvJDtc9PYgPnGJYVi-Rnf_qCujSB_26IdDmkfOmIzbZBRXDjuX_Ktda_jgsiLSB0kZJ9YY_-5O6UA2U32wH383Dcbq62hOpgfw45pQsdsO6JJmbenUFr2iy2s4297VJ6Bv5f8YkbRSbRsMO-Xmc0hjFSXMreJ8Rbqahqq-BfBauMwsW1gFyrnt7kzijmx5mWFc-iVIWjXl4gVo-7w0xOYrXo2Q18ShhZnFrBSBx9r0ysOO8ykFd525amXi_glhQbRtknF8WvcqyfmgI7SmZuSqOF6-5FsZwy5ilZfdVelUzineZQm2Mkcoux6Okd5g7wWWYJ7mcx2ck9J-l84MkojebSIZlQF-7UM9y6Y759S8BpjY5XgfWlujfYwwwIf7jQsUMpMMBzI07p1gsqOWa7ueZseQB10ulkIQjZSeY8ViyjF52OlX4gpr0n5OIk2vc48dFwJZkXzYrcouzU-9qzfwemotvkoYwRt-kjB2W0-_kbaZva_fnvaXZB5O5rMowsY8JrWXW33RVmvzUFhF7kMq7tqh-WldmhXtOJJr52Ot4mfdUQnjO9s1b1Fyhr4F3BkaQZwSsz9ybRZaaZ5nsV8iVqZS7_R5kghqj9IoyX0voBQsROR4MWYJRqXgwoZ7gl0-x1kUORpSxRw_oggUkUJoXqvnf03Qwfff77tQBFFtzpSSOcQqBgoW0fzYnJUF6jiRXypYbFwczcVr0QoWF";
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
        "ya29.c.c0ASRK0GaK7n7hz9kYiGQvqvH1ZUUcGQjQ7fhUNuLSlOBRoI74MhGnbUqUQu3jgq_-Ll6KYqdrmYyAaD3H82fsrgz1G8VhdIeO7M5lUECJi4GwuIKcuISsiWokY39TtUwYyZpaM6harX2mHfDMxahxd5i4r50kgCZvYda9i2o6bIKn0YzBUvWHAA6Q3y6yr0GetSdxd5vO9hEJV1qQf-oRvVW5atp3tO_ssF_vxz8VA3flVM6y5NEYpeHFerFrnmz9SwKIHhNN7GZdMYoXv7QUoBRjZfNbupbS1bLlZvJDtc9PYgPnGJYVi-Rnf_qCujSB_26IdDmkfOmIzbZBRXDjuX_Ktda_jgsiLSB0kZJ9YY_-5O6UA2U32wH383Dcbq62hOpgfw45pQsdsO6JJmbenUFr2iy2s4297VJ6Bv5f8YkbRSbRsMO-Xmc0hjFSXMreJ8Rbqahqq-BfBauMwsW1gFyrnt7kzijmx5mWFc-iVIWjXl4gVo-7w0xOYrXo2Q18ShhZnFrBSBx9r0ysOO8ykFd525amXi_glhQbRtknF8WvcqyfmgI7SmZuSqOF6-5FsZwy5ilZfdVelUzineZQm2Mkcoux6Okd5g7wWWYJ7mcx2ck9J-l84MkojebSIZlQF-7UM9y6Y759S8BpjY5XgfWlujfYwwwIf7jQsUMpMMBzI07p1gsqOWa7ueZseQB10ulkIQjZSeY8ViyjF52OlX4gpr0n5OIk2vc48dFwJZkXzYrcouzU-9qzfwemotvkoYwRt-kjB2W0-_kbaZva_fnvaXZB5O5rMowsY8JrWXW33RVmvzUFhF7kMq7tqh-WldmhXtOJJr52Ot4mfdUQnjO9s1b1Fyhr4F3BkaQZwSsz9ybRZaaZ5nsV8iVqZS7_R5kghqj9IoyX0voBQsROR4MWYJRqXgwoZ7gl0-x1kUORpSxRw_oggUkUJoXqvnf03Qwfff77tQBFFtzpSSOcQqBgoW0fzYnJUF6jiRXypYbFwczcVr0QoWF";
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
    } else {
      print('Error sending notification: ${response.body}');
    }
  }
}
