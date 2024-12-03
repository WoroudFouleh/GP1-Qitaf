import 'package:flutter/material.dart';
import 'package:login_page/Admin/AcceptDelivery.dart';
import 'package:login_page/Admin/Admin.dart';
import 'package:login_page/Auth/test.dart';
import 'package:login_page/Customers/CustomerAdvertisements.dart';
import 'package:login_page/Customers/CustomersBuying.dart';
import 'package:login_page/Delivery/DileveryHome.dart';
import 'package:login_page/Discussion/Home.dart';
import 'package:login_page/screens/LandPage.dart';
import 'package:login_page/screens/details.dart';
import 'package:login_page/screens/previousOrders.dart';
import 'package:login_page/screens/production_line.dart';
import 'package:login_page/screens/profile2.dart';
import 'package:login_page/screens/qataf.dart';
import 'package:login_page/screens/welcome_screen.dart';

void main() {
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
      home: AdminPage(),
    );
  }
}
