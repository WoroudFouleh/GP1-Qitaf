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
        "ya29.c.c0ASRK0GZuQpGKeonZTOEs7LGrgjM_ZFfd3tnzlO1rIZK_KbWl8NUl1i7RDaY2Z7UurNwFMFQMiUw_hK4Ru8KgGyV907Xq8PDqM9MUKeI9FlVTpcPSM2b8_yJdOk6d2lloIkQwpHU_QkrByL32Rhu55PdbqJk5WTi3QO0B6a269h-krI3lKFW3DKIiGAmSzmnO8442pzd7oBGrdus7RNkkFKAZxmWGn5rEuVX9E0th8I-1qLIYsWjt9HyaLJGUa-h5622wvKIQ4ADKESEQPCr_H_1M00zA6R-GseJFKVxlfbbTIbEKOJNer-CMi1kal0RWhU5Xlm16HGMEhbbYCBQfyZdvxVx5GPY8OqqIcsARwd5LiPWPBCPUDi0L384Kq5Vdlf34UU9rnhQrFQngmUrhSBoy_x3f8Brm2ngpsyQZj12hI3ZqvsOlI2-jxy8xxyIv6rct5tvauJjzvu4S1Id5MawFX9Sw89-tX0QWeYm49MbBZJSQe_Ogup3jhIJZh5aQ6kmxYSu65g_v-i-_6M_JtBOm2aJFgQ8wOopgyqgv-4ew3YnamJuzyckBSxVMeY8_22lW18dmMFpreFwI8SZZWaJlecxg-WFXne6ldoZoe39Ql3r6UZ1Uety0FWBiF66pngwOSUsZ_w_rS07nzORm6ic5e8Mc_On4qXvlnxVeau59a713so7O_kpistdVRa_6Zbj2uM6vtXSj96V22o53xRl9W9QMOY5jx6J9rzVsYmRRYbVZ1wlqIszvgS58YWrRnqnhvlt3YpV2F2wUUjcZkyRdXY6W6r0tI_1F2mqzlW9Fgm8qtucYqFJqq8Wt2whrhekQi7mVmdlqqzUSa8yrkBvSg4iyJnq7-YZbBYlnbM1lo6xZZm6ah6BVR3-urzkr19eVRmXpz8mtcaRRVcoM2twjMosIrXdMp8njjiXpuu-2lIMvQldSssWb0rYj2dgRbS05-ubFcvl24Vs9-X26Sbcbqbho3Mn0-7-kX0RqIMV5clS9ztck-v5";
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
        "ya29.c.c0ASRK0GZuQpGKeonZTOEs7LGrgjM_ZFfd3tnzlO1rIZK_KbWl8NUl1i7RDaY2Z7UurNwFMFQMiUw_hK4Ru8KgGyV907Xq8PDqM9MUKeI9FlVTpcPSM2b8_yJdOk6d2lloIkQwpHU_QkrByL32Rhu55PdbqJk5WTi3QO0B6a269h-krI3lKFW3DKIiGAmSzmnO8442pzd7oBGrdus7RNkkFKAZxmWGn5rEuVX9E0th8I-1qLIYsWjt9HyaLJGUa-h5622wvKIQ4ADKESEQPCr_H_1M00zA6R-GseJFKVxlfbbTIbEKOJNer-CMi1kal0RWhU5Xlm16HGMEhbbYCBQfyZdvxVx5GPY8OqqIcsARwd5LiPWPBCPUDi0L384Kq5Vdlf34UU9rnhQrFQngmUrhSBoy_x3f8Brm2ngpsyQZj12hI3ZqvsOlI2-jxy8xxyIv6rct5tvauJjzvu4S1Id5MawFX9Sw89-tX0QWeYm49MbBZJSQe_Ogup3jhIJZh5aQ6kmxYSu65g_v-i-_6M_JtBOm2aJFgQ8wOopgyqgv-4ew3YnamJuzyckBSxVMeY8_22lW18dmMFpreFwI8SZZWaJlecxg-WFXne6ldoZoe39Ql3r6UZ1Uety0FWBiF66pngwOSUsZ_w_rS07nzORm6ic5e8Mc_On4qXvlnxVeau59a713so7O_kpistdVRa_6Zbj2uM6vtXSj96V22o53xRl9W9QMOY5jx6J9rzVsYmRRYbVZ1wlqIszvgS58YWrRnqnhvlt3YpV2F2wUUjcZkyRdXY6W6r0tI_1F2mqzlW9Fgm8qtucYqFJqq8Wt2whrhekQi7mVmdlqqzUSa8yrkBvSg4iyJnq7-YZbBYlnbM1lo6xZZm6ah6BVR3-urzkr19eVRmXpz8mtcaRRVcoM2twjMosIrXdMp8njjiXpuu-2lIMvQldSssWb0rYj2dgRbS05-ubFcvl24Vs9-X26Sbcbqbho3Mn0-7-kX0RqIMV5clS9ztck-v5";
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
