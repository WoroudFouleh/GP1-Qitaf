import 'package:flutter/material.dart';
import 'package:login_page/widgets/CartAppBar.dart';
import 'package:login_page/widgets/CartItemSamples.dart';
import 'package:login_page/widgets/OrderWidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'config.dart';

class CartPage extends StatefulWidget {
  final String token;
  const CartPage({required this.token, Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> items = []; // List to store cart items
  String? username; // Store the extracted username
  final int deliveryFee = 20; // Example delivery fee
  final int discount = 10; // Example discount

  @override
  void initState() {
    super.initState();
    username = JwtDecoder.decode(widget.token)['username'] ?? 'Unknown User';
    fetchProducts();
  }

  void fetchProducts() async {
    if (username == null) {
      print("Username not available from token.");
      return;
    }
    print("Sending username: $username");

    try {
      final response = await http.get(
        Uri.parse(
            '$getUserCart/$username'), // Send the URL without the username
        headers: {'Content-Type': 'application/json'},
        // Send the username in the body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            items = data['cartItems'];
          });
          print("Fetched cart items: $items");
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

  int calculateTotalPrice() {
    int total = 0;
    for (var item in items) {
      int price = item['price'] ?? 0;
      total += price;
    }
    return total;
  }

  int calculateGrandTotal() {
    return calculateTotalPrice() + deliveryFee - discount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const CartAppBar(),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEDECF2),
            ),
            child: Column(
              children: [
                items.isEmpty
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.all(
                              20), // Add margin for spacing
                          padding: const EdgeInsets.all(
                              20), // Padding inside the container
                          decoration: BoxDecoration(
                            color: Colors.white, // Background color
                            borderRadius:
                                BorderRadius.circular(20), // Rounded borders
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 5,
                                spreadRadius: 2,
                                offset:
                                    const Offset(0, 3), // Add a shadow effect
                              ),
                            ],
                          ),
                          child: const Text(
                            "عربة التسوق فارغة",
                            textAlign: TextAlign.right, // Center the text
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(
                                  255, 240, 21, 21), // Text color
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return CartItemSamples(
                            productName: item['productName'],
                            image: item['image'],
                            price: item['price'],
                            quantity: item['quantity'],
                            quantityType: item['quantityType'],
                            productId: item['_id'],
                            token: widget.token,
                          );
                        },
                      ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF475269).withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                calculateTotalPrice().toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475269),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "₪",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475269),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            ":الإجمالي الفرعي",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475269),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 20,
                        thickness: 0.5,
                        color: Color(0xFF475269),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                deliveryFee.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475269),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "₪",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475269),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            ":توصيل مجاني",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475269),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 20,
                        thickness: 0.5,
                        color: Color(0xFF475269),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "-$discount",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475269),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "₪",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475269),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            ":خصم",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475269),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 20,
                        thickness: 0.5,
                        color: Color(0xFF475269),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                calculateGrandTotal().toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "₪",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            ":الإجمالي",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475269),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                OrderWidget(
                  items: items, // Pass the list of items
                  token: widget.token, // Pass the token
                  totalPrice: calculateGrandTotal(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
