import 'package:flutter/material.dart';
import 'package:login_page/Admin/advertisements.dart';
import 'package:login_page/Admin/productAdvertisments.dart';
import 'package:login_page/screens/owner_profile.dart';

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
              'admin@gmail.com',
              textAlign: TextAlign.right,
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset('assets/images/profile.png'),
              ),
            ),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 18, 92, 21),
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
            trailing: const Icon(Icons.campaign),
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text("إعلانات الزبائن"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Advertisements()),
              );
            },
          ),
          const ListTile(
            trailing: Icon(Icons.delivery_dining),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text("طلبات عمل التوصيل "),
            ),
          ),
          const SizedBox(height: 45.0),
          const ListTile(
            trailing: Icon(Icons.logout),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text("تسجيل الخروج"),
            ),
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
