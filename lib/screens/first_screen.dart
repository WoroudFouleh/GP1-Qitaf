import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:login_page/screens/owner_home.dart';
import 'package:login_page/screens/owner_add.dart';
import 'package:login_page/screens/owner_chat.dart';
import 'package:login_page/screens/owner_notify.dart';
import 'package:login_page/screens/map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;

  // إضافة جميع الصفحات التي سيتم عرضها في شريط التنقل
  final List<Widget> _pages = [
    const OwnerHome(), // صفحة الصفحة الرئيسية
    const OwnerChat(), // صفحة الرسائل
    const OwnerAdd(), // صفحة الإضافة
    const OwnerNotify(),
    const GoogleMapPage()

    // صفحة الإشعارات
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: const Color.fromARGB(255, 39, 145, 43),
        color: const Color.fromARGB(255, 28, 139, 34),
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 26, color: Colors.white),
          Icon(Icons.message, size: 26, color: Colors.white),
          Icon(Icons.add, size: 26, color: Colors.white),
          Icon(Icons.notifications, size: 26, color: Colors.white),
          Icon(Icons.location_on, size: 26, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index; // تحديث الصفحة المعروضة
          });
        },
      ),
      body: IndexedStack(
        index: _pageIndex,
        children: _pages, // عرض الصفحات بناءً على الـ _pageIndex
      ),
    );
  }
}
