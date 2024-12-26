import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/profile3.dart';

import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class CustomerWorkPage extends StatefulWidget {
  final userId;
  final String token;
  const CustomerWorkPage({required this.token, Key? key, this.userId});

  @override
  State<CustomerWorkPage> createState() => _CustomerWorkPageState();
}

class _CustomerWorkPageState extends State<CustomerWorkPage> {
  int quantity = 1; // الكمية الحالية
  double rating = 0;
  Map<String, dynamic> landInfoCache = {};
  // قيمة التقييم الافتراضية (نجمة 4)
  List<dynamic> requests = [];
  late String username;
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No username';

    fetchRequests(); // Call the fetch function when the page is loaded
  }

  Future<Map<String, dynamic>> fetchLand(String landId) async {
    print("landid:   ${landId}");
    // If the land info is already cached, return it
    if (landInfoCache.containsKey(landId)) {
      return landInfoCache[landId];
    }

    try {
      final response = await http.get(
        Uri.parse('$getLand/$landId'), // Replace with your backend API
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          // Cache the land info
          landInfoCache[landId] = data;
          return data;
        } else {
          print('Failed to fetch land details: ${data['message']}');
          return {};
        }
      } else {
        print('Failed to fetch land: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching land info: $e');
      return {};
    }
  }

  void fetchRequests() async {
    final response = await http.get(
      Uri.parse('$getWorkerRequests/$username'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          requests =
              data['requests']; // Update the lands list with the response data
        });
      } else {
        print("Error fetching requests: ${data['message']}");
      }
    } else {
      print("Failed to load requests: ${response.statusCode}");
    }
  }

  void deleteRequest(String requestId) async {
    try {
      print("request id: $requestId");
      final response = await http.delete(
        Uri.parse(
            '$deleteWorkRequest/${requestId}'), // Send the URL without the username
        headers: {'Content-Type': 'application/json'},
        // Send the username in the body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          print("request deleted successfully");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerWorkPage(token: widget.token),
            ),
          );
        } else {
          print("Error deleting request1");
        }
      } else {
        print("Error deleting request2 ");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl, // جعل الكتابة من اليمين لليسار
        child: ListView(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.event, // أيقونة تدل على الحجز
                        size: 30,
                        color: Color(0xFF556B2F), // لون زيتي
                      ),
                      SizedBox(width: 8),
                      Text(
                        "  طلبات العمل",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF556B2F), // لون زيتي
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_forward, // سهم يتجه لليسار ليكون ع الشمال
                      size: 30,
                      color: Color(0xFF556B2F), // لون زيتي
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEDECF2),
              ),
              child: Column(
                children: [
                  for (var request in requests)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 113, 134, 25)
                                .withOpacity(0.6),
                            spreadRadius: 2,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: fetchLand(request[
                            'landId']), // Call fetchLand for each request
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text('Failed to load land info');
                          }

                          final landData = snapshot.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Color(0xFF556B2F),
                                            width: 2,
                                          ),
                                          image: DecorationImage(
                                            image: MemoryImage(base64Decode(
                                                landData['image'])),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                landData['landName'] ??
                                                    'Unknown Land',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF556B2F),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 150,
                                              ),
                                              SizedBox(height: 5),
                                              IconButton(
                                                onPressed: () {
                                                  // ضع الوظيفة التي تريد تنفيذها عند الضغط على الأيقونة
                                                  print(
                                                      "request1: ${request['_id']}");
                                                  deleteRequest(request['_id']);
                                                  //print('Delete icon pressed');
                                                },
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors
                                                      .red, // لون الأيقونة
                                                  size: 30,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),

                              // Display other land information here
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '${landData['city']} , ${landData['location']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'أيام العمل: ${landData['startDate'].toString().substring(0, 10)} إلى ${landData['endDate'].toString().substring(0, 10)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Color.fromRGBO(85, 107, 47, 1),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'أوقات العمل: ${landData['startTime']} إلى ${landData['endTime']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "أجرة العامل: ₪ ${landData['workerWages']} / ساعة ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.apple_rounded,
                                        color: Color(0xFF556B2F),
                                        size: 16,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "المحصول: ${landData['cropType']}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_circle,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      GestureDetector(
                                        onTap: () {
                                          // Navigate to the profile page and pass the username
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Ownerprofile2(
                                                username: landData[
                                                    'username'], // Pass the owner's username
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          '  حساب مالك خط الإنتاج:  ${landData['username']} ',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors
                                                .black, // لون النص أزرق للإشارة إلى إمكانية التفاعل
                                            fontWeight: FontWeight.bold,
                                            // خط تحت النص للإشارة إلى رابط
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        " تاريخ تقديم الطلب: ${request['requestDate'].toString().substring(0, 10)}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 15),

                              ElevatedButton(
                                onPressed: () {
                                  // Handle button press if necessary
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: request['requestStatus'] ==
                                          'pending'
                                      ? const Color.fromARGB(255, 248, 184, 23)
                                      : request['requestStatus'] == 'accepted'
                                          ? Colors.green
                                          : Colors
                                              .red, // Change color based on status
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  minimumSize: Size(
                                      double.infinity, 0), // Full-width button
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      request['requestStatus'] == 'pending'
                                          ? Icons.pending
                                          : request['requestStatus'] ==
                                                  'accepted'
                                              ? Icons.check_circle
                                              : Icons
                                                  .cancel, // Change icon based on status
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      request['requestStatus'] == 'pending'
                                          ? "بانتظار الرد"
                                          : request['requestStatus'] ==
                                                  'accepted'
                                              ? "تم القبول"
                                              : "تم الرفض", // Change text based on status
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
