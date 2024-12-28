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
        "ya29.c.c0ASRK0GY21_24KrfwlrUIWqCCLN070Mfv33PnUR_0fBSK80O09uB9XE-6ofuP2ehV6zUnjM7k-_5rP89jh719myaUqAcHFiBV2vgmDlcwMgSW54oQTZOB3J8YQUWmXcD_Z6YCgn4sQ3BiADgdf5Bku4bh_C81B7QX-no_cIymNvnER-chVciT55xUFWbhhXtjItWdnZqAY7XmrZiHJ9yPR1yPiCR7kQspXexyD0vKxsFoApVe51IO-UrDufEHjcCuNdiLdXvq-0AMI6aoLY6IKCvsrgeG1xH40IKKT6GoOhpNDorNrEVj6Fu7Hp02ewy3ySBp2LHV9Q4gJ5nWUdy-E8xclwcnPoFrNyuIkICbXzVQYcylxClbMtEXG385Dl1n9pu7FdcapUaZQclM3-n7Oxt1dVBSz8tOa1Fd2Uaa1rut1V6992caWgSms_ozOVIww9R_BSU-XrbSwat-X24eJUolBykR4_FM9RInvr8VteBqiMckqB5q3YXuV-lt9yi1-s6JV2IgteUxciYy7jSBZRbwm-h0gMxMlSc1MsJfXSYVRj3UXWS00wY4Vz_3S9kibe1-SjwSrX-1O3eR4X_qv5m0iox5eyu46qcX8W50eU7VJhJnOiF8pUVm3Zys9Xuvdsl2flq6OVfpt_dRX4jxsrFxfMRu1pYV0jYQFZfh7tMQrV0OMRthtF6ueJB3WX37sr9O8vks_U1qy8k-cepbhuawrUlk-mXpwm7m59zuR0Z0fjVdl8xpFlx87mZyUik88a4jrj2oqUpwt2nq3ygnu3oU47-6sR444rhkzpc8UlvdombWayWnSX5jW5Qae2p0M1UQugQWVZwBuYvYolvaee1v93kiS9dQb81j592dY8s63m7dr6q8hRO4awBUcJfx-bv2B0dqgd6Ycl37ue-X1oi787ZujY1SjeMZOafy-w9lFISrv18qMbS5x8yhXsVfR29UXem7vFl_YflWSo3iJhpB9vOWZFgYIU779252IR9wBJkpWUOf3-8";
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
      String? target, String title, String body, String userId) async {
    String accessToken =
        "ya29.c.c0ASRK0GY21_24KrfwlrUIWqCCLN070Mfv33PnUR_0fBSK80O09uB9XE-6ofuP2ehV6zUnjM7k-_5rP89jh719myaUqAcHFiBV2vgmDlcwMgSW54oQTZOB3J8YQUWmXcD_Z6YCgn4sQ3BiADgdf5Bku4bh_C81B7QX-no_cIymNvnER-chVciT55xUFWbhhXtjItWdnZqAY7XmrZiHJ9yPR1yPiCR7kQspXexyD0vKxsFoApVe51IO-UrDufEHjcCuNdiLdXvq-0AMI6aoLY6IKCvsrgeG1xH40IKKT6GoOhpNDorNrEVj6Fu7Hp02ewy3ySBp2LHV9Q4gJ5nWUdy-E8xclwcnPoFrNyuIkICbXzVQYcylxClbMtEXG385Dl1n9pu7FdcapUaZQclM3-n7Oxt1dVBSz8tOa1Fd2Uaa1rut1V6992caWgSms_ozOVIww9R_BSU-XrbSwat-X24eJUolBykR4_FM9RInvr8VteBqiMckqB5q3YXuV-lt9yi1-s6JV2IgteUxciYy7jSBZRbwm-h0gMxMlSc1MsJfXSYVRj3UXWS00wY4Vz_3S9kibe1-SjwSrX-1O3eR4X_qv5m0iox5eyu46qcX8W50eU7VJhJnOiF8pUVm3Zys9Xuvdsl2flq6OVfpt_dRX4jxsrFxfMRu1pYV0jYQFZfh7tMQrV0OMRthtF6ueJB3WX37sr9O8vks_U1qy8k-cepbhuawrUlk-mXpwm7m59zuR0Z0fjVdl8xpFlx87mZyUik88a4jrj2oqUpwt2nq3ygnu3oU47-6sR444rhkzpc8UlvdombWayWnSX5jW5Qae2p0M1UQugQWVZwBuYvYolvaee1v93kiS9dQb81j592dY8s63m7dr6q8hRO4awBUcJfx-bv2B0dqgd6Ycl37ue-X1oi787ZujY1SjeMZOafy-w9lFISrv18qMbS5x8yhXsVfR29UXem7vFl_YflWSo3iJhpB9vOWZFgYIU779252IR9wBJkpWUOf3-8";
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
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'userId': userId,
      });
    } else {
      print('Error sending notification: ${response.body}');
    }
  }
}
