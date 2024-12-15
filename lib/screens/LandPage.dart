import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:login_page/screens/profile2.dart';
import 'package:login_page/widgets/ItemAppBar.dart';
import 'package:login_page/widgets/ItemBottonBar.dart';
import 'package:login_page/widgets/LandAppBar.dart';
import 'package:login_page/widgets/LandBottonBar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LandPage extends StatefulWidget {
  final String userId;
  final String landName;
  final String landId;
  final String username;
  final String image;
  final String cropType;
  final int workerWages;
  final int landSpace;
  final int numOfWorkers;
  final String city;
  final String location;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String token;

  const LandPage(
      {Key? key,
      required this.city,
      required this.landName,
      required this.landSpace,
      required this.location,
      required this.startDate,
      required this.startTime,
      required this.endDate,
      required this.endTime,
      required this.username,
      required this.cropType,
      required this.image,
      required this.numOfWorkers,
      required this.workerWages,
      required this.token,
      required this.landId,
      required this.userId})
      : super(key: key);

  @override
  State<LandPage> createState() => _LandPageState();
}

class _LandPageState extends State<LandPage> {
  int quantity = 1; // الكمية الحالية، جعلها 1 كما طلبت
  bool isFavorite = false;

  late String firstName = "";
  late String lastName = "";
  late String userProfileImage = "";
  late String phoneNum = "";
  late String code = "";
  late String email = "";
  late String city = "";
  late String location = "";
  late int postsCount = 0;
  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    print("Sending username: ${widget.username}");

    try {
      final response = await http.get(
        Uri.parse(
            '$getUser/${widget.username}'), // Send the URL without the username
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
  // حالة الأيقونة المفضلة

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // لون الخلفية أبيض
      body: ListView(
        children: [
          const LandAppBar(),
          Padding(
              padding: const EdgeInsets.all(16),
              child: Image.memory(
                base64Decode(widget.image),
                fit: BoxFit.fill,
                width: double.infinity,
                height: 300,
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  // صورة المالك واسم الأرض الزراعية
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Directionality(
                              textDirection:
                                  TextDirection.rtl, // تحديد اتجاه النص
                              child: Text(
                                '$firstName $lastName', // اسم المالك
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
                              widget.username,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
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
                            child: userProfileImage != null
                                ? Image.memory(
                                    base64Decode(userProfileImage),
                                    fit: BoxFit.cover,
                                    width: 50.0,
                                    height: 50.0,
                                  )
                                : Image.asset(
                                    'assets/images/profile.png',
                                    fit: BoxFit.fill,
                                    width: 50.0,
                                    height: 50.0,
                                  ),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Directionality(
                              textDirection:
                                  TextDirection.rtl, // تحديد اتجاه النص
                              child: Text(
                                widget.landName, // اسم الأرض الزراعية
                                style: const TextStyle(
                                  fontSize: 20, // تكبير الخط
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
                  // معلومات المحصول والموقع
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.location, // الموقع
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
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

                  // معلومات المساحة وعدد العمال
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.numOfWorkers.toString(), // الرقم 5
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const Text(
                              ":عدد العمال", // النص "عدد العمال"
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.group, color: Color(0xFF556B2F)),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "           دونم", // النص "دونم"
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              " ${widget.landSpace.toString()} ", // الرقم 10
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const Text(
                              ":المساحة", // النص "المساحة"
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.landscape,
                                color: Color(0xFF556B2F)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // معلومات تاريخ بداية ونهاية العمل
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              " أيام العمل : (${widget.startDate.toString().substring(0, 10)}) - (${widget.endDate.toString().substring(0, 10)}) ", // النص "نهاية العمل"
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.calendar_today,
                                color: Color(0xFF556B2F)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // معلومات ساعة بدء وانتهاء الدوام
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              "   ${widget.endTime} - ${widget.startTime} :أوقات العمل", // النص "انتهاء الدوام"
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.access_time,
                                color: Color(0xFF556B2F)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // إضافة المعلومات الأخرى أو الأزرار
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          LandBottonBar(
            token: widget.token,
            ownerUserName: widget.username,
            workersWages: widget.workerWages,
            numOfWorkers: widget.numOfWorkers,
            landLocation: widget.city,
            landName: widget.landName,
            landId: widget.landId,
          ),
        ],
      ),
    );
  }
}
