import 'dart:convert'; // For base64 decoding
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:login_page/Customers/CustomerProfile.dart';
import 'package:login_page/screens/CustomerWork.dart';
import 'package:login_page/screens/MyBooking.dart';
import 'package:login_page/screens/OwnerBooking.dart';
import 'package:login_page/screens/OwnerWorking.dart';
import 'package:login_page/screens/ProfilePage.dart';
import 'package:login_page/screens/owner_profile.dart';
import 'package:login_page/screens/CartPage.dart';
import 'package:login_page/screens/previousOrders.dart';

class CustomDrawer2 extends StatefulWidget {
  final token;

  const CustomDrawer2({required this.token, Key? key}) : super(key: key);

  @override
  _CustomDrawer2State createState() => _CustomDrawer2State();
}

class _CustomDrawer2State extends State<CustomDrawer2> {
  late String firstName;
  late String lastName;
  late String email;
  String? profilePhotoBase64; // Store the base64 image string

  @override
  void initState() {
    super.initState();

    // Decode the token using jwt_decoder and extract necessary fields
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    firstName = jwtDecoderToken['firstName'] ?? 'No First Name';
    lastName = jwtDecoderToken['lastName'] ?? 'No Last Name';
    email = jwtDecoderToken['email'] ?? 'No Email';
    profilePhotoBase64 = jwtDecoderToken['profilePhoto'];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              '$firstName $lastName',
              textAlign: TextAlign.right,
            ),
            accountEmail: Text(
              email,
              textAlign: TextAlign.right,
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                // Check if profile photo exists, if not, show a default asset image
                child: profilePhotoBase64 != null
                    ? Image.memory(
                        base64Decode(profilePhotoBase64!),
                        fit: BoxFit.cover,
                        width: 90.0,
                        height: 90.0,
                      )
                    : Image.asset(
                        'assets/images/profilew.png'), // Default image
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
                MaterialPageRoute(
                    builder: (context) => CustomerProfile(
                          token: widget.token,
                        )),
              );
            },
          ),
          ListTile(
            trailing: Icon(Icons.add_card),
            title: Align(
              alignment: Alignment.centerRight,
              child: Text("طلبات الحجز"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyBookingPage(
                    token: widget.token,
                  ),
                ),
              );
            },
          ),
          ListTile(
            trailing: const Icon(Icons.work),
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text("طلبات العمل"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerWorkPage(token: widget.token),
                ),
              );
            },
          ),
          ListTile(
            trailing: const Icon(Icons.add_shopping_cart),
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text("عربة التسوق"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CartPage(
                        token: widget.token)), // التنقل إلى صفحة عربة التسوق
              );
            },
          ),
          ListTile(
            trailing: const Icon(Icons.card_giftcard),
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text("الطلبات السابقة"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Previousorders(token: widget.token)),
              );
            },
          ),
          const SizedBox(height: 28.0),
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
