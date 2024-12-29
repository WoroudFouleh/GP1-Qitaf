import 'dart:convert';

import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:login_page/Customers/CustomerDrawer2.dart';
import 'package:login_page/screens/config.dart';
import 'package:http/http.dart' as http;

import 'package:login_page/screens/product.dart';
import 'package:login_page/screens/production_line.dart';
import 'package:login_page/screens/qataf.dart';

class CustomerHome extends StatefulWidget {
  final String token;
  final String userId;
  const CustomerHome({required this.token, Key? key, required this.userId})
      : super(key: key);

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int currentSlider = 0;
  int selectedIndex = 0;
  List<dynamic> advertisements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdvertisements(); // Fetch ads when the widget initializes
  }

  Future<void> fetchAdvertisements() async {
    final response = await http.get(
      Uri.parse(getMainAds),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          advertisements = data['ads'];
          isLoading = false; // Update the lands list with the response data
        });
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

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
            fontSize: 24, // حجم أكبر للعناوين
            fontFamily: 'CustomArabicFont',
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
            CustomDrawer2(token: widget.token), // استخدام الـ CustomDrawer هنا
        body: Padding(
          padding: const EdgeInsets.all(24.0), // زيادة التباعد لتناسب التصميم
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // النص الترحيبي
                const Text(
                  'أهلاً بك في تطبيق قطاف!',
                  style: TextStyle(
                    fontSize: 24, // حجم خط أكبر لصفحة ويب
                    fontWeight: FontWeight.bold, // سماكة الخط
                    color: Color.fromARGB(255, 12, 123, 17), // اللون الأخضر
                  ),
                  textAlign: TextAlign.center, // محاذاة النص إلى المنتصف
                ),
                const SizedBox(height: 30),
                // السلايدر
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : advertisements.isEmpty
                        ? const Text(
                            'لا توجد إعلانات متاحة حاليًا.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: SizedBox(
                              height: 400, // ارتفاع أكبر ليتناسب مع عرض الصفحة
                              width: 600, // عرض متوسط مناسب لصفحة ويب
                              child: AnotherCarousel(
                                images: advertisements.map((ad) {
                                  if (ad['image'] != null) {
                                    try {
                                      return MemoryImage(
                                          base64Decode(ad['image']));
                                    } catch (e) {
                                      print('Error decoding image: $e');
                                    }
                                  }
                                  return const AssetImage(
                                      'assets/images/placeholder.jpg');
                                }).toList(),
                                dotSize:
                                    5, // زيادة حجم النقاط قليلاً لتكون واضحة
                                indicatorBgPadding:
                                    8.0, // تعديل المسافات بين النقاط
                              ),
                            ),
                          ),
                const SizedBox(height: 30),
                // النص فوق القائمة
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    ':قم باختيار القائمة التي تريدها', // النص المطلوب
                    style: TextStyle(
                      fontSize: 18, // خط أكبر قليلاً
                      color: Color.fromARGB(255, 58, 58, 58), // اللون الرمادي
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // القائمة
                buildCustomListItem(
                  'قطف أراضي زراعية',
                  'فرص عمل بقطف أراضي زراعية',
                  const AssetImage('assets/images/lands.jpg'),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QatafPage(
                            token: widget.token, userId: widget.userId),
                      ),
                    );
                  },
                ),
                buildCustomListItem(
                  'منتجات زراعية',
                  'شراء منتجات زراعية بأنواعها',
                  const AssetImage('assets/images/products1.jpg'),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsPage(
                            token: widget.token, userId: widget.userId),
                      ),
                    );
                  },
                ),
                buildCustomListItem(
                  'خطوط إنتاج',
                  'عرض خطوط الانتاج المتاحة',
                  const AssetImage('assets/images/lines.jpg'),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductionLinesPage(
                            token: widget.token, userId: widget.userId),
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
    AssetImage imageAsset, // لقبول AssetImage
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Container(
          height: 150, // زيادة الارتفاع ليناسب صفحات الويب
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25), // زوايا دائرية أكبر
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 158, 158, 158).withOpacity(0.6),
                spreadRadius: 3,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // صورة دائرية على اليمين بحجم أكبر
              ClipOval(
                child: Image(
                  image: imageAsset,
                  height: 140, // زيادة ارتفاع الصورة
                  width: 140, // زيادة عرض الصورة
                  fit: BoxFit.cover,
                ),
              ),
              // Expanded للنصوص لتجنب تجاوز المساحة
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18, // حجم خط أكبر للويب
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 16, // خط أكبر للنصوص الثانوية
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Icon(
                  Icons.arrow_forward_ios, // السهم باتجاه اليمين
                  color: Colors.green, // تغيير اللون إلى الأخضر
                  size: 24, // زيادة حجم الأيقونة قليلاً
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
