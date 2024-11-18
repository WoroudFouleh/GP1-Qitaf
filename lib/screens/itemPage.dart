import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:login_page/screens/profile2.dart';
import 'package:login_page/widgets/ItemAppBar.dart';
import 'package:login_page/widgets/ItemBottonBar.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

class ItemPage extends StatefulWidget {
  final String productName;
  final String productDescription;
  final String? profilePhotoBase64;
  final int productPrice;
  final String quantityType;
  final int type;
  final quantityAvailable;
  final String token;
  final String productId;

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
      required this.productId})
      : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  int quantity = 1; // Current quantity
  bool isFavorite = false; // Favorite icon state
  bool isLimitExceeded = false; // To track if quantity limit is exceeded
  late String firstName;
  late String lastName;
  String? userProfileImage;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    firstName = jwtDecoderToken['firstName'] ?? 'No First Name';
    lastName = jwtDecoderToken['lastName'] ?? 'No Last Name';
    userProfileImage = jwtDecoderToken[
        'profilePhoto']; // Decode token when the widget is initialized
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

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          ItemAppBar(),
          Padding(
            padding: EdgeInsets.all(16),
            child: widget.profilePhotoBase64 != null
                ? Image.memory(
                    base64Decode(widget.profilePhotoBase64!),
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  )
                : Image.asset(
                    _getDefaultImage(),
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 23, 57, 28).withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15, top: 30, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Profile2(
                                    token: widget
                                        .token), // Navigate to profile page
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                '$firstName $lastName',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 14),
                              ClipOval(
                                child: userProfileImage != null
                                    ? Image.memory(
                                        base64Decode(userProfileImage!),
                                        fit: BoxFit.cover,
                                        width: 50.0,
                                        height: 50.0,
                                      )
                                    : Image.asset('assets/images/profile.png'),
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
                                offset: Offset(0, 0),
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
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 21, 80, 13),
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: const Color.fromARGB(255, 23, 53, 36)
                                    .withOpacity(0.5),
                                offset: Offset(1, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            // Minus button
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(CupertinoIcons.minus, size: 20),
                                color: Color.fromARGB(255, 21, 80, 13),
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
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              padding: EdgeInsets.symmetric(
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
                                      : Color(0xFF475269),
                                ),
                              ),
                            ),
                            // Plus button
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(CupertinoIcons.plus, size: 20),
                                color: Color.fromARGB(255, 21, 80, 13),
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
                            initialRating: 4,
                            minRating: 1,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 2),
                            itemSize: 30,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              shadows: [
                                Shadow(
                                  blurRadius: 15.0,
                                  color: Colors.yellowAccent.withOpacity(0.8),
                                  offset: Offset(0, 0),
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
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Directionality(
                      textDirection:
                          TextDirection.rtl, // لجعل النص يبدأ من اليمين
                      child: Text(
                        widget.productDescription,
                        style: TextStyle(
                          fontSize: 20, // تكبير النص
                          fontWeight: FontWeight.w600, // غمق اللون
                          color: Color(0xFF333333), // لون داكن
                        ),
                        textAlign: TextAlign.justify,
                        overflow: TextOverflow.visible, // للسماح بالتفاف النص
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ItemBottonBar(
          quantityType: widget.quantityType,
          productPrice: widget.productPrice,
          quantity: quantity,
          productName: widget.productName,
          profilePhotoBase64: widget.profilePhotoBase64,
          token: widget.token,
          productId: widget.productId),
    );
  }
}
