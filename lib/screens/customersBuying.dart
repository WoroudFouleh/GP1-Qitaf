import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class CustomersBuying extends StatefulWidget {
  final String token;
  final String userId;
  const CustomersBuying({super.key, required this.token, required this.userId});

  @override
  _CustomersBuyingState createState() => _CustomersBuyingState();
}

class _CustomersBuyingState extends State<CustomersBuying> {
  int quantity = 1; // الكمية الحالية
  late String username;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    //print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No username';
    fetchItems();
  }

  void fetchItems() async {
    final response = await http.get(
      Uri.parse('$getOwnerOrders/$username'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          items = data['items']; // Update the lands list with the response data
        });
        print(items);
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

  Future<void> updateItemPreparation(String itemId, String status) async {
    final response = await http.put(
      Uri.parse('$updatePreparationStatus/$itemId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      print("Item preparation status updated successfully");
    } else {
      print("Failed to update item preparation status: ${response.body}");
    }
  }

  void handleReadyConfirmation(
      BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "هل أصبح الطلب جاهزاً للاستلام من قبل عامل التوصيل؟",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline,
                size: 50,
                color: Colors.orange,
              ),
              SizedBox(height: 10),
              Text(
                "يرجى تأكيد جاهزية الطلب للاستلام.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            // No Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              icon: Icon(
                Icons.close,
                color: Colors.black,
              ),
              label: Text(
                "لا",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(width: 10),
            // Yes Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await updateItemPreparation(
                    item['_id'], 'ready'); // Update status
                setState(() {
                  item['itemPreparation'] = 'ready'; // Update locally
                });
              },
              icon: Icon(
                Icons.check,
                color: Colors.white,
              ),
              label: Text(
                "نعم",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void handleCancelledItem(BuildContext context, String productName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Text(
                'لم يقم الزبون باستلام الطلب',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.left,
              ),
              SizedBox(width: 10),
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 30,
              ),
            ],
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'هل تريد إعطاء هذا المستخدم تنبيهاً؟',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel,
                    size: 20,
                    color: Colors.black,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'إلغاء',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print("Report submitted for $productName");
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.report,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'تنبيه المستخدم',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Color getButtonColor(Map<String, dynamic> item) {
    if (item['itemPreparation'] == 'notReady') {
      return Colors.grey;
    } else if (item['itemPreparation'] == 'ready') {
      switch (item['itemStatus']) {
        case 'delivered':
          return Colors.green;
        case 'undelivered':
          return Colors.amber;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
    return Colors.grey;
  }

  String getButtonText(Map<String, dynamic> item) {
    if (item['itemPreparation'] == 'notReady') {
      return " حالة الاستلام غير متوفرة";
    } else if (item['itemPreparation'] == 'ready') {
      switch (item['itemStatus']) {
        case 'delivered':
          return "تم الاستلام";
        case 'undelivered':
          return "لم يتم التسليم بعد";
        case 'cancelled':
          return "الزبون لم يستلم الطلب!";
        default:
          return "حالة الاستلام غير متوفرة";
      }
    }
    return "غير مفعّل";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl, // Make the text right-to-left
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 35, horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event, // Booking icon
                        size: 30,
                        color: Color(0xFF556B2F), // Olive color
                      ),
                      SizedBox(width: 8),
                      Text(
                        "سجل شراء الزبائن",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF556B2F), // Olive color
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_forward, // Back arrow
                      size: 30,
                      color: Color(0xFF556B2F), // Olive color
                    ),
                  ),
                ],
              ),
            ),
            // Items List
            Expanded(
              child: Container(
                // padding: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 237, 236, 242),
                ),
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          "لا توجد بيانات متاحة",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Item Header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Color(0xFF556B2F),
                                                width: 2, // Olive border
                                              ),
                                              image: DecorationImage(
                                                image: MemoryImage(base64Decode(
                                                    item[
                                                        'image'])), // Replace with your asset
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['productName'] ??
                                                    "اسم المنتج",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF556B2F),
                                                ),
                                              ),
                                              //SizedBox(height: 5),
                                            ],
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          print(
                                              "Delete pressed for ${item['productName']}");
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "${item['username']} ",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "${item['addedAt'].toString().substring(0, 10)}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // Item Details
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.scale,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "${item['quantity'] ?? 0} ${item['quantityType'] ?? ''}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.attach_money,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "${item['price'] ?? 0} ₪",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  // Buttons
                                  ElevatedButton(
                                    onPressed:
                                        item['itemPreparation'] == 'notReady'
                                            ? () => handleReadyConfirmation(
                                                context, item)
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          item['itemPreparation'] == 'ready'
                                              ? Colors.green
                                              : Colors.red,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          item['itemPreparation'] == 'ready'
                                              ? Icons.check_circle
                                              : Icons.pending,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          item['itemPreparation'] == 'ready'
                                              ? "جاهز للاستلام"
                                              : "اضغط إذا أصبح الطلب جاهزا",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 15),
                                  ElevatedButton(
                                    onPressed: (item['itemPreparation'] ==
                                                'notReady' ||
                                            item['itemStatus'] == 'delivered')
                                        ? null
                                        : item['itemStatus'] == 'cancelled'
                                            ? () => handleCancelledItem(
                                                context, item['productName'])
                                            : () {
                                                print(
                                                    "${item['productName']} button pressed");
                                              },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: getButtonColor(item),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        //SizedBox(width: 10),
                                        Text(
                                          getButtonText(item),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
