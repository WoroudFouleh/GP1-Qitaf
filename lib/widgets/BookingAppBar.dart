import 'package:flutter/material.dart';
import 'package:login_page/screens/custom_drawer.dart'; // تأكد من استيراد CustomDrawer

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: BookingAppBar(),
      ),
      //endDrawer: CustomDrawer(), // إضافة CustomDrawer هنا
      body: Center(
        child: Text(
          '',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class BookingAppBar extends StatelessWidget {
  const BookingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // النص على اليمين والسهم على الشمال
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back, // سهم يتجه لليمين ليكون ع الشمال
              size: 30,
              color: const Color.fromRGBO(15, 99, 43, 1), // لون زيتي
            ),
          ),
          // Row(
          //   children: [
          //     Text(
          //       "إضافة حجز",
          //       style: TextStyle(
          //         fontSize: 23,
          //         fontWeight: FontWeight.bold,
          //         color: Color(0xFF556B2F), // لون زيتي
          //       ),
          //     ),
          //     SizedBox(width: 8), // مسافة صغيرة بين النص والأيقونة
          //     Icon(
          //       Icons.calendar_today, // أيقونة الجدول أو التقويم
          //       size: 30,
          //       color: Color(0xFF556B2F), // لون زيتي
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
