import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:login_page/screens/map2.dart';
import 'package:login_page/screens/profile2.dart';

import 'package:login_page/widgets/LandAppBar.dart';
import 'package:login_page/widgets/LandBottonBar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';

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

  final Map<String, double> coordinates;

  const LandPage({
    super.key,
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
    required this.coordinates,
    required this.userId,
  });

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
  late String gender = "";
  late String ownerFCM = "";
  late String ownerID = "";
  late double rate;
  ////////////////
  late String workerfirstName = "";
  late String workerlastName = "";
  late String workeruserProfileImage = "";
  late String workerphoneNum = "";
  late String workercode = "";
  late String workeremail = "";
  late String workercity = "";
  late String workerlocation = "";
  late String workerusername;
  late String workergender = "";

  late double workerrate;
  @override
  void initState() {
    super.initState();
    fetchFcmOwner();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    workercode = jwtDecoderToken['phoneCode'];
    workerphoneNum = jwtDecoderToken['phoneNumber'];
    workerfirstName = jwtDecoderToken['firstName'];
    workerlastName = jwtDecoderToken['lastName'];
    workercity = jwtDecoderToken['city'];
    workerlocation = jwtDecoderToken['street'];
    workeremail = jwtDecoderToken['email'];
    workerrate = jwtDecoderToken['rate'];
    workergender = jwtDecoderToken['gender'];
    workerusername = jwtDecoderToken['username'];
    workeruserProfileImage =
        jwtDecoderToken['profilePhoto']; // Get the base64 image string

    fetchUser();
  }

  Future<void> fetchFcmOwner() async {
    try {
      print("on fetch");
      // Query Firestore for a user with the same email as the owner
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        setState(() {
          ownerFCM = userDoc['fcmToken'] ?? "";
          ownerID = userDoc.id; // Get the FCM token
        });
        print("Customer's FCM token: $ownerFCM");
        print("Customer's document ID: $ownerID");
        // Send the notification
      } else {
        print("No user found with the email: $email");
      }
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
  }

  void fetchUser() async {
    //////////owner
    try {
      final response = await http.get(
        Uri.parse('$getUser/${widget.username}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final userInfo = data['data'];
          if (mounted) {
            setState(() {
              firstName = userInfo['firstName'];
              lastName = userInfo['lastName'];
              userProfileImage = userInfo['profilePhoto'];
              phoneNum = userInfo['phoneNumber'];
              email = userInfo['email'];
              code = userInfo['phoneCode'];
              city = userInfo['city'];
              location = userInfo['street'];
              postsCount = userInfo['postNumber'];
              gender = userInfo['gender'];
              rate = userInfo['rate'];
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  // حالة الأيقونة المفضلة
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
          const LandAppBar(),
          Padding(
              padding: const EdgeInsets.all(16),
              child: Image.memory(
                base64Decode(widget.image),
                width: double.infinity,
                height: 300,
                fit: BoxFit.fill,
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
                                  color:
                                      Color.fromRGBO(15, 99, 43, 1), // لون زيتي
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 3,
                                      color: Color.fromRGBO(
                                          15, 99, 43, 1), // لون اللمعان
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
                        const SizedBox(width: 3),
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
                                  color:
                                      Color.fromRGBO(15, 99, 43, 1), // لون زيتي
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
                            GestureDetector(
                              onTap: () {
                                // final coordinates = LatLng(
                                //   widget.coordinates['latitude']!,
                                //   widget.coordinates['longitude']!,
                                // );

                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => MapScreen2(
                                //       initialLocation: coordinates,
                                //     ),
                                //   ),
                                // );
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
                            const SizedBox(width: 5),
                            const Icon(Icons.location_on,
                                color: Color.fromRGBO(15, 99, 43, 1)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '                          ${widget.cropType}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.apple,
                                color: Color.fromRGBO(15, 99, 43, 1)),
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
                            const Icon(Icons.group,
                                color: Color.fromRGBO(15, 99, 43, 1)),
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
                            const SizedBox(width: 5),
                            const Icon(Icons.landscape,
                                color: Color.fromRGBO(15, 99, 43, 1)),
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
                            const SizedBox(width: 5),
                            const Icon(Icons.calendar_today,
                                color: Color.fromRGBO(15, 99, 43, 1)),
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
                                color: Color.fromRGBO(15, 99, 43, 1)),
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
            workerFirstname: workerfirstName,
            workerLastname: workerlastName,
            workerCity: workercity,
            workerGender: workergender,
            workerProfileImage: workeruserProfileImage,
            workerUserName: workerusername,
            ownerFcmToken: ownerFCM,
            ownerId: ownerID,
            userRate: workerrate,
          ),
        ],
      ),
    );
  }
}
