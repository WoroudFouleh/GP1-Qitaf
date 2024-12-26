import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/config.dart';

class DeliveryPage extends StatefulWidget {
  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ManageDeliveryScreen(),
    );
  }
}

class ManageDeliveryScreen extends StatefulWidget {
  @override
  _ManageDeliveryScreenState createState() => _ManageDeliveryScreenState();
}

class _ManageDeliveryScreenState extends State<ManageDeliveryScreen> {
  List<Map<String, dynamic>> allDeliveries = [
    {
      'name': 'سامي بدر',
      'phone': '972598126148+',
      'city': 'رام الله',
      'image': null,
      'rating': 4.5,
    },
    {
      'name': 'رامي خالد',
      'phone': '970599778821+',
      'city': 'نابلس',
      'image': 'assets/images/profilew.png',
      'rating': 4.0,
    },
    {
      'name': 'علي حسن',
      'phone': '970599123456+',
      'city': 'جنين',
      'image': null,
      'rating': 3.5,
    },
    {
      'name': 'محمد عادل',
      'phone': '970592334455+',
      'city': 'رام الله',
      'image': 'assets/images/profilew.png',
      'rating': 5.0,
    },
  ];
  List<dynamic> deliveryMen = [];
  bool isLoading = true;
  List<dynamic> filteredDeliveries = [];
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    fetchDeliveryMen();
    //filteredDeliveries = allDeliveries;
  }

  Future<void> fetchDeliveryMen() async {
    final response = await http.get(
      Uri.parse(getAllDeliveryMens),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          deliveryMen = data['deliveryMen'];
          isLoading = false; // Update the lands list with the response data
          filteredDeliveries = deliveryMen;
        });
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

  Future<void> deleteDelivery(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$deleteDeliveryMan/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await fetchDeliveryMen(); // Refresh the ads
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("delivery deleted successfully")),
        );
      } else {
        print("Failed to delete delivery: ${response.statusCode}");
      }
    } catch (error) {
      print("Error deleting ad: $error");
    }
  }

  void filterByCity(String city) {
    setState(() {
      filteredDeliveries = deliveryMen
          .where((delivery) => delivery['location'] == city)
          .toList();
    });
  }

  void resetFilter() {
    setState(() {
      filteredDeliveries = deliveryMen;
      selectedCity = null;
    });
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                'حذف',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Icon(Icons.warning, color: Colors.red),
            ],
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد حذف هذا الموصل؟',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.cancel, color: Colors.grey),
              label: const Text(
                'لا',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  filteredDeliveries.removeWhere((item) => item['_id'] == id);
                  allDeliveries.removeWhere((item) => item['_id'] == id);
                });
                deleteDelivery(id);
                Navigator.of(context).pop();
                _showSuccessDialog();
              },
              icon: const Icon(Icons.check, color: Colors.green),
              label: const Text(
                'نعم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                'تم حذف الموصل بنجاح!',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              Icon(Icons.check_circle, color: Colors.green, size: 40),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.done, color: Colors.green),
              label: const Text(
                'تم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            alignment: AlignmentDirectional.centerEnd,
            value: selectedCity,
            hint: const Text(
              'اختر المدينة',
              textAlign: TextAlign.right,
            ),
            items: deliveryMen
                .map((delivery) => delivery['location'] as String?)
                .toSet()
                .where((city) => city != null)
                .map((city) => DropdownMenuItem<String>(
                      value: city!,
                      child: Text(city, textAlign: TextAlign.right),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                filterByCity(value);
                setState(() {
                  selectedCity = value;
                });
              }
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          if (selectedCity != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: resetFilter,
                icon: const Icon(Icons.refresh, color: Colors.blue),
                label: const Text(
                  'إعادة التصفية',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: deliveryMen.length,
              itemBuilder: (context, index) {
                final deliveryMan = filteredDeliveries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      backgroundImage: deliveryMan['profileImage'] != null
                          ? NetworkImage(deliveryMan['profileImage']!)
                          : null,
                      child: deliveryMan['profileImage'] == null
                          ? Text(
                              deliveryMan['firstName']![0],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                '${deliveryMan['firstName']} ${deliveryMan['lastName']}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerRight,
                          child: RatingBar.builder(
                            initialRating: deliveryMan['rate']!.toDouble(),
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20.0,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                deliveryMan['rate'] = rating;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'رقم الهاتف: ${deliveryMan['phoneNumber']}',
                      textAlign: TextAlign.right,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(deliveryMan['_id']!),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
