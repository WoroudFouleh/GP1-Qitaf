import 'package:flutter/material.dart';
import 'package:login_page/Auth/test.dart';
import 'package:login_page/screens/LandPage.dart';
import 'package:login_page/screens/details.dart';
import 'package:login_page/screens/navigate.dart';
import 'package:login_page/screens/notificationScreem.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:login_page/screens/previousOrders.dart';
import 'package:login_page/screens/production_line.dart';
import 'package:login_page/screens/profile2.dart';
import 'package:login_page/screens/qataf.dart';
import 'package:login_page/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:login_page/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();
  await initializeDateFormatting('ar', null);
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'CustomArabicFont', // Use your custom font family here
      ),
      home: const WelcomeScreen(),
    );
  }
}
