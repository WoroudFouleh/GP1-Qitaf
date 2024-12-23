import 'package:flutter/material.dart';
import 'package:login_page/screens/custom_drawer.dart'; // تأكد من استيراد CustomDrawer

class Ordersappbar extends StatelessWidget {
  const Ordersappbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(15, 99, 43, 1),
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
              color: Color.fromARGB(255, 255, 255, 254), // لون زيتي
            ),
          ),
          const Row(
            children: [
              Text(
                "تفاصيل الطلب ",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // لون زيتي
                ),
              ),
              SizedBox(width: 8), // مسافة صغيرة بين النص والأيقونة
              Icon(
                Icons.note, // أيقونة سلة التسوق
                size: 30,
                color: Colors.white, // لون زيتي
              ),
            ],
          ),
        ],
      ),
    );
  }
}
