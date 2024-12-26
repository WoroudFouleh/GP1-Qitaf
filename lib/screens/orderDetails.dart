import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:login_page/Auth/test.dart';
import 'package:login_page/widgets/CartAppBar.dart';
import 'package:login_page/widgets/ordersAppBar.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:login_page/screens/config.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//import 'package:uispeed_grocery_shop/page/detail_page.dart';

class Orderdetails extends StatefulWidget {
  final int price;
  final String date;
  final String status;
  final List<dynamic> items;
  const Orderdetails({
    Key? key,
    required this.price,
    required this.date,
    required this.status,
    required this.items,
  }) : super(key: key);

  @override
  State<Orderdetails> createState() => _HomePageState();
}

class _HomePageState extends State<Orderdetails> {
  int indexCategory = 0;
  double userRate = 0.0;
  void rateProduct(String productId, double rate) async {
    try {
      // Prepare the request body
      var reqBody = {
        'productId': productId,
        "newRate": rate,
      };

      // Make the POST request
      var response = await http.post(
        Uri.parse(updateProductRate), // Ensure the URL is correct
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          print('Product rated successfully');
          setState(() {
            userRate = jsonResponse['product']
                ['rate']; // Access the rate from the response
          });
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => Orderdetails(
          //       price: widget.price,
          //       status: widget.status,
          //       items: widget.items,
          //       date: widget.date,
          //     ),
          //   ),
          // );
        } else {
          print('Error rating product: ${jsonResponse['message']}');
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const SizedBox(height: 30),
          const Ordersappbar(),
          const SizedBox(height: 20),
          details(),
          const SizedBox(height: 20),
          gridFood(),
        ],
      ),
    );
  }

  Widget title() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الطلب',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget details() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 5), // Changes position of shadow
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        elevation: 0, // Use 0 here since we are applying a custom shadow
        child: Column(
          children: [
            detailRow(" ₪${widget.price.toString()}  ", "السعر الإجمالي للطلب"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(thickness: 3),
            ),
            detailRow(widget.status, "                حالة الطلب"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(thickness: 3),
            ),
            detailRow(widget.date.toString().substring(0, 10),
                "             تاريخ الطلب"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(thickness: 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String boxText, String labelText) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Fixed-size container
          SizedBox(
            width: 120, // Ensures the same width
            height: 50, // Ensures the same height
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  boxText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          // Label
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                labelText,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget gridFood() {
    return GridView.builder(
      itemCount: widget.items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 280,
      ),
      itemBuilder: (context, index) {
        final item = widget.items[index];
        var productId = item['productId'];

        String itemId;
        if (productId is String) {
          // If it's already a string
          itemId = productId;
        } else if (productId is Map) {
          // If it's an ObjectId (likely returned as a Map with a reference)
          itemId = productId['_id'] ?? ''; // Adjust based on the structure
        } else {
          // Handle the case if productId is neither string nor Map
          itemId = 'defaultValue'; // Default or error handling
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const DetailPage();
            }));
          },
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(120),
                        child: item['image'] != null
                            ? Image.memory(
                                base64Decode(item['image']!),
                                fit: BoxFit.cover,
                                width: 140.0,
                                height: 140.0,
                              )
                            : Image.asset(
                                'assets/images/food.jpg',
                                fit: BoxFit.cover,
                                width: 140.0,
                                height: 140.0,
                              ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Text(
                        item['productName'],
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center, // Align to the right
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              " ${item['quantity']} ${item['quantityType']} \n ₪ ${item['price']}",
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 55, 54, 54),
                                  fontSize: 15),
                              textAlign: TextAlign.end,

                              // Align to the right
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            userRate.toString(),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Material(
                    color: const Color.fromRGBO(15, 99, 43, 1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () => showRatingDialog(
                          context, itemId, item['productName']),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showRatingDialog(
      BuildContext context, String productId, String productName) {
    double rating = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(" ($productName) قيّم المنتج"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("الرجاء تقييم المنتج"),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle the rating submission here
                print("User rated $rating stars for item $productName");
                rateProduct(productId, rating);
              },
              child: const Text("تقييم"),
            ),
          ],
        );
      },
    );
  }
}
