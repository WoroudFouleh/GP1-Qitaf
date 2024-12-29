import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:login_page/screens/config.dart';
import 'package:login_page/screens/profile2.dart';
import 'package:login_page/widgets/ItemAppBar.dart';
import 'package:login_page/widgets/ItemBottonBar.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

class ItemPage extends StatefulWidget {
  final String userId;
  final String productName;
  final String productDescription;
  final String profilePhotoBase64;
  final int productPrice;
  final String quantityType;
  final int type;
  final double productRate;
  final quantityAvailable;
  final String token;
  final String productId;
  final String username;
  final String preparationTime;
  final String preparationUnit;
  final String ownerUsername;
  final String productCity;
  final Map<String, double> productCoordinates;

  const ItemPage(
      {Key? key,
      required this.productName,
      required this.productDescription,
      required this.profilePhotoBase64,
      required this.productPrice,
      required this.quantityType,
      required this.type,
      required this.quantityAvailable,
      required this.token,
      required this.productRate,
      required this.productId,
      required this.username,
      required this.preparationTime,
      required this.preparationUnit,
      required this.ownerUsername,
      required this.userId,
      required this.productCity,
      required this.productCoordinates})
      : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  int quantity = 1; // Current quantity
  bool isFavorite = false; // Favorite icon state
  bool isLimitExceeded = false; // To track if quantity limit is exceeded
  late String firstName = "";
  late String lastName = "";
  String userProfileImage = "";

  late String phoneNum = "";
  late String code = "";
  late String email = "";
  late String city = "";
  late String location = "";
  late int postsCount = 0;
  @override
  void initState() {
    super.initState();
    print("productRate: ${widget.productRate}");

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
          print("User info: $userInfo"); // Assuming the user info is in 'data'
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

  String _getDefaultImage() {
    switch (widget.type) {
      case 1:
        return 'assets/images/harvest.jpg';
      case 2:
        return 'assets/images/food.jpg';
      case 3:
        return 'assets/images/products.jpg';
      default:
        return 'assets/images/harvest.jpg'; // Default image
    }
  }

  @override
  Widget build(BuildContext context) {
    // double ratee = widget.productRate.toDouble();
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const ItemAppBar(),
          Padding(
              padding: const EdgeInsets.all(16),
              child: Image.memory(
                base64Decode(widget.profilePhotoBase64),
                height: 300,
                width: double.infinity,
                fit: BoxFit.fill,
              )),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 23, 57, 28).withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
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
                                ), // Navigate to profile page
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                '$firstName $lastName',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              ClipOval(
                                  child: Image.memory(
                                base64Decode(userProfileImage),
                                fit: BoxFit.cover,
                                width: 40.0,
                                height: 40.0,
                              )
                                  // : Image.asset(
                                  //     'assets/images/profile.png',
                                  //     fit: BoxFit.cover,
                                  //     width: 50.0,
                                  //     height: 50.0,
                                  //   ),
                                  ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: isFavorite ? Colors.redAccent : Colors.grey,
                            size: 30,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: isFavorite
                                    ? Colors.redAccent.withOpacity(0.8)
                                    : Colors.grey.withOpacity(0.5),
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          onPressed: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          },
                        ),
                        Text(
                          widget.productName,
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 21, 80, 13),
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: const Color.fromARGB(255, 23, 53, 36)
                                    .withOpacity(0.5),
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            // Minus button
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon:
                                    const Icon(CupertinoIcons.minus, size: 20),
                                color: const Color.fromARGB(255, 21, 80, 13),
                                onPressed: () {
                                  setState(() {
                                    if (quantity > 1) {
                                      quantity--;
                                      isLimitExceeded = false;
                                    }
                                  });
                                },
                              ),
                            ),
                            // Quantity display with dynamic color
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isLimitExceeded
                                    ? Colors.red.shade100
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isLimitExceeded
                                      ? Colors.red
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                quantity.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isLimitExceeded
                                      ? Colors.red
                                      : const Color(0xFF475269),
                                ),
                              ),
                            ),
                            // Plus button
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(CupertinoIcons.plus, size: 20),
                                color: const Color.fromARGB(255, 21, 80, 13),
                                onPressed: () {
                                  setState(() {
                                    if (quantity < widget.quantityAvailable) {
                                      quantity++;
                                      isLimitExceeded = false;
                                    } else {
                                      isLimitExceeded = true;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: RatingBar.builder(
                            initialRating: widget.productRate,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(
                      thickness: 1.5,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Color.fromARGB(255, 21, 80, 13),
                          size: 33,
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Text(
                              textDirection: TextDirection.rtl,
                              "  ${widget.preparationTime} ${widget.preparationUnit}",
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 21, 80, 13),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              " :المدة الزمنية لتحضير الطلب",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  // Divider line
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(
                      thickness: 1.5,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  // Description text
                  Directionality(
                    textDirection:
                        TextDirection.rtl, // Right-to-left text direction
                    child: Text(
                      widget.productDescription,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ItemBottonBar(
          ownerusername: widget.ownerUsername,
          quantityType: widget.quantityType,
          productPrice: widget.productPrice,
          quantity: quantity,
          productName: widget.productName,
          profilePhotoBase64: widget.profilePhotoBase64,
          token: widget.token,
          productId: widget.productId,
          productCity: widget.productCity,
          productCoordinates: widget.productCoordinates),
    );
  }
}

bool _isValidBase64(String base64String) {
  try {
    base64Decode(base64String);
    return true;
  } catch (e) {
    print("Invalid base64 data: $e");
    return false;
  }
}
