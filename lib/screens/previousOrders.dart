import 'package:flutter/material.dart';
import 'package:intl/date_symbols.dart';
import 'package:login_page/widgets/prevOrder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'config.dart';

class Previousorders extends StatefulWidget {
  final token;
  const Previousorders({@required this.token, Key? key}) : super(key: key);

  @override
  State<Previousorders> createState() => _PreviousOrdersState();
}

class _PreviousOrdersState extends State<Previousorders> {
  List<dynamic> orders = [];
  late String username;
  int num = 1;
  @override
  void initState() {
    super.initState();
    username = JwtDecoder.decode(widget.token)['username'] ?? 'Unknown User';
    fetchOrders();
  }

  void fetchOrders() async {
    if (username == null) {
      print("Username not available from token.");
      return;
    }
    print("Sending username: $username");

    try {
      final response = await http.get(
        Uri.parse(
            '$getUserOrders/$username'), // Send the URL without the username
        headers: {'Content-Type': 'application/json'},
        // Send the username in the body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            orders = data['orders'];
          });
          print("Fetched cart items: $orders");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 224, 224),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context); // Navigate back
            },
            child: const Icon(
              Icons.arrow_back, // Arrow icon pointing left
              size: 30,
              color: Color.fromARGB(255, 255, 255, 255), // Olive green color
            ),
          ),
          title: const Align(
            alignment: Alignment.bottomRight, // Align the title to the right
            child: Text(
              "طلباتي السابقة",
              style: TextStyle(
                color: Color.fromARGB(255, 238, 238, 238),
                fontWeight: FontWeight.bold,
                fontFamily: 'CustomArabicFont',
                fontSize: 23,
              ),
            ),
          ),
        ),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                "لا توجد طلبات سابقة",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 188, 248, 202),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index]; // Access each order
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Prevorder(
                      num: num++,
                      status: order['status'],
                      orderId: order['_id'], // Replace with actual field
                      orderDate:
                          order['orderDate'], // Replace with actual field
                      price: order['totalPrice'], // Replace with actual field
                      items: order['items'], // Replace with actual field
                      username: username),
                );
              },
            ),
    );
  }
}
