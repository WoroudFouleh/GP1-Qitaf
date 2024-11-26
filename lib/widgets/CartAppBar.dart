import 'package:flutter/material.dart';
import 'package:login_page/screens/custom_drawer.dart'; // تأكد من استيراد CustomDrawer

class CartPage extends StatelessWidget {
  final String token;
  const CartPage({required this.token, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CartAppBar(),
      ),
      endDrawer: CustomDrawer(token: token), // إضافة CustomDrawer هنا
      body: const Center(
        child: Text(
          'محتويات عربة التسوق',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class CartAppBar extends StatelessWidget {
  const CartAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // النص على اليمين والسهم على الشمال
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back, // سهم يتجه لليمين ليكون ع الشمال
              size: 30,
              color: Color(0xFF556B2F), // لون زيتي
            ),
          ),
          const Row(
            children: [
              Text(
                "عربة التسوّق",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF556B2F), // لون زيتي
                ),
              ),
              SizedBox(width: 8), // مسافة صغيرة بين النص والأيقونة
              Icon(
                Icons.shopping_cart, // أيقونة سلة التسوق
                size: 30,
                color: Color(0xFF556B2F), // لون زيتي
              ),
            ],
          ),
        ],
      ),
    );
  }
}
