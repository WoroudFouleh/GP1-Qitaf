import 'package:flutter/material.dart';
import 'package:login_page/screens/custom_drawer.dart';

class OwnerChat extends StatelessWidget {
  const OwnerChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تعيين اتجاه النص من اليمين إلى اليسار
      child: DefaultTabController(
        length: 4, // عدد التبويبات
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 12, 123, 17),
            ),
            titleTextStyle: const TextStyle(
              color: Color.fromARGB(255, 11, 130, 27),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            elevation: 0,
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                '  الرسائلس ',
                textAlign: TextAlign.right,
              ),
            ),
          ),
          endDrawer: const CustomDrawer(), // استخدام الـ CustomDrawer هنا
        ),
      ),
    );
  }
}
