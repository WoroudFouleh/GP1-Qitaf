import 'package:flutter/material.dart';
import 'package:login_page/screens/LinePage.dart';
import 'package:login_page/screens/custom_drawer.dart';
import 'package:login_page/widgets/DealWidget.dart';
import 'package:login_page/screens/LandPage.dart'; // تأكد من إضافة LandPage هنا
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';

import 'package:jwt_decoder/jwt_decoder.dart';

class ProductionLinesPage extends StatefulWidget {
  final String token;
  final String userId;
  const ProductionLinesPage(
      {required this.token, super.key, required this.userId});

  @override
  State<ProductionLinesPage> createState() => _ProductionLinesPageState();
}

class _ProductionLinesPageState extends State<ProductionLinesPage> {
  List<dynamic> lines = [];
  late String username;
  late String ownerUsername = "";
  late String firstName = "";
  late String lastName = "";
  String userProfileImage = "";
  late String phoneNum = "";
  late String code = "";
  late String email = "";
  late String city = "";
  late String location = "";
  String searchQuery = '';
  String searchCategory = 'crop';
  late int postsCount = 0;
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No username';
    fetchLines(); // Call the fetch function when the page is loaded
  }

  void fetchLines() async {
    final response = await http.get(
      Uri.parse('$getProductutionLines/$username'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          lines = data['lines']; // Update the lands list with the response data
        });
      } else {
        print("Error fetching lines: ${data['message']}");
      }
    } else {
      print("Failed to load lines: ${response.statusCode}");
    }
  }

  void fetchUser(String username) async {
    print("Sending username: $username");

    try {
      final response = await http.get(
        Uri.parse('$getUser/$username'), // Send the URL without the username
        headers: {'Content-Type': 'application/json'},
        // Send the username in the body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final userInfo = data['data'];
          //print("User info: $userInfo"); // Assuming the user info is in 'data'
          setState(() {
            ownerUsername = userInfo['username'];
            firstName = userInfo['firstName']; // Extract first name
            lastName = userInfo['lastName']; // Extract last name
            userProfileImage = userInfo['profilePhoto'];
            // Extract profile photo URL
            phoneNum = userInfo['phoneNumber'];
            email = userInfo['email'];
            code = userInfo['phoneCode'];
            city = userInfo['city'];
            location = userInfo['street'];
            postsCount = userInfo['postNumber'];
          });
        } else {
          print("Error fetching items: ${data['message']}");
        }
      } else {
        print("Failed to load items: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void searchLines() async {
    final response = await http.get(
      Uri.parse(
          '$getProductutionLines/$username?search=$searchQuery&category=$searchCategory'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          lines = data['lines']; // Update the lands list with the search result
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
            color:
                const Color.fromRGBO(15, 99, 43, 1), // Olive green text color
          ),
          titleTextStyle: const TextStyle(
              color:
                  const Color.fromRGBO(15, 99, 43, 1), // Olive green text color
              fontWeight: FontWeight.bold, // جعل النص بولد
              fontSize: 24, // زيادة حجم النص
              fontFamily: 'CustomArabicFont'),
          elevation: 0,
          title: const Align(
            alignment: Alignment.centerRight,
            child: Text(
              ' خطوط الإنتاج ',
              textAlign: TextAlign.right,
            ),
          ),
        ),
        //endDrawer: const CustomDrawer(), // استخدام الـ CustomDrawer هنا

        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.center, // لجعل شريط البحث في المنتصف
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: searchCategory,
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(
                              color: const Color.fromRGBO(15, 99, 43, 1)),
                          underline: Container(
                            height: 2,
                            color: const Color.fromRGBO(15, 99, 43, 1),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              searchCategory = newValue!;
                              searchQuery =
                                  ''; // Clear the previous query when changing category
                            });
                          },
                          items: <String>['name', 'crop', 'location']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value == 'name'
                                    ? 'الاسم'
                                    : value == 'crop'
                                        ? 'نوع المادة الخام'
                                        : 'الموقع',
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            width: 400, // Adjust the width as needed
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255,
                                  255), // Background color of the TextField
                              borderRadius:
                                  BorderRadius.circular(8.0), // Rounded corners
                            ),
                            child: TextField(
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              onChanged: (text) {
                                setState(() {
                                  searchQuery = text;
                                });
                              },
                              onSubmitted: (text) {
                                setState(() {
                                  searchQuery =
                                      text; // Update the search query with the entered text
                                });
                                searchLines(); // Trigger the search function
                              },
                              decoration: InputDecoration(
                                hintText: searchCategory == 'name'
                                    ? 'ابحث عن الاسم'
                                    : searchCategory == 'crop'
                                        ? 'ابحث حسب المادة الخام'
                                        : 'ابحث عن الموقع',
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: const Color.fromRGBO(15, 99, 43, 1),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(right: 10, bottom: 10),
                child: const Text(
                  "خطوط الإنتاج المتوفرة",
                  style: TextStyle(
                    fontSize: 20, // حجم النص كما هو
                    fontWeight: FontWeight.bold, // جعل النص بولد
                    color: const Color.fromRGBO(
                        15, 99, 43, 1), // Olive green text color
                  ),
                ),
              ),

              // إضافة RecipeCard هنا مع صور من assets
              ...lines.map((line) {
                fetchUser(line['ownerUsername']);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LinePage(
                          userId: widget.userId,
                          token: widget.token,
                          lineName: line['lineName'],
                          image: line['image'],
                          ownerUsername: line['ownerUsername'],
                          cropType: line['materialType'],
                          lineId: line['_id'],
                          description: line['description'],
                          preparationTime: line['timeOfPreparation'],
                          city: line['city'],
                          location: line['location'],
                          days: List<String>.from(line['datesOfWork']),
                          preparationUnit: line['unitTimeOfPreparation'],
                          startTime: line['startWorkTime'],
                          endTime: line['endWorkTime'],
                          lineRate: (line['rate'] as num).toDouble(),
                          price: line['price'],
                          quantityUnit: line['quantityUnit'],
                          coordinates: line['coordinates'] != null
                              ? {
                                  'lat': line['coordinates']['lat'],
                                  'lng': line['coordinates']['lng']
                                }
                              : {
                                  'lat': 0.0,
                                  'lng': 0.0
                                }, // يمكنك وضع قيم افتراضية مثل 0.0 في حال كانت null
                        ),
                      ),
                    );
                  },
                  child: RecipeCard(
                    title: line['lineName'] ?? "اسم غير متوفر",
                    workernum: "${line['timeOfPreparation']} ساعة",
                    crops: line['materialType'] ?? "محاصيل غير متوفرة",
                    city: line['city'] ?? "مدينة غير متوفرة",
                    thumbnailUrl: line['image'] ?? '',
                  ),
                );
              }).toList(),

              // يمكنك إضافة المزيد حسب الحاجة
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String title;
  final String city;
  final String workernum;
  final String crops;
  final String thumbnailUrl;

  const RecipeCard({
    super.key,
    required this.title,
    required this.workernum,
    required this.city,
    required this.crops,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      // لضمان تمركز الـ Container في وسط الصفحة
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 30, vertical: 20), // تعديل المارجين لتناسب شاشات الويب
        width: MediaQuery.of(context).size.width *
            0.9, // جعل العرض 90% من عرض الشاشة لظهور العناصر بشكل جيد
        height: MediaQuery.of(context).size.height *
            0.4, // زيادة الارتفاع بنسبة 40% من ارتفاع الشاشة لتظهر الصورة بشكل أكبر
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(
              20), // زيادة نصف القطر لجعل الحواف أكثر استدارة
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(0.0, 15.0), // تعديل الإزاحة لتناسب الويب
              blurRadius: 15.0, // زيادة التمويه للظل
              spreadRadius: -8.0,
            ),
          ],
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black
                  .withOpacity(0.5), // تقليل الشفافية لتكون الصورة أكثر وضوحًا
              BlendMode.multiply,
            ),
            image: MemoryImage(
                base64Decode(thumbnailUrl)), // إذا كانت الصورة بتنسيق base64
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24, // زيادة حجم النص
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2, // تحديد الحد الأقصى لعدد الأسطر
                  textAlign: TextAlign.center, // محاذاة النص في المنتصف
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft, // محاذاة العنصر إلى أقصى اليسار
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0), // إضافة بعض الهوامش من الأسفل
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // محاذاة العناصر في اليسار
                  children: [
                    _buildInfoContainer(
                        Icons.location_city, city, 22), // العنصر في أقصى اليسار
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter, // محاذاة العنصر في المنتصف
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // محاذاة العناصر في المنتصف
                  children: [
                    _buildInfoContainer(
                        Icons.access_time, workernum, 22), // العنصر في المنتصف
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight, // محاذاة العنصر إلى أقصى اليمين
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // محاذاة العناصر في اليمين
                  children: [
                    _buildInfoContainer(
                        Icons.apple, crops, 20), // العنصر في أقصى اليمين
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// دالة مساعدة لبناء العناصر المكررة
  Widget _buildInfoContainer(IconData icon, String text, double iconSize) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 246, 246).withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.yellow,
            size: iconSize, // تحديد حجم الأيقونة
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18, // حجم النص
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
