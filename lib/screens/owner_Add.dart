import 'package:flutter/material.dart';
import 'package:login_page/screens/addLand.dart';
import 'package:login_page/screens/addProduct.dart';
import 'package:login_page/screens/addProductionLine.dart';
import 'package:login_page/screens/custom_drawer.dart';

class OwnerAdd extends StatefulWidget {
  final token;
  const OwnerAdd({@required this.token, Key? key}) : super(key: key);

  @override
  State<OwnerAdd> createState() => _OwnerAddState();
}

class _OwnerAddState extends State<OwnerAdd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(
          color: const Color.fromRGBO(15, 99, 43, 1), // لون الأيقونات
        ),
        titleTextStyle: const TextStyle(
          color: const Color.fromRGBO(15, 99, 43, 1), // لون العنوان
          fontWeight: FontWeight.bold, // جعل العنوان غامق
          fontSize: 24,
          fontFamily: 'CustomArabicFont', // تكبير حجم الخط
        ),
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            '  إضافة عنصر جديد',
            textAlign: TextAlign.right, // محاذاة النص لليمين
          ),
        ),
      ),
      endDrawer: CustomDrawer(
        token: widget.token,
      ), // استخدام الـ CustomDrawer هنا

      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/add1.png'), // تأكد من توفير الصورة في المسار الصحيح
                fit: BoxFit.cover, // لجعل الصورة تغطي كامل الصفحة
              ),
            ),
          ),
          // المحتويات
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20.0),
                // الزر الأول
                SizedBox(
                  width: 300, // تحديد عرض ثابت لكل الأزرار
                  height: 60, // تحديد ارتفاع ثابت للأزرار لجعلها مستطيلة
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddLand(token: widget.token)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // لون الخلفية الأبيض
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // زوايا مستديرة
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // محاذاة الوسط
                      children: [
                        Text(
                          'إضافة أرض زراعية للقطف',
                          style: TextStyle(
                            fontSize: 20, // حجم النص في الأزرار
                            fontWeight: FontWeight.bold, // جعل النص غامق
                            color: const Color.fromRGBO(
                                15, 99, 43, 1), // لون النص أخضر
                          ),
                        ),
                        SizedBox(width: 10), // مسافة بين النص والأيقونة
                        Icon(
                          Icons.landscape, // أيقونة تدل على أرض زراعية
                          color: const Color.fromRGBO(
                              15, 99, 43, 1), // لون الأيقونة أخضر
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15.0), // تقليل المسافة بين الأزرار
                // الزر الثاني
                SizedBox(
                  width: 300, // تحديد عرض ثابت لكل الأزرار
                  height: 60, // تحديد ارتفاع ثابت للأزرار لجعلها مستطيلة
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AddProduct(token: widget.token)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // لون الخلفية الأبيض
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // زوايا مستديرة
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // محاذاة الوسط
                      children: [
                        Text(
                          'إضافة منتج زراعي',
                          style: TextStyle(
                            fontSize: 20, // حجم النص في الأزرار
                            fontWeight: FontWeight.bold, // جعل النص غامق
                            color: Colors.green, // لون النص أخضر
                          ),
                        ),
                        SizedBox(width: 10), // مسافة بين النص والأيقونة
                        Icon(
                          Icons.grass, // أيقونة تدل على منتج زراعي
                          color: const Color.fromRGBO(
                              15, 99, 43, 1), // لون الأيقونة أخضر
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15.0), // تقليل المسافة بين الأزرار
                // الزر الثالث
                SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AddProductionLine(token: widget.token)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'إضافة خط انتاج',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(15, 99, 43, 1),
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.factory,
                          color: const Color.fromRGBO(15, 99, 43, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
