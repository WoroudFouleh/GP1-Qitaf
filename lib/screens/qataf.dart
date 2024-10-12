import 'package:flutter/material.dart';
import 'package:login_page/screens/custom_drawer.dart';

class QatafPage extends StatefulWidget {
  const QatafPage({super.key});

  @override
  State<QatafPage> createState() => _QatafPageState();
}

class _QatafPageState extends State<QatafPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تعيين اتجاه النص من اليمين إلى اليسار
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
              'قطف أرض زراعية ',
              textAlign: TextAlign.right,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.center, // لجعل شريط البحث في المنتصف
                child: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // تقليل العرض ليصبح 80% من عرض الشاشة
                  child: TextField(
                    textDirection: TextDirection.rtl, // تعيين اتجاه النص
                    textAlign: TextAlign.right, // محاذاة النص لليمين
                    decoration: InputDecoration(
                      hintText:
                          'البحث باستخدام اسم المدينة أو نوع المحصول', // النص الداخلي لشريط البحث
                      prefixIcon: const Icon(Icons.search,
                          color: Color.fromARGB(255, 12, 123, 17)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // باقي محتوى الصفحة هنا
          ],
        ),
        //endDrawer: const CustomDrawer(), // استخدام الـ CustomDrawer هنا
      ),
    );
  }
}
