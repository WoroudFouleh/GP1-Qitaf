import 'package:flutter/material.dart';
import 'package:login_page/Admin/Delivery.dart';
import 'package:login_page/Admin/Posts.dart';
import 'package:login_page/Admin/Statistics.dart';
import 'package:login_page/Admin/adminNotifications.dart';
import 'package:login_page/Admin/admin_drawer.dart';
import 'package:login_page/screens/welcome_screen.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    StatisticsPage(),
    DeliveryPage(),
    PostsPage(),
  ];

  final List<String> _titles = [
    'الإحصائيات',
    'إدارة التوصيلات',
    'المنشورات',
  ];

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'تأكيد تسجيل الخروج',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(15, 99, 43, 1),
              ),
            ),
            content: const Text(
              'هل أنت متأكد أنك تريد تسجيل الخروج؟',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.cancel,
                    color: Color.fromARGB(255, 255, 0, 0)),
                label: const Text(
                  'لا',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  );
                },
                icon: const Icon(Icons.check,
                    color: Color.fromRGBO(15, 99, 43, 1)),
                label: const Text(
                  'نعم',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(15, 99, 43, 1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _titles[_currentIndex],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
          iconTheme: const IconThemeData(
              color: Colors.white), // تغيير لون الثلاثة شحطات
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminNotificationsPage()),
                );
              },
              icon: const Icon(Icons.notifications, color: Colors.white),
            ),
            IconButton(
              onPressed: _showLogoutConfirmationDialog,
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ],
        ),
        drawer: const AdminDrawer(),
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'الإحصائيات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining),
              label: 'التوصيل',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.post_add),
              label: 'المنشورات',
            ),
          ],
          selectedItemColor: const Color.fromRGBO(15, 99, 43, 1),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
