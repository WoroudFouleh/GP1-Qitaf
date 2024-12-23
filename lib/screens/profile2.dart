import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

import 'package:login_page/screens/chat_screen.dart';

class Profile2 extends StatelessWidget {
  final token;
  final userId;
  final String firstName;
  final String lastName;
  final String email;
  final String code;
  final String phoneNum;
  final String? image;
  final String city;
  final String street;
  final int postsCount;
  //final userData;

  const Profile2(
      {required this.token,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.phoneNum,
      required this.code,
      required this.image,
      required this.city,
      required this.street,
      required this.postsCount,
      Key? key, this.userId})
      : super(key: key);

  // Decode the token using jwt_decoder and extract necessary fields
  //Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);

  @override
  Widget build(BuildContext context) {
    //final userData = decodeToken(token);
Future<void> navigateToChat(BuildContext context) async {
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
                currentUserId: userId,
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
    // Extract name, email, and phone
    // final firstName = userData['firstName'] ?? 'Unknown Name';
    // final lastName = userData['lastName'] ?? 'Unknown Name';
    // final profileImage = userData['profilePhoto'];
    // final email = userData['email'] ?? 'Unknown Email';
    // final phoneCode = userData['phoneCode'] ?? 'Unknown Phone';
    // final phoneNumber = userData['phoneNumber'] ?? 'Unknown Phone';
    // final city = userData['city'] ?? 'Unknown city';
    // final street = userData['street'] ?? 'Unknown street';
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    int rating = 1; // Example rating, adjust dynamically based on your data

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
                      color: Colors.white, // لون السهم أبيض
                    ),
                  ),
                  //Spacer(), // Push the text to the right
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'صفحة\nالمالك الشخصية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                    ),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
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
                                    const SizedBox(
                                      height: 80,
                                    ),
                                    Text(
                                      '$firstName $lastName',
                                      style: const TextStyle(
                                        color: Color.fromRGBO(52, 121, 40, 1),
                                        fontSize: 30,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              'المنشورات',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 20,
                                              ),
                                            ),
                                            Text(
                                              postsCount.toString(),
                                              style: const TextStyle(
                                                color: Color.fromRGBO(
                                                    52, 121, 40, 1),
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 25,
                                            vertical: 8,
                                          ),
                                          child: Container(
                                            height: 50,
                                            width: 3,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => navigateToChat(context),
                                          child: Column(
                                            children: [
                                              Text(
                                                'دردشة مع المالك',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const Icon(
                                                AntDesign.message1,
                                                color: Color.fromRGBO(
                                                    52, 121, 40, 1),
                                                size: 25,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 110,
                              right: 20,
                              child: Icon(
                                AntDesign.setting,
                                color: Colors.grey[700],
                                size: 30,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: ClipOval(
                                  child: image != null
                                      ? Image.memory(
                                          base64Decode(image!),
                                          fit: BoxFit.cover,
                                          width: 150.0,
                                          height: 150.0,
                                        )
                                      : Image.asset(
                                          'assets/images/profile.png'),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
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
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'معلومات المالك',
                            style: TextStyle(
                              color: Color.fromRGBO(52, 121, 40, 1),
                              fontSize: 27,
                            ),
                          ),
                          const Divider(
                            thickness: 2.5,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
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
                          const Divider(
                            thickness: 1.5,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
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
                          const Divider(
                            thickness: 1.5,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Icon(AntDesign.enviromento,
                                  color: Colors.grey[700]),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '$city , $street',
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
        )
      ],
    );
  }
}
