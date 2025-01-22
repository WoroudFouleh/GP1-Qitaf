import 'package:flutter/material.dart';
import 'package:login_page/Admin/AcceptDelivery.dart';
import 'package:login_page/Admin/advertisements.dart';
import 'package:login_page/Admin/DeliveryAdvertisement.dart';
import 'package:login_page/Admin/productAdvertisements.dart';

import 'package:login_page/Admin/viewAdvertisements.dart';
import 'package:login_page/Delivery/DileveryHome.dart';
import 'package:login_page/screens/owner_profile.dart';
import 'package:login_page/screens/welcome_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text(
              ' المسؤول',
              textAlign: TextAlign.right,
            ),
            accountEmail: const Text(
              'qitaf2025@gmail.com',
              textAlign: TextAlign.right,
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset('assets/images/admin (2).png'),
              ),
            ),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(15, 99, 43, 1),
              image: DecorationImage(
                image: AssetImage('assets/images/cover.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            trailing: const Icon(Icons.campaign),
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text(" إعلانات الصفحة الرئيسية"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Advertisements()),
              );
            },
          ),
          ListTile(
            trailing: const Icon(Icons.add_card),
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text("إعلانات المنتجات"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Productadvertisments()),
              );
            },
          ),
          ListTile(
            trailing: const Icon(Icons.post_add),
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text("إنشاء إعلان  "),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DeliveryAdvertisements()),
              );
            },
          ),
          ListTile(
            trailing: const Icon(Icons.view_agenda),
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text(" إعلانات قطاف"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewAdvertisement()),
              );
            },
          ),
          ListTile(
            trailing: const Icon(Icons.delivery_dining),
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text("طلبات عمل التوصيل "),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeliveryRequestsPage()),
              );
            },
          ),
          const SizedBox(height: 45.0),
          ListTile(
            trailing: Icon(Icons.logout),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text("تسجيل الخروج"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
              );
            },
          ),
          const ListTile(
            trailing: Icon(Icons.settings),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text("الإعدادات"),
            ),
          ),
        ],
      ),
    );
  }
}
