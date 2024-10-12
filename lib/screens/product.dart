import 'package:flutter/material.dart';
import 'package:login_page/screens/custom_drawer.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

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
                'قطف أرض زراعية',
                textAlign: TextAlign.right,
              ),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'الكل'),
                Tab(text: 'محاصيل'),
                Tab(text: 'منتج غذائي'),
                Tab(text: 'منتج غير غذائي'),
              ],
              indicatorColor: Color.fromARGB(255, 12, 123, 17), // لون المؤشر
              labelColor: Color.fromARGB(255, 12, 123, 17), // لون النص المحدد
              unselectedLabelColor: Colors.grey, // لون النص غير المحدد
              labelStyle: TextStyle(fontWeight: FontWeight.bold), // نمط النص
            ),
          ),
          //endDrawer: const CustomDrawer(), // استخدام الـ CustomDrawer هنا

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
                            'البحث باستخدام اسم المنتج', // النص الداخلي لشريط البحث
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
              const SizedBox(
                  height: 8.0), // إضافة مسافة بين شريط البحث والتبويبات
              const Expanded(
                child: TabBarView(
                  children: [
                    Center(
                        child: Text(' جميع المنتجات ')), // محتوى تبويب "الكل"
                    Center(child: Text(' المحاصيل ')), // محتوى تبويب "محاصيل"
                    Center(
                        child: Text(
                            ' المنتجات الغذائية ')), // محتوى تبويب "منتج غذائي"
                    Center(
                        child: Text(
                            ' المنتجات غير الغذائية ')), // محتوى تبويب "منتج غير غذائي"
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
