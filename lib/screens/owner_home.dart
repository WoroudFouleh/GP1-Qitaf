import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:login_page/screens/custom_drawer.dart';
import 'package:login_page/screens/product.dart';
import 'package:login_page/screens/production_line.dart';
import 'package:login_page/screens/qataf.dart';

class OwnerHome extends StatefulWidget {
  final String token;
  const OwnerHome({required this.token, Key? key}) : super(key: key);

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  int currentSlider = 0;
  int selectedIndex = 0;

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
              'الصفحة الرئيسية',
              textAlign: TextAlign.right,
            ),
          ),
        ),
        endDrawer:
            CustomDrawer(token: widget.token), // استخدام الـ CustomDrawer هنا

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // إضافة النص المطلوب قبل السلايدر
                const Text(
                  'أهلاً بك في تطبيق قطاف!',
                  style: TextStyle(
                    fontSize: 20, // حجم الخط
                    fontWeight: FontWeight.bold, // سماكة الخط
                    color: Color.fromARGB(255, 12, 123, 17), // اللون الأخضر
                  ),
                  textAlign: TextAlign.center, // محاذاة النص إلى المنتصف
                ),
                const SizedBox(height: 20),
                // إضافة حواف دائرية لصور السلايدر
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0), // زوايا دائرية
                  child: SizedBox(
                    height: 230,
                    width: double.infinity,
                    child: AnotherCarousel(
                      images: const [
                        AssetImage("assets/images/p1.jpg"),
                        AssetImage("assets/images/p3.jpg"),
                        AssetImage("assets/images/q1.jpg"),
                        AssetImage("assets/images/q2.jpg"),
                        AssetImage("assets/images/q3.jpg"),
                        AssetImage("assets/images/q4.jpg"),
                        AssetImage("assets/images/q5.jpg"),
                        AssetImage("assets/images/q8.jpg"),
                      ],
                      dotSize: 6,
                      indicatorBgPadding: 5.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // إضافة نص صغير فوق القائمة
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    ':قم باختيار القائمة التي تريدها', // النص المطلوب
                    style: TextStyle(
                      fontSize: 15, // حجم الخط الصغير
                      color: Color.fromARGB(255, 58, 58, 58), // اللون الرمادي
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // عرض القائمة بعد السلايدر
                buildCustomListItem(
                  'قطف أراضي زراعية',
                  'فرص عمل بقطف أراضي زراعية',
                  'https://i.pinimg.com/564x/97/29/4e/97294e473be6477598edccd2d417f702.jpg',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QatafPage(),
                      ),
                    );
                  },
                ),
                buildCustomListItem(
                  'منتجات زراعية',
                  'شراء منتجات زراعية بأنواعها',
                  'https://i.pinimg.com/564x/a9/50/a0/a950a06ec32eb6507f50352339a29465.jpg',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsPage(token: widget.token),
                      ),
                    );
                  },
                ),
                buildCustomListItem(
                  'خطوط إنتاج',
                  'عرض خطوط الانتاج المتاحة',
                  'https://i.pinimg.com/564x/4e/83/5c/4e835c3d3fc1f71dd672570782506666.jpg',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductionLinesPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCustomListItem(
    String title,
    String subtitle,
    String imageUrl,
    VoidCallback onTap, // إضافة onTap هنا لتمرير الدالة
  ) {
    return GestureDetector(
      onTap: onTap, // ربط التنقل عند الضغط على العنصر
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 158, 158, 158).withOpacity(0.6),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // صورة دائرية على اليمين
              ClipOval(
                child: Image.network(
                  imageUrl,
                  height: 90,
                  width: 90, // عرض ثابت للصورة لتجنب overflow
                  fit: BoxFit.cover,
                ),
              ),
              // Expanded للنصوص لتجنب تجاوز المساحة
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
              // السهم في اليسار ولونه أخضر واتجاهه لليمين
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Icon(
                  Icons.arrow_forward_ios, // السهم باتجاه اليمين
                  color: Colors.green, // تغيير اللون إلى الأخضر
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
