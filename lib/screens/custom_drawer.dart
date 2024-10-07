import 'package:flutter/material.dart';
import 'package:login_page/screens/owner_profile.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text(
              'ورود فوله',
              textAlign: TextAlign.right,
            ),
            accountEmail: const Text(
              'woroud@gmail.com',
              textAlign: TextAlign.right,
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset('assets/images/profilew.png'),
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
            trailing: const Icon(Icons.person),
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text("ملفي الشخصي"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OwnerProfile()),
              );
            },
          ),
          const ListTile(
            trailing: Icon(Icons.add_card),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text("الطلبات"),
            ),
          ),
          const ListTile(
            trailing: Icon(Icons.add_shopping_cart),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text("عربة التسوق"),
            ),
          ),
          const ListTile(
            trailing: Icon(Icons.card_giftcard),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text("الطلبات السابقة"),
            ),
          ),
          const SizedBox(height: 28.0),
          const ListTile(
            trailing: Icon(Icons.post_add),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text(" منشوراتي"),
            ),
          ),
          const ListTile(
            trailing: Icon(Icons.work),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text("طلبات العمل"),
            ),
          ),
          const ListTile(
            trailing: Icon(Icons.money),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text("طلبات شراء الزبائن"),
            ),
          ),
          const ListTile(
            trailing: Icon(Icons.book),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text("طلبات حجز الزبائن"),
            ),
          ),
          const SizedBox(height: 28.0),
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
