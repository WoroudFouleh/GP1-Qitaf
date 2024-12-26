import 'package:flutter/material.dart';
import 'package:login_page/Auth/test.dart';
import 'package:login_page/screens/LandPage.dart';
import 'package:login_page/screens/details.dart';
import 'package:login_page/screens/navigate.dart';
import 'package:login_page/screens/previousOrders.dart';
import 'package:login_page/screens/production_line.dart';
import 'package:login_page/screens/profile2.dart';
import 'package:login_page/screens/qataf.dart';
import 'package:login_page/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'CustomArabicFont', // Use your custom font family here
      ),
      home: WelcomeScreen(),
    );
  }
}
