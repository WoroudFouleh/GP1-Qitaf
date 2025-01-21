import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/chat_screen.dart';

import 'config.dart';

class Workerprofile extends StatefulWidget {
  final String username;
  final String userId;

  const Workerprofile({required this.username, Key? key, required this.userId})
      : super(key: key);

  @override
  _WorkerprofileState createState() => _WorkerprofileState();
}

class _WorkerprofileState extends State<Workerprofile> {
  late String firstName = "";
  late String lastName = "";
  late String userProfileImage = "";
  late String phoneNum = "";
  late String code = "";
  late String email = "";
  late String city = "";
  late String location = "";
  late String gender = "";

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    print("Sending username: ${widget.username}");

    try {
      final response = await http.get(
        Uri.parse('$getUser/${widget.username}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final userInfo = data['data'];
          setState(() {
            firstName = userInfo['firstName'] ?? "";
            lastName = userInfo['lastName'] ?? "";
            userProfileImage = userInfo['profilePhoto'] ?? "";
            phoneNum = userInfo['phoneNumber'] ?? "";
            email = userInfo['email'] ?? "";
            code = userInfo['phoneCode'] ?? "";
            city = userInfo['city'] ?? "";
            location = userInfo['street'] ?? "";
            gender = userInfo['gender'] ?? 0;
          });
        } else {
          print("Error fetching user: ${data['message']}");
        }
      } else {
        print("Failed to load user: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> navigateToChat() async {
    try {
      // استعلام Firestore للحصول على userId بناءً على البريد الإلكتروني
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email) // البحث بالبريد الإلكتروني
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final otherUserId =
            querySnapshot.docs.first.id; // جلب ID المستخدم الآخر
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              currentUserId: widget.userId,
              otherUserId: otherUserId,
            ),
          ),
        );
      } else {
        // إذا لم يتم العثور على المستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('المستخدم غير موجود'),
          ),
        );
      }
    } catch (e) {
      // التعامل مع الأخطاء
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء جلب البيانات: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(150, 230, 150, 0.5),
                Color.fromRGBO(180, 255, 180, 1),
              ],
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 73),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'صفحة \nالعامل الشخصية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: height * 0.43,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double innerHeight = constraints.maxHeight;
                        double innerWidth = constraints.maxWidth;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: innerHeight * 0.72,
                                width: innerWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 80),
                                    Text(
                                      '$firstName $lastName',
                                      style: const TextStyle(
                                        color:
                                            const Color.fromRGBO(15, 99, 43, 1),
                                        fontSize: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              widget.username,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 15,
                                              ),
                                            ),
                                            const Divider(thickness: 1.5),
                                            GestureDetector(
                                              onTap: navigateToChat,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'دردشة مع العامل',
                                                    style: TextStyle(
                                                      color: Colors.grey[700],
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  const Icon(
                                                    AntDesign.message1,
                                                    color: const Color.fromRGBO(
                                                        15, 99, 43, 1),
                                                    size: 25,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: ClipOval(
                                  child: userProfileImage.isNotEmpty
                                      ? Image.memory(
                                          base64Decode(userProfileImage),
                                          fit: BoxFit.cover,
                                          width: 150.0,
                                          height: 150.0,
                                        )
                                      : Image.asset(
                                          'assets/images/profile.png',
                                          width: 150.0,
                                          height: 150.0,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: height * 0.5,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'معلومات المالك',
                            style: TextStyle(
                              color: const Color.fromRGBO(15, 99, 43, 1),
                              fontSize: 27,
                            ),
                          ),
                          const Divider(thickness: 2.5),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(AntDesign.mail, color: Colors.grey[700]),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(thickness: 1.5),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(AntDesign.phone, color: Colors.grey[700]),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ' $code $phoneNum ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(thickness: 1.5),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(AntDesign.enviromento,
                                  color: Colors.grey[700]),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '$city , $location',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
