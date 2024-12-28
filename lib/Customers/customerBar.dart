import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:login_page/Customers/CustomerAdvertisements.dart';
import 'package:login_page/Customers/CustomerHome.dart';
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

class CustomerBar extends StatefulWidget {
  final token;
  final token2;
  const CustomerBar({@required this.token, Key? key, this.token2})
      : super(key: key);

  @override
  State<CustomerBar> createState() => _CustomerBarState();
}

class _CustomerBarState extends State<CustomerBar> {
  int _pageIndex = 0;
  late List<Widget> _pages;
  // إضافة جميع الصفحات التي سيتم عرضها في شريط التنقل
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    String uid = JwtDecoder.decode(widget.token2)['user_id'];
    // Initialize the pages here because widget.token is needed
    print("2Fetching notifications for userId: $uid");
    _pages = [
      CustomerHome(
        token: widget.token,
        userId: uid,
      ), // Pass the token correctly without const
      TabbedInboxScreen(userId: uid),

      NotificationsPage(currentUserId: uid),
      HomeDiscussion(token: widget.token),
      CustomerAdvertisement(token: widget.token),
    ];
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: const Color.fromARGB(255, 33, 121, 31),
        color: const Color.fromARGB(255, 33, 121, 31),
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 26, color: Colors.white),
          Icon(Icons.message, size: 26, color: Colors.white),
          //Icon(Icons.add, size: 26, color: Colors.white),
          Icon(Icons.notifications, size: 26, color: Colors.white),
          Icon(Icons.dashboard_customize, size: 26, color: Colors.white),
          Icon(Icons.newspaper, size: 26, color: Colors.white),
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
