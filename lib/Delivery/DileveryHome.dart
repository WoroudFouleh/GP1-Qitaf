import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:login_page/Delivery/AcceptedPage.dart';
import 'package:login_page/Delivery/DeliveryMap.dart';
import 'package:login_page/Delivery/DileveryProfile.dart';
import 'package:login_page/screens/allInbox.dart';
import 'package:login_page/screens/map2.dart';
import 'package:login_page/screens/map_screen.dart';
import 'package:login_page/screens/config.dart';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

class DeliveryOrdersPage extends StatefulWidget {
  final String token;
  final String token2;
  const DeliveryOrdersPage(
      {super.key, required this.token, required this.token2});
  @override
  _DeliveryOrdersPageState createState() => _DeliveryOrdersPageState();
}

class _DeliveryOrdersPageState extends State<DeliveryOrdersPage> {
  String _status = 'متاح'; // الحالة الافتراضية
  int _currentIndex = 0;
  LatLng? locationCoordinates;
  final List<dynamic> _orders = [];
  late String deliveryCity;
  bool isFast = true;
  late String deliveryusername;
  late String uid;
  late String deliveryManStatus;
  @override
  void initState() {
    super.initState();
    uid = JwtDecoder.decode(widget.token2)['user_id'];
    print(uid);
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    deliveryCity = jwtDecoderToken['city'] ?? 'No username';
    deliveryusername = jwtDecoderToken['email'] ?? 'No username';
    deliveryManStatus = jwtDecoderToken['status'] ?? 'No username';
    if (deliveryManStatus == 'Available') {
      _status = 'متاح';
    } else if (deliveryManStatus == 'Busy') {
      _status = 'مشغول';
    } else {
      _status = 'خارج عن الخدمة';
    }
  }

  Future<void> _updateDeliveryManStatus(String newStatus) async {
    try {
      final response = await http.post(
        Uri.parse(updateDeliveryManStatus),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': deliveryusername, // Replace with the actual email
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _status = newStatus; // Update the UI with the new status
        });
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

  void _updateStatus(String newStatus) {
    setState(() {
      _status = newStatus;
    });
  }

  Future<void> _fetchFastOrders() async {
    isFast = true;
    final response = await http.post(
      Uri.parse(getFastDeliveryOrders), // Replace with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'deliveryManLocation': {
          "lat": locationCoordinates!.latitude,
          "lng": locationCoordinates!.longitude
        }, // Example location, can be dynamically set
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        setState(() {
          _orders.clear();
          _orders.addAll(data['orders']);
        });
      } else {
        print('Error fetching orders: ${data['error']}');
      }
    } else {
      print('Failed to load orders');
    }
  }

  Future<void> _fetchNormalOrders() async {
    isFast = false;
    final response = await http.post(
      Uri.parse(getNormalDeliveryOrders), // Replace with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'deliveryManCity':
            deliveryCity // Example location, can be dynamically set
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data); // Log the API response
      if (data['status'] == true) {
        setState(() {
          _orders.clear();
          _orders.addAll(data['groups']); // Assuming orders are inside "groups"
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

  void _navigateToMap() async {
    // Navigate to the MapScreen and wait for the result
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        // _streetController.text = "${result['name']}"; // Fill the TextField
        // _coordController.text =
        //     "${result['position'].latitude}, ${result['position'].longitude}";
        locationCoordinates = result['position'];
        print("Name: ${result['name']}, Coordinates: ${result['position']}");
      });
      await _updateCoordinates(
        // Replace with the actual email
        coordinates: result['position'],
      );
      // Optionally save the result to the database
      //_saveLocationToDatabase(result['name'], result['position']);
    }
  }

  Future<void> _updateCoordinates({
    required dynamic coordinates,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(updateDeliveryManCoordinates),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': deliveryusername,
          'coordinates': {
            'lat': coordinates.latitude,
            'lng': coordinates.longitude,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status']) {
          print('Coordinates updated successfully');
        } else {
          print('Error: ${data['error']}');
        }
      } else {
        print('Failed to update coordinates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating coordinates: $e');
    }
  }

  void _showOrderTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'اختر نوع الطلبات',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _fetchFastOrders(); // Call fetch orders for fast delivery
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(15, 99, 43, 1),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'الطلبات السريعة',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                print("normal");
                Navigator.of(context).pop(); // Close the dialog
                _fetchNormalOrders(); // Call fetch orders for normal delivery
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'الطلبات العادية',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateItemsStatus(
    List<String> itemIds,
  ) async {
    // Replace with your backend URL

    try {
      final response = await http.post(
        Uri.parse(updateNormalItemsStatus),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'itemIds': itemIds,
          'deliverymanUsername': deliveryusername,
        }),
      );

      if (response.statusCode == 200) {
        // Successful request
        print('Order status updated successfully!');
      } else {
        // Handle errors
        print('Failed to update order status: ${response.body}');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  void updateFastOrderStatus(
    String orderId,
  ) async {
    // Replace with your backend URL

    try {
      final response = await http.post(
        Uri.parse(updateFastStatus),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'deliveryUsername': deliveryusername,
        }),
      );

      if (response.statusCode == 200) {
        // Successful request
        print('Order status updated successfully!');
      } else {
        // Handle errors
        print('Failed to update order status: ${response.body}');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  // صفحة رئيسية مع الحالة
  Widget _buildHomePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            'الحالة: $_status',
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusButton(
                  'متاح', _status == 'متاح', Color.fromRGBO(15, 99, 43, 1)!),
              const SizedBox(width: 8.0),
              _buildStatusButton('مشغول', _status == 'مشغول', Colors.orange),
              const SizedBox(width: 8.0),
              _buildStatusButton(
                  'خارج عن الخدمة', _status == 'خارج عن الخدمة', Colors.red),
            ],
          ),
        ),
        const Divider(),
        // Conditionally render buttons based on status
        if (_status == 'متاح') ...[
          Row(
            children: [
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _navigateToMap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(15, 99, 43, 1),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                label: const Text(
                  ' موقع الانطلاق',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 5),
              ElevatedButton.icon(
                onPressed:
                    locationCoordinates == null ? null : _showOrderTypeDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: locationCoordinates == null
                      ? Colors.grey
                      : Colors.yellow[700],
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: const Icon(
                  Icons.assignment_turned_in,
                  color: Colors.white,
                ),
                label: const Text(
                  'إحضار الطلبات المقترحة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
        Expanded(
          child: _status == 'متاح'
              ? ListView.builder(
                  itemCount: _orders.length, // Dynamically set to order count
                  itemBuilder: (context, index) {
                    if (isFast) {
                      return _buildOrderCard(
                          _orders[index]); // Pass the order data
                    } else {
                      return _buildNormalOrderCard(
                          _orders[index]); // Pass the order data
                    }
                  },
                )
              : Center(
                  child: Text(
                    _status == 'مشغول'
                        ? 'لا توجد طلبات مخصصة لك حاليًا'
                        : 'أنت خارج عن الخدمة حاليًا',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
        ),
      ],
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
                      Row(
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
                          const SizedBox(width: 12),
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
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print(itemsGroup);
                      final List<String> itemIds = itemsGroup
                          .where((item) =>
                              item['itemId'] !=
                              null) // Filter out items with null itemId
                          .map<String>((item) => item['itemId']
                              .toString()) // Convert itemId to string
                          .toList();

                      print('itemIds: $itemIds');

                      if (itemIds.isEmpty) {
                        print('No valid item IDs found');
                        return;
                      }

                      print('items: $itemIds');

                      _updateStatus('مشغول');
                      updateItemsStatus(itemIds);
                      _updateDeliveryManStatus('Busy');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم قبول الطلب!'),
                          backgroundColor: Color.fromRGBO(15, 99, 43, 1),
                        ),
                      );
                    },
                    //icon: const Icon(Icons.check, color: Colors.green),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Color.fromRGBO(
                          15, 99, 43, 1), // Change background to solid green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white, // Set the icon color to white
                    ),
                    label: const Text(
                      'قبول',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Change the text color to white
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map order) {
    print("hereeeeee");
    final route = order['deliveryRoute'];
    final orderDetails = order['orderDetails'];
    print(order['deliveryRoute']);
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFEFFAF1),
              Color(0xFFDFF2E0),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.confirmation_number, color: Colors.blue),
                Text(
                  'رقم الطلب: ${orderDetails['phoneNumber']}',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.right,
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
                  color: Color.fromRGBO(15, 99, 43, 1),
                ),
              ),
            ),

            _buildOrderDetailWithIcon(Icons.person, 'الزبون',
                orderDetails['username'], Colors.purple),
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
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      String orderId = order['orderId'];
                      updateFastOrderStatus(orderId);
                      _updateStatus('مشغول');
                      _updateDeliveryManStatus('Busy');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم قبول الطلب!'),
                          backgroundColor: Color.fromRGBO(15, 99, 43, 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor:
                          Colors.green, // Change background to solid green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white, // Set the icon color to white
                    ),
                    label: const Text(
                      'قبول',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Change the text color to white
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
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
                  border: Border.all(
                      color: Color.fromRGBO(15, 99, 43, 1), width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$index  ', // Node number
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(15, 99, 43, 1),
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

  Widget _buildStatusButton(String status, bool isSelected, Color color) {
    return ElevatedButton(
      onPressed: () => _updateStatus(status),
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.black,
        backgroundColor: isSelected ? color : Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
        minimumSize: Size(100, 50),
      ),
      child: Text(status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _currentIndex == 2
            ? null // لا يظهر التوب بار عند الضغط على الخريطة
            : AppBar(
                backgroundColor: Color.fromRGBO(15, 99, 43, 1),
                title: Text(
                  _currentIndex == 0
                      ? 'الصفحة الرئيسية'
                      : _currentIndex == 1
                          ? 'الطلبات المقبولة'
                          : _currentIndex == 2
                              ? 'الخريطة'
                              : _currentIndex == 3
                                  ? 'المحادثة'
                                  : 'الملف الشخصي',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      // تنفيذ عند الضغط على الجرس
                    },
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      // تنفيذ عند الضغط على تسجيل الخروج
                    },
                    color: Colors.white,
                  ),
                ],
              ),
        body: _currentIndex == 0
            ? _buildHomePage()
            : _currentIndex == 1
                ? AcceptedOrdersPage(
                    token: widget.token,
                    token2: widget.token2,
                  )
                : _currentIndex == 2
                    ? Deliverymap()
                    : _currentIndex == 3
                        ? TabbedInboxScreen(userId: uid)
                        : DeliveryProfile(
                            token: widget.token,
                          ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'الطلبات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'الخريطة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'الدردشة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'الملف الشخصي',
            ),
          ],
          selectedItemColor: Color.fromRGBO(15, 99, 43, 1),
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}
