import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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

  List<Map<String, dynamic>> filteredDeliveries = [];
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    filteredDeliveries = allDeliveries;
  }

  void filterByCity(String city) {
    setState(() {
      filteredDeliveries =
          allDeliveries.where((delivery) => delivery['city'] == city).toList();
    });
  }

  void resetFilter() {
    setState(() {
      filteredDeliveries = allDeliveries;
      selectedCity = null;
    });
  }

  void _showDeleteDialog(String name) {
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
                  filteredDeliveries
                      .removeWhere((item) => item['name'] == name);
                  allDeliveries.removeWhere((item) => item['name'] == name);
                });
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
            items: allDeliveries
                .map((delivery) => delivery['city'] as String?)
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
              itemCount: filteredDeliveries.length,
              itemBuilder: (context, index) {
                final deliveryMan = filteredDeliveries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      backgroundImage: deliveryMan['image'] != null
                          ? AssetImage(deliveryMan['image']!)
                          : null,
                      child: deliveryMan['image'] == null
                          ? Text(
                              deliveryMan['name']![0],
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
                                deliveryMan['name']!,
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
                            initialRating: deliveryMan['rating']!,
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
                                deliveryMan['rating'] = rating;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'رقم الهاتف: ${deliveryMan['phone']}',
                      textAlign: TextAlign.right,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(deliveryMan['name']!),
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
