import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_page/screens/itemPage.dart';
import 'dart:convert'; // For base64 decoding

class Item3Widget extends StatelessWidget {
  final String productName;
  final String productDescription;
  final String? profilePhotoBase64;
  final int productPrice;
  final String quantityType;

  const Item3Widget({
    Key? key,
    required this.productName,
    required this.productDescription,
    required this.profilePhotoBase64,
    required this.productPrice,
    required this.quantityType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth / 5 - 20;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD3E5D3).withOpacity(0.7),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD3E5D3).withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: profilePhotoBase64 != null
                    ? Image.memory(
                        base64Decode(profilePhotoBase64!),
                        fit: BoxFit.cover,
                        width: imageSize,
                        height: imageSize,
                      )
                    : Image.asset(
                        'assets/images/food.jpg',
                        fit: BoxFit.cover,
                        width: imageSize,
                        height: imageSize,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                productDescription,
                maxLines: 3, // اختصار النصوص الطويلة
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "₪",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(15, 99, 43, 1),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        productPrice.toString(),
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(15, 99, 43, 1),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        quantityType.toString(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Color(0xFF7C7C7C),
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    CupertinoIcons.cart_badge_plus,
                    color: Color(0xFF475269),
                    size: 28,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
