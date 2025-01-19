import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:login_page/Delivery/DileveryHome.dart';
import 'package:login_page/screens/config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/customerProfile.dart';
import 'package:login_page/screens/map2.dart';

class AcceptedOrdersPage extends StatefulWidget {
  final String token;
  final String token2;
  AcceptedOrdersPage({required this.token, required this.token2});

  @override
  _AcceptedOrdersPageState createState() => _AcceptedOrdersPageState();
}

class _AcceptedOrdersPageState extends State<AcceptedOrdersPage> {
  late String deliveryEmail;
  late String deliveryCity;
  List<dynamic> slowOrders = [];
  List<dynamic> fastOrders = [];
  LatLng? locationCoordinates;
  @override
  void initState() {
    super.initState();

    // Decode the token to get the email
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    deliveryEmail = jwtDecoderToken['email'] ?? 'No username';
    deliveryCity = jwtDecoderToken['city'] ?? 'No username';
    //fetchAcceptedOrders(deliveryEmail);
    // Assuming coordinates is a map with lat and lng
    var coordinates = jwtDecoderToken['coordinates'];
    if (coordinates != null) {
      locationCoordinates = LatLng(coordinates['lat'], coordinates['lng']);
    } else {
      locationCoordinates = null; // or set to a default LatLng
    }
    _fetchFastOrders();
    _fetchNormalOrders();
  }

  // void fetchAcceptedOrders(String deliveryUsername) async {
  //   final response =
  //       await http.get(Uri.parse('$getAcceptedOrders/$deliveryEmail'));

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     setState(() {
  //       fastOrders = data['fastOrders'];
  //       slowOrders = data['slowItems'];
  //     });
  //   } else {
  //     throw Exception('Failed to load orders');
  //   }
  // }
  Future<void> _fetchFastOrders() async {
    //isFast = true;
    final response = await http.post(
      Uri.parse(getFastAcceptedOrders), // Replace with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'deliveryManLocation': {
          "lat": locationCoordinates!.latitude,
          "lng": locationCoordinates!.longitude
        }, // Example location, can be dynamically set
        'deliveryUsername': deliveryEmail
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        setState(() {
          fastOrders.clear();
          fastOrders.addAll(data['orders']);
        });
        print(fastOrders);
      } else {
        print('Error fetching orders: ${data['error']}');
      }
    } else {
      print('Failed to load orders');
    }
  }

  Future<void> _fetchNormalOrders() async {
    final response = await http.post(
      Uri.parse(getNormalAcceptedOrders), // Replace with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'deliveryManCity':
            deliveryCity, // Example location, can be dynamically set
        'deliveryUsername': deliveryEmail
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data); // Log the API response
      if (data['status'] == true) {
        setState(() {
          slowOrders.clear();
          slowOrders
              .addAll(data['groups']); // Assuming orders are inside "groups"
        });
      } else {
        print('Error fetching orders: ${data['error']}');
      }
    } else {
      print('Failed to load orders');
    }
  }

  void _showCoordinatesOnMap(
      Map<String, double> coordinates, String locationName) {
    try {
      final latitude = coordinates['lat']!;
      final longitude = coordinates['lng']!;

      final location = LatLng(latitude, longitude);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MapScreen2(
            initialLocation: location,
            name: locationName,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء عرض الموقع')),
      );
    }
  }

  Future<void> _updateManStatus() async {
    try {
      final response = await http.post(
        Uri.parse(updateDeliveryManStatus),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': deliveryEmail, // Replace with the actual email
          'status': 'Available',
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الحالة بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('Failed to update status: ${response.body}');
      }
    } catch (e) {
      print('Error updating delivery man status: $e');
    }
  }

  void updateItemsStatus(List<String> itemIds, String status) async {
    // Replace with your backend URL

    try {
      final response = await http.post(
        Uri.parse(updateItemsRecievedStatus),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'itemIds': itemIds, 'status': status}),
      );

      if (response.statusCode == 200) {
        // Successful request
        print('Order status updated successfully!');
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => AcceptedOrdersPage(token: widget.token)),
        // );
        await _updateManStatus();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DeliveryOrdersPage(
                  token: widget.token, token2: widget.token2)),
        );
      } else {
        // Handle errors
        print('Failed to update order status: ${response.body}');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  void updateFastOrderStatus(String orderId, String status) async {
    // Replace with your backend URL

    try {
      final response = await http.post(
        Uri.parse(updateFastRecievedStatus),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId, 'status': status}),
      );

      if (response.statusCode == 200) {
        // Successful request
        print('Order status updated successfully!');
        await _updateManStatus();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DeliveryOrdersPage(
                  token: widget.token, token2: widget.token2)),
        );
      } else {
        // Handle errors
        print('Failed to update order status: ${response.body}');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   //title: const Text('الطلبات المقبولة'),
      // ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (slowOrders.isNotEmpty) ...[
            const Text(
              'الطلبات العادية',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ...slowOrders.map((order) => _buildNormalOrderCard(order)),
          ],
          if (fastOrders.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'الطلبات السريعة',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ...fastOrders.map((order) => _buildOrderCard(order)),
          ],
          if (slowOrders.isEmpty && fastOrders.isEmpty)
            const Center(
              child: Text(
                'لا توجد طلبات مقبولة حالياً',
                style: TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPathSection(List<dynamic>? path) {
    if (path == null || path.isEmpty) {
      return const Text(
        'لا يوجد مسار متاح',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        textDirection: TextDirection.rtl, // Align to Arabic layout
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl, // Ensure Arabic alignment
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مسار التوصيل:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          ...path.asMap().entries.map((entry) {
            int index = entry.key + 1;
            var step = entry.value;
            String nodeName = step['name'] ?? 'غير متوفر';
            double? lat = step['coordinates']?['lat'];
            double? lng = step['coordinates']?['lng'];

            return GestureDetector(
              onTap: () {
                if (lat != null && lng != null) {
                  _showCoordinatesOnMap({
                    'lat': lat,
                    'lng': lng,
                  }, step['name'] ?? 'غير متوفر');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لا تتوفر إحداثيات لهذه النقطة'),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green, width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$index  ', // Node number
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: Text(
                        nodeName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderDetailWithIcon(
      IconData icon, String title, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              '$title: $value',
              style: const TextStyle(fontSize: 16.0, color: Colors.black),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalOrderCard(Map order) {
    final itemsGroup = order['items'];
    final destinationCity = order['destinationCity'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4), // Shadow position
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with source and destination cities
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      'من: ${itemsGroup.isNotEmpty ? itemsGroup[0]['sourceCity'] : 'غير محدد'}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      'إلى: $destinationCity',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),

            // List of items in this group
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemsGroup.length,
              itemBuilder: (context, index) {
                final item = itemsGroup[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(width: 10),
                          if (item['productImage'] != null)
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color.fromARGB(255, 38, 95, 10),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: MemoryImage(
                                    base64Decode(item['productImage']),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            item['productName'],
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (item['recepientCoordinates'] != null) {
                                final coordinates = {
                                  'lat': (item['recepientCoordinates']['lat']
                                          as num)
                                      .toDouble(),
                                  'lng': (item['recepientCoordinates']['lng']
                                          as num)
                                      .toDouble(),
                                };
                                _showCoordinatesOnMap(
                                    coordinates, 'موقع الاستلام من المالك');
                              }
                            },
                            child: Text(
                              'موقع الاستلام من المالك: ${item['sourceCity']}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              if (item['productCoordinates'] != null) {
                                final coordinates = {
                                  'lat':
                                      (item['productCoordinates']['lat'] as num)
                                          .toDouble(),
                                  'lng':
                                      (item['productCoordinates']['lng'] as num)
                                          .toDouble(),
                                };
                                _showCoordinatesOnMap(
                                    coordinates, 'موقع التسليم إلى الزبون');
                              }
                            },
                            child: Text(
                              'موقع التسليم إلى الزبون: ${item['destinationCity']}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              // Navigate to the customer profile page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Customerprofile(
                                          username: item['customerusername'],
                                        )),
                              );
                            },
                            child: Text(
                              'الملف الشخصي للزبون',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: const Color.fromARGB(255, 26, 105, 1),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          // Add buttons for 'تم الاستلام' and 'تم التوصيل'
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  // Add functionality for 'تم الاستلام' here
                                  final List<String> itemIds = itemsGroup
                                      .where((item) =>
                                          item['itemId'] !=
                                          null) // Filter out items with null itemId
                                      .map<String>((item) => item['itemId']
                                          .toString()) // Convert itemId to string
                                      .toList();
                                  updateItemsStatus(itemIds, 'مستلم');
                                  print(
                                      'تم الاستلام for item ${item['productName']}');
                                },
                                child: Text('تم الاستلام'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  side: BorderSide(
                                      color: Colors.green,
                                      width: 2), // Border color and width
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal:
                                          16.0), // Adjust padding to make it smaller
                                  minimumSize: Size(100,
                                      36), // Set a specific minimum size (width, height)
                                ),
                              ),
                              const SizedBox(width: 5),
                              OutlinedButton(
                                onPressed: () {
                                  final List<String> itemIds = itemsGroup
                                      .where((item) =>
                                          item['itemId'] !=
                                          null) // Filter out items with null itemId
                                      .map<String>((item) => item['itemId']
                                          .toString()) // Convert itemId to string
                                      .toList();
                                  updateItemsStatus(itemIds, 'غير مستلم');
                                },
                                child: Text('لم يتم الاستلام '),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(
                                      color: Colors.red,
                                      width: 2), // Border color and width
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal:
                                          16.0), // Adjust padding to make it smaller
                                  minimumSize: Size(100,
                                      36), // Set a specific minimum size (width, height)
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map order) {
    print("hereeeeee");
    print(order);
    final route = order['deliveryRoute'];
    final orderDetails = order['orderDetails'];
    print(order['deliveryRoute']);
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 7.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4), // Shadow position
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.confirmation_number, color: Colors.blue),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'رقم الطلب: ${orderDetails['_id'].toString().substring(0, 3)}',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const Divider(thickness: 1.5),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.green[100],
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.green,
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                // Navigate to the customer profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Customerprofile(
                            username: orderDetails['username'],
                          )),
                );
              },
              child: _buildOrderDetailWithIcon(
                  Icons.person,
                  'الملف الشخصي للزبون ',
                  orderDetails['username'],
                  const Color.fromARGB(255, 70, 10, 72)),
            ),
            _buildOrderDetailWithIcon(Icons.phone, 'رقم الزبون',
                orderDetails['phoneNumber'], Colors.orange),
            _buildOrderDetailWithIcon(Icons.location_on, 'عنوان التوصيل',
                orderDetails['location'], Colors.red),
            _buildOrderDetailWithIcon(
                Icons.monetization_on, 'الدفع', "عند الاستلام", Colors.teal),
            _buildOrderDetailWithIcon(Icons.attach_money, 'السعر الكلي',
                '${orderDetails['totalPrice'].toString()}', Colors.blue),
            const SizedBox(height: 8.0),
            _buildPathSection(route), // New section for showing the path
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    String orderId = order['orderId'];
                    updateFastOrderStatus(orderId, 'مستلم');
                    // Add functionality for 'تم التوصيل' here
                    print('تم التوصيل for item ${orderDetails['productName']}');
                  },
                  child: Text('تم الاستلام'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: BorderSide(
                        color: Colors.green,
                        width: 2), // Border color and width
                    padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0), // Adjust padding to make it smaller
                    minimumSize: Size(
                        150, 50), // Set a specific minimum size (width, height)
                  ),
                ),
                const SizedBox(width: 5),
                OutlinedButton(
                  onPressed: () {
                    String orderId = order['orderId'];
                    updateFastOrderStatus(orderId, 'غير مستلم');
                    // Add functionality for 'تم التوصيل' here
                    print('تم التوصيل for item ${orderDetails['productName']}');
                  },
                  child: Text('لم يتم الاستلام '),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(
                        color: Colors.red, width: 2), // Border color and width
                    padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0), // Adjust padding to make it smaller
                    minimumSize: Size(
                        150, 50), // Set a specific minimum size (width, height)
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
