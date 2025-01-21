import 'package:flutter/material.dart';

class OwnerChat extends StatelessWidget {
  final token;
  const OwnerChat({@required this.token, Key? key}) : super(key: key);
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
              color: const Color.fromRGBO(15, 99, 43, 1),
            ),
            titleTextStyle: const TextStyle(
              color: const Color.fromRGBO(15, 99, 43, 1),
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
          //endDrawer: const CustomDrawer(), // استخدام الـ CustomDrawer هنا
        ),
      ),
    );
  }
}
