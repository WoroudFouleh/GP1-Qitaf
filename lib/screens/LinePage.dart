import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:login_page/screens/map2.dart';
import 'package:login_page/screens/profile2.dart';
import 'package:login_page/widgets/ItemAppBar.dart';
import 'package:login_page/widgets/ItemBottonBar.dart';
import 'package:login_page/widgets/LandAppBar.dart';
import 'package:login_page/widgets/LandBottonBar.dart';
import 'package:login_page/widgets/LineAppBar.dart';
import 'package:login_page/widgets/LineBottonBar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LinePage extends StatefulWidget {
  final String userId;
  final String lineName;
  final String lineId;
  final double lineRate;
  final String image;
  final String description;
  final String preparationTime;
  final String preparationUnit;
  final String city;
  final String location;
  final String cropType;
  final int price;
  final String quantityUnit;
  final List<String> days;
  final String startTime;
  final String endTime;
  final String token;

  final Map<String, double> coordinates;
  final String ownerUsername;

  const LinePage(
      {super.key,
      required this.lineName,
      required this.lineId,
      required this.ownerUsername,
      required this.image,
      required this.description,
      required this.preparationTime,
      required this.preparationUnit,
      required this.city,
      required this.cropType,
      required this.days,
      required this.startTime,
      required this.endTime,
      required this.token,
      required this.location,
      required this.lineRate,
      required this.price,
      required this.quantityUnit,
      required this.coordinates, required this.userId});

  @override
  State<LinePage> createState() => _LinePageState();
}

class _LinePageState extends State<LinePage> {
  int quantity = 1; // الكمية الحالية، جعلها 1 كما طلبت
  bool isFavorite = false; // حالة الأيقونة المفضلة

  late String firstName = "";
  late String lastName = "";
  late String userProfileImage = "";
  late String phoneNum = "";
  late String code = "";
  late String email = "";
  late String city = "";
  late String location = "";
  late int postsCount = 0; // قيمة التقييم الافتراضية (نجمة 4)

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    print("Sending username: ${widget.ownerUsername}");

    try {
      final response = await http.get(
        Uri.parse(
            '$getUser/${widget.ownerUsername}'), // Send the URL without the username
        headers: {'Content-Type': 'application/json'},
        // Send the username in the body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final userInfo = data['data'];
          //print("User info: $userInfo"); // Assuming the user info is in 'data'
          setState(() {
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

  void _showCoordinatesOnMap() {
    // Parse the input from _inputCoordController
    //final input = widget.coordinates.text.split(',');
    //if (input.length == 2) {
    try {
      print("here1");

      final latitude = widget.coordinates['lat']!;
      print("here2");
      final longitude = widget.coordinates['lng']!;
      print('Latitude: ${widget.coordinates['lat']}');
      print('Longitude: ${widget.coordinates['lng']}');

      final coordinates = LatLng(latitude, longitude);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              MapScreen2(initialLocation: coordinates, name: widget.location),
        ),
      );
    } catch (e) {
      // Show an error message if parsing fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid coordinates format')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // لون الخلفية أبيض
      body: ListView(
        children: [
          const LineAppBar(),
          Padding(
              padding: const EdgeInsets.all(16),
              child: Image.memory(
                base64Decode(widget.image),
                fit: BoxFit.fill,
                width: double.infinity,
                height: 250,
              )),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5), // لمعان بسيط
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3), // تحريك الظل لتمييز الصندوق
                ),
              ],
              borderRadius: BorderRadius.circular(15), // لتحديد الحواف
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // صورة المالك واسم خط الإنتاج
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // محاذاة العناصر إلى اليمين
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .end, // محاذاة النصوص إلى اليمين
                          children: [
                            Directionality(
                              textDirection:
                                  TextDirection.rtl, // تحديد اتجاه النص
                              child: Text(
                                '${firstName} ${lastName}', // اسم خط الإنتاج
                                style: const TextStyle(
                                  fontSize: 20, // تكبير الخط
                                  fontWeight: FontWeight.bold, // خط عريض
                                  color: Color(0xFF556B2F), // لون زيتي
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 3,
                                      color: Color.fromARGB(
                                          255, 120, 183, 72), // لون اللمعان
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              widget.ownerUsername,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            // Navigate to the Profile2 page when the profile photo is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Profile2(
                                  userId: widget.userId,
                                  token: widget.token,
                                  phoneNum: phoneNum,
                                  code: code,
                                  city: city,
                                  street: location,
                                  firstName: firstName,
                                  lastName: lastName,
                                  image: userProfileImage,
                                  email: email,
                                  postsCount: postsCount,
                                ), // Replace Profile2Page with the actual name of your Profile2 page
                              ),
                            );
                          },
                          child: ClipOval(
                              child: Image.memory(
                            base64Decode(userProfileImage),
                            fit: BoxFit.cover,
                            width: 50.0,
                            height: 50.0,
                          )),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // محاذاة النصوص إلى اليسار
                          children: [
                            Directionality(
                              textDirection:
                                  TextDirection.rtl, // تحديد اتجاه النص
                              child: Text(
                                widget.lineName, // اسم خط الإنتاج
                                style: const TextStyle(
                                  fontSize: 19, // تكبير الخط
                                  fontWeight: FontWeight.bold, // خط عريض
                                  color: Color(0xFF556B2F), // لون زيتي
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 3,
                                      color: Color.fromARGB(
                                          255, 129, 179, 79), // لون اللمعان
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // وضع النجوم في الجهة اليمنى
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: RatingBar.builder(
                            initialRating: widget.lineRate,
                            minRating: 1,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 2),
                            itemSize: 30,
                            allowHalfRating: false, // Disable half-star ratings
                            ignoreGestures: true,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: const Color(0xFFFFD700),
                              shadows: [
                                Shadow(
                                  blurRadius: 15.0,
                                  color: Colors.yellowAccent.withOpacity(0.8),
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            onRatingUpdate: (index) {},
                          ),
                        ),
                      ],
                    ),
                  ),

                  // إضافة فقرة وصف خط الإنتاج
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  // معلومات عدد ساعات جهوزية الطلب
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // محاذاة العناصر إلى اليمين
                      children: [
                        Text(
                          "عدد ساعات جهوزية الطلب: ${widget.preparationTime} ${widget.preparationUnit}  ", // ساعات الجهوزية
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.access_time, color: Color(0xFF556B2F)),
                      ],
                    ),
                  ),
                  // المدينة والموقع مع أيقونة الموقع
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showCoordinatesOnMap();
                              },
                              child: Text(
                                widget.location, // الموقع
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  decoration: TextDecoration
                                      .underline, // Add underline for emphasis
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              ",", // الفاصلة
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.city, // المدينة
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.location_on,
                                color: Color(0xFF556B2F)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '                               ${widget.cropType}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.apple, color: Color(0xFF556B2F)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // أيام الأسبوع مع أيقونة التقويم
                  // أيام الأسبوع مع أيقونة التقويم
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // محاذاة العناصر إلى اليمين
                      children: [
                        Flexible(
                          child: Text(
                            "أيام العمل: ${widget.days.join('، ')}", // عرض الأيام المفصولة بفاصلة
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign:
                                TextAlign.right, // محاذاة النص إلى اليمين
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.calendar_today,
                            color: Color(0xFF556B2F)),
                      ],
                    ),
                  ),

                  // وقت الدوام مع أيقونة الساعة
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // محاذاة العناصر إلى اليمين
                      children: [
                        Text(
                          "وقت الدوام: ${widget.startTime.toString().substring(10, 15)} - ${widget.endTime.toString().substring(10, 15)} ", // وقت الدوام
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.access_time, color: Color(0xFF556B2F)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          LineBottonBar(
              price: widget.price,
              quantityUnit: widget.quantityUnit,
              lineName: widget.lineName,
              lineId: widget.lineId,
              lineRate: widget.lineRate,
              location: widget.location,
              city: widget.city,
              cropType: widget.cropType,
              startTime: widget.startTime,
              endTime: widget.endTime,
              days: widget.days,
              description: widget.description,
              preparationTime: widget.preparationTime,
              preparationUnit: widget.preparationUnit,
              image: widget.image,
              token: widget.token,
              ownerUsername: widget.ownerUsername),
        ],
      ),
    );
  }
}
