import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 decoding
import 'package:http/http.dart' as http;
import 'package:login_page/screens/CartPage.dart';
import 'package:login_page/screens/config.dart';

class CartItemSamples extends StatefulWidget {
  final String productName; // اسم المنتج
  final String? image; // الصورة
  final int price; // السعر
  final int quantity; // الكمية
  final String quantityType; // نوع الكمية (مثل كغم)
  final String productId;
  final String token;
  const CartItemSamples({
    super.key,
    required this.productName,
    required this.image,
    required this.price,
    required this.quantity,
    required this.quantityType,
    required this.productId,
    required this.token,
  });

  @override
  State<CartItemSamples> createState() => _CartItemSamplesState();
}

class _CartItemSamplesState extends State<CartItemSamples> {
  String? selectedRadioValue; // متغير لتخزين القيمة المحددة للراديو
  void deleteItem() async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$deleteItemFromCart/${widget.productId}'), // Send the URL without the username
        headers: {'Content-Type': 'application/json'},
        // Send the username in the body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          print("item deleted successfully");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(token: widget.token),
            ),
          );
        } else {
          print("Error deleting item1");
        }
      } else {
        print("Error deleting item2 ");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.6),
            spreadRadius: 2,
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // First Column: Radio Button (J Button)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                value: widget.productName, // Unique value for each product
                groupValue: selectedRadioValue, // Currently selected value
                onChanged: (value) {
                  setState(() {
                    selectedRadioValue = value as String?;
                  });
                },
              ),
            ],
          ),
          const SizedBox(width: 15), // Space between radio button and image

          // Second Column: Product Image
          Container(
            height: 120,
            width: 120,
            alignment: Alignment.center,
            child: widget.image != null
                ? Image.memory(
                    base64Decode(widget.image!),
                    fit: BoxFit.cover,
                    width: 100.0,
                    height: 100.0,
                  )
                : Image.asset('assets/images/cart1.png'),
          ),
          const SizedBox(width: 20), // Space between image and details

          // Third Column: Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Product Name
                Text(
                  widget.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475269),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      "${widget.quantityType}", // Display quantity type
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475269),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${widget.quantity}", // Display quantity
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475269),
                      ),
                    ),
                  ],
                ),

                // Price
                Row(
                  children: [
                    Text(
                      widget.price.toStringAsFixed(2), // Display price
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "₪", // Currency symbol
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10), // Space between details and trash icon

          // Fourth Column: Trash Icon
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                  size: 30,
                ),
                onPressed: () {
                  deleteItem(); // Print "delete" when pressed
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
