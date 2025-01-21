import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/config.dart';

class ItemBottonBar extends StatelessWidget {
  final int productPrice;
  final String quantityType;
  final String productName;
  final String? profilePhotoBase64;
  final String token;
  final int quantity;
  final String productId;
  final String username;
  final String ownerusername;
  final String productCity;
  final Map<String, double> productCoordinates;
  ItemBottonBar({
    Key? key,
    required this.productPrice,
    required this.quantityType,
    required this.productName,
    required this.token,
    required this.quantity,
    required this.profilePhotoBase64,
    required this.productId,
    required this.ownerusername,
    required this.productCity,
    required this.productCoordinates,
  })  : username = JwtDecoder.decode(token)['username'] ?? 'Unknown User',
        super(key: key);

  void addItemToCart() async {
    try {
      // Prepare the request body
      var reqBody = {
        'ownerusername': ownerusername,
        'username': username,
        "productName": productName,
        "image": profilePhotoBase64,
        "productId": productId,
        "price": (quantity * productPrice),
        "quantity": quantity,
        "quantityType": quantityType,
        "productCity": productCity,
        "productCoordinates": {
          "lat": productCoordinates['lat'], // Add latitude
          "lng": productCoordinates['lng'], // Add longitude
        },
      };

      // Make the POST request
      var response = await http.post(
        Uri.parse(addToCart), // Ensure the URL is correct
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          print('Product added successfully');
        } else {
          print('Error adding product: ${jsonResponse['message']}');
        }
      } else {
        var errorResponse = jsonDecode(response.body);
        print('Error: ${errorResponse['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // عرض الشاشة
    return Container(
      height: 80, // ارتفاع أكبر قليلاً للويب
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ElevatedButton on the left
          ElevatedButton.icon(
            onPressed: addItemToCart,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                const Color.fromRGBO(15, 99, 43, 1), // لون كبسة زيتي
              ),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(
                  vertical: 15, // زيادة ارتفاع الزر
                  horizontal: screenWidth * 0.02, // عرض الزر ديناميكي
                ),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            icon: const Icon(
              CupertinoIcons.cart_badge_plus,
              color: Colors.white, // لون الأيقونة أبيض
            ),
            label: Text(
              "إضافة إلى سلة المشتريات",
              style: TextStyle(
                fontSize: screenWidth * 0.012, // ضبط حجم النص ديناميكياً
                fontWeight: FontWeight.bold,
                color: Colors.white, // لون النص أبيض
              ),
            ),
          ),
          // Price on the right with separate currency and weight text
          Row(
            children: [
              // Weight text
              Text(
                quantityType, // نص الوزن
                style: TextStyle(
                  fontSize: screenWidth * 0.014, // حجم الخط ديناميكي
                  color: const Color(0xFF7C7C7C), // لون أقل شدة
                ),
              ),
              const SizedBox(width: 5), // إضافة مسافة بين السلاش و"كغم"
              const Text(
                "/", // السلاش
                style: TextStyle(
                  fontSize: 18, // حجم الخط للسلاش
                  color: Color(0xFF7C7C7C), // لون أقل شدة
                ),
              ),
              const SizedBox(width: 5), // إضافة مسافة بين السلاش والرقم
              // Price
              Text(
                productPrice.toString(), // الرقم فقط
                style: TextStyle(
                  fontSize: screenWidth * 0.02, // حجم الخط ديناميكي
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(15, 99, 43, 1), // لون الرقم زيتي
                ),
              ),
              const SizedBox(width: 5), // إضافة مسافة بين الرقم والعملة
              // Currency
              const Text(
                "₪", // العملة
                style: TextStyle(
                  fontSize: 20, // حجم الخط للعملة
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(15, 99, 43, 1), // لون العملة زيتي
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
