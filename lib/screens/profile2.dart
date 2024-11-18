import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

class Profile2 extends StatelessWidget {
  final token;
  //final userData;

  const Profile2({required this.token, Key? key}) : super(key: key);
  Map<String, dynamic> decodeToken(String token) {
    try {
      final jwtDecoderToken = JwtDecoder.decode(token);
      return jwtDecoderToken;
    } catch (e) {
      print('Error decoding token: $e');
      return {};
    }
  }

  // Decode the token using jwt_decoder and extract necessary fields
  //Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);

  @override
  Widget build(BuildContext context) {
    final userData = decodeToken(token);

    // Extract name, email, and phone
    final firstName = userData['firstName'] ?? 'Unknown Name';
    final lastName = userData['lastName'] ?? 'Unknown Name';
    final profileImage = userData['profilePhoto'];
    final email = userData['email'] ?? 'Unknown Email';
    final phoneCode = userData['phoneCode'] ?? 'Unknown Phone';
    final phoneNumber = userData['phoneNumber'] ?? 'Unknown Phone';
    final city = userData['city'] ?? 'Unknown city';
    final street = userData['street'] ?? 'Unknown street';
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    int rating = 1; // Example rating, adjust dynamically based on your data

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
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
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 73),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.white, // لون السهم أبيض
                    ),
                  ),
                  //Spacer(), // Push the text to the right
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'صفحة\nالمالك الشخصية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                    ),
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  Container(
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
                                    SizedBox(
                                      height: 80,
                                    ),
                                    Text(
                                      '$firstName $lastName',
                                      style: TextStyle(
                                        color: Color.fromRGBO(52, 121, 40, 1),
                                        fontSize: 30,
                                      ),
                                    ),
                                    SizedBox(
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
                                              '10',
                                              style: TextStyle(
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
                                        Column(
                                          children: [
                                            Text(
                                              'التقييم',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 20,
                                              ),
                                            ),
                                            // Replace the number with stars
                                            Row(
                                              children: List.generate(
                                                5, // Total stars
                                                (index) => Icon(
                                                  index < rating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Color.fromRGBO(
                                                      52, 121, 40, 1),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
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
                                  child: profileImage != null
                                      ? Image.memory(
                                          base64Decode(profileImage!),
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
                  SizedBox(
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
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'معلومات المالك',
                            style: TextStyle(
                              color: Color.fromRGBO(52, 121, 40, 1),
                              fontSize: 27,
                            ),
                          ),
                          Divider(
                            thickness: 2.5,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Icon(AntDesign.mail, color: Colors.grey[700]),
                              SizedBox(width: 10),
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
                          Divider(
                            thickness: 1.5,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Icon(AntDesign.phone, color: Colors.grey[700]),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ' $phoneCode $phoneNumber ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            thickness: 1.5,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Icon(AntDesign.enviromento,
                                  color: Colors.grey[700]),
                              SizedBox(width: 10),
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
