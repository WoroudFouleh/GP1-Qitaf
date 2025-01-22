import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:login_page/screens/custom_drawer.dart';
import 'package:login_page/screens/product.dart';
import 'package:login_page/screens/production_line.dart';
import 'package:login_page/screens/qataf.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/config.dart';

class OwnerHome extends StatefulWidget {
  final String token;
  final String userId;
  const OwnerHome({required this.token, Key? key, required this.userId})
      : super(key: key);

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
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
            color: Color.fromRGBO(15, 99, 43, 1),
          ),
          titleTextStyle: const TextStyle(
            color: Color.fromRGBO(15, 99, 43, 1),
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
        endDrawer: CustomDrawer(
            token: widget.token,
            userId: widget.userId), // استخدام الـ CustomDrawer هنا

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
                    color: Color.fromRGBO(15, 99, 43, 1), // اللون الأخضر
                  ),
                  textAlign: TextAlign.center, // محاذاة النص إلى المنتصف
                ),
                const SizedBox(height: 20),
                // إضافة حواف دائرية لصور السلايدر
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : advertisements.isEmpty
                        ? const Text(
                            'لا توجد إعلانات متاحة حاليًا.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: SizedBox(
                              height: 230,
                              width: double.infinity,
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
                                dotSize: 3,
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
    AssetImage imageAsset, // تحديث هنا لقبول AssetImage
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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
                child: Image(
                  image: imageAsset,
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
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Icon(
                  Icons.arrow_forward_ios, // السهم باتجاه اليمين
                  color:
                      Color.fromRGBO(15, 99, 43, 1), // تغيير اللون إلى الأخضر
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
