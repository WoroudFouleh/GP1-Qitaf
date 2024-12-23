import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/qqq.png',
            fit: BoxFit
                .cover, // تملأ الصورة المساحة بالكامل وتغطي العرض والارتفاع
            width: double.infinity, // الصورة تأخذ العرض الكامل
            height: MediaQuery.of(context)
                .size
                .height, // الصورة تأخذ ارتفاع كامل الشاشة
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600
                    ? 100.0
                    : 20.0, // Adjust padding for web
              ),
              child: child!,
            ),
          ),
        ],
      ),
    );
  }
}
