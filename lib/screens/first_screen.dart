import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:login_page/Discussion/Home.dart';
import 'package:login_page/screens/allInbox.dart';
import 'package:login_page/screens/mainMap.dart';
import 'package:login_page/screens/map_screen.dart';
import 'package:login_page/screens/notificationsMainPage.dart';
import 'package:login_page/screens/owner_home.dart';
import 'package:login_page/screens/owner_add.dart';
import 'package:login_page/screens/owner_chat.dart';
import 'package:login_page/screens/owner_notify.dart';

import 'package:jwt_decoder/jwt_decoder.dart';

class HomePage extends StatefulWidget {
  final token;
  final token2;
  const HomePage({@required this.token, Key? key, this.token2})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;
  late List<Widget> _pages;
  // إضافة جميع الصفحات التي سيتم عرضها في شريط التنقل
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    String uid = JwtDecoder.decode(widget.token2)['user_id']; // استخراج UID

    // Initialize the pages here because widget.token is needed
    _pages = [
      OwnerHome(
          token: widget.token,
          userId: uid,
          token2: widget.token2), // Pass the token correctly without const
      TabbedInboxScreen(userId: uid),
      OwnerAdd(token: widget.token),
      NotificationsPage(
        token: widget.token,
        currentUserId: uid,
      ),
      HomeDiscussion(token: widget.token),
    ];
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Color.fromRGBO(15, 99, 43, 1),
        color: const Color.fromRGBO(15, 99, 43, 1),
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 26, color: Colors.white),
          Icon(Icons.message, size: 26, color: Colors.white),
          Icon(Icons.add, size: 26, color: Colors.white),
          Icon(Icons.notifications, size: 26, color: Colors.white),
          Icon(Icons.dashboard_customize, size: 26, color: Colors.white),
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
