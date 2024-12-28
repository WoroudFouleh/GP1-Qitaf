import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/Admin/RequestDelivery.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/config.dart';

class CustomerAdvertisement extends StatefulWidget {
  final token;
  const CustomerAdvertisement({@required this.token, Key? key})
      : super(key: key);

  @override
  State<CustomerAdvertisement> createState() => _CustomerAdvertisementState();
}

class _CustomerAdvertisementState extends State<CustomerAdvertisement> {
  String adText =
      'هذا هو نص الإعلان المقدم من قِطاف. يمكن للمستخدمين قراءة التفاصيل هنا.';
  File? adImageFile; // لتخزين الصورة المختارة من المعرض
  final ImagePicker _picker = ImagePicker(); // مهيّئ اختيار الصور
  List<dynamic> advertisements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdvertisements(); // Fetch ads when the widget initializes
  }

  Future<void> fetchAdvertisements() async {
    final response = await http.get(
      Uri.parse(getCustomerAds),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          advertisements = data['ads'];
          isLoading = false; // Update the lands list with the response data
        });
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إعلانات قطاف',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        backgroundColor: Color(0xFF556B2F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader
          : advertisements.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد إعلانات متاحة حالياً.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: advertisements.length, // عدد الإعلانات
                  itemBuilder: (context, index) {
                    final ad = advertisements[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white
                                .withOpacity(0.6), // توهج داخلي أبيض
                            spreadRadius: 5,
                            blurRadius: 10,
                          ),
                        ],
                        border: Border.all(color: Color(0xFF556B2F), width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // السطر الخاص بالاسم
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'قِطاف | Qitaf',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        'assets/images/trees.jpeg', // تعديل المسار للصور
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // نص الإعلان
                            Column(
                              children: [
                                Text(
                                  ad['title'] ?? 'عنوان الإعلان',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  ad['text'],
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // صورة الإعلان بعرض الشاشة
                            // Image الإعلان بعرض الشاشة
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: ad['image'] != null
                                    ? Image.memory(
                                        base64Decode(ad['image'])!,
                                        width: 600, // Adjust width as needed
                                        height: 400, // Adjust height as needed
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/p1.jpg',
                                        width: 600, // Adjust width as needed
                                        height: 400, // Adjust height as needed
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // زر انضم إلينا
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RequestDelivery(
                                            token: widget.token)),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xFF556B2F),
                                  textStyle: const TextStyle(
                                    fontSize: 24, // Larger font size
                                    fontWeight: FontWeight.bold,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 40), // Larger padding
                                ),
                                child: Text(ad['buttonText']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
