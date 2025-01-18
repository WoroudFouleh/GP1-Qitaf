import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:login_page/screens/config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/map2.dart';
import 'package:login_page/screens/map_screen.dart';

class AcceptedOrdersPage extends StatefulWidget {
  final String token;

  AcceptedOrdersPage({required this.token});

  @override
  _AcceptedOrdersPageState createState() => _AcceptedOrdersPageState();
}

class _AcceptedOrdersPageState extends State<AcceptedOrdersPage> {
  late String deliveryEmail;
  List<dynamic> slowOrders = [];
  List<dynamic> fastOrders = [];

  @override
  void initState() {
    super.initState();

    // Decode the token to get the email
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    deliveryEmail = jwtDecoderToken['email'] ?? 'No username';
    fetchAcceptedOrders(deliveryEmail);
  }

  void fetchAcceptedOrders(String deliveryUsername) async {
    final response =
        await http.get(Uri.parse('$getAcceptedOrders/$deliveryEmail'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fastOrders = data['fastOrders'];
        slowOrders = data['slowItems'];
      });
    } else {
      throw Exception('Failed to load orders');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات المقبولة'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (slowOrders.isNotEmpty) ...[
            const Text(
              'الطلبات العادية:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            ...slowOrders.map((order) => _buildNormalOrderCard(order)),
          ],
          if (fastOrders.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'الطلبات السريعة:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
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
                  color: Colors.green,
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
                      // updateFastOrderStatus(orderId);
                      // _updateStatus('مشغول');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم قبول الطلب!'),
                          backgroundColor: Colors.green,
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

                      // _updateStatus('مشغول');
                      // updateItemsStatus(itemIds);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم قبول الطلب!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    //icon: const Icon(Icons.check, color: Colors.green),
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

  Widget _buildFastOrders() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: fastOrders.map((order) {
            return _buildOrderDetail(order);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSlowOrders() {
    return Column(
      children: slowOrders.map((order) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            child: _buildOrderDetail(order),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderDetail(Map<String, dynamic> order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOrderDetailWithIcon(
          Icons.confirmation_number,
          'رقم الطلب',
          order['_id'] ?? 'غير متوفر',
          Colors.blue,
        ),
        _buildOrderDetailWithIcon(
          Icons.person,
          'الزبون',
          order['username'] ?? 'غير متوفر',
          Colors.purple,
        ),
        _buildOrderDetailWithIcon(
          Icons.phone,
          'رقم الزبون',
          order['customerPhone'] ?? 'غير متوفر',
          Colors.orange,
        ),
        _buildOrderDetailWithIcon(
          Icons.location_on,
          'عنوان التوصيل',
          order['deliveryAddress'] ?? 'غير متوفر',
          Colors.red,
        ),
        _buildOrderDetailWithIcon(
          Icons.attach_money,
          'السعر الكلي',
          '${order['totalPrice']}₪' ?? 'غير متوفر',
          Colors.green,
        ),
        const Divider(thickness: 1.5),
      ],
    );
  }
}
