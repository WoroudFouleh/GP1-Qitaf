import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/Admin/RequestDelivery.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/config.dart';

class ViewAdvertisement extends StatefulWidget {
  const ViewAdvertisement({super.key});

  @override
  State<ViewAdvertisement> createState() => _ViewAdvertisementState();
}

class _ViewAdvertisementState extends State<ViewAdvertisement> {
  String adText =
      'هذا هو نص الإعلان المقدم من قِطاف. يمكن للمستخدمين قراءة التفاصيل هنا.';
  // File? adImageFile; // لتخزين الصورة المختارة من المعرض
  // final ImagePicker _picker = ImagePicker(); // مهيّئ اختيار الصور

  List<dynamic> advertisements = [];
  bool isLoading = true;
  String? _imagePath; // لتخزين المسار للصورة التي يتم اختيارها
  Uint8List? imageBytes;
  @override
  void initState() {
    super.initState();
    fetchAdvertisements(); // Fetch ads when the widget initializes
  }

  Future<void> _pickImage({String? id}) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Read the image as bytes
      imageBytes = await pickedFile.readAsBytes();
    }
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

  Future<void> deleteAdvertisement(String adId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$deleteCustomerAd/$adId'), // Replace with your delete API endpoint
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            advertisements.removeWhere((ad) => ad['_id'] == adId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم حذف الإعلان بنجاح')),
          );
        } else {
          print("Error deleting ad: ${data['message']}");
        }
      } else {
        print("Failed to delete ad: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting ad: $e");
    }
  }

  Future<void> editAdvertisement(
      String adId, String newText, Uint8List? newImage) async {
    try {
      print("hereeee");
      String? imageBase64;
      if (newImage != null) {
        imageBase64 =
            base64Encode(newImage); // Encode Uint8List to Base64 string
      }
      print("new texr: $newText");
      print("adid: $adId");
      print("new image: $newImage");

      final response = await http.put(
        Uri.parse(editCustomerAd), // Replace with your edit API endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "id": adId,
          "text": newText,
          "image": imageBase64, // Send the image if provided
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            final index = advertisements.indexWhere((ad) => ad['_id'] == adId);
            if (index != -1) {
              advertisements[index]['text'] = newText;
              if (imageBase64 != null) {
                advertisements[index]['image'] = imageBase64;
              }
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تعديل الإعلان بنجاح')),
          );
        } else {
          print("Error editing ad: ${data['message']}");
        }
      } else {
        print("Failed to edit ad: ${response.statusCode}");
      }
    } catch (e) {
      print("Error editing ad: $e");
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
                            // السطر الخاص بالاسم وقائمة الخيارات
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      adText = ad['text'];
                                      imageBytes = base64Decode(ad['image']);

                                      _showEditDialog(ad['_id'], ad['text']);
                                    } else if (value == 'delete') {
                                      _showDeleteDialog(ad['_id']);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text('تعديل الإعلان'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('حذف الإعلان'),
                                      ),
                                    ];
                                  },
                                ),
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
                                  ad['title'],
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.right,
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: ad['image'] != null
                                  ? Image.memory(
                                      base64Decode(ad['image'])!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/p1.jpg',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
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
                                        builder: (context) =>
                                            const RequestDelivery()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xFF556B2F),
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
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

  // نافذة تعديل الإعلان
  // نافذة تعديل الإعلان
  void _showEditDialog(String adId, String text) {
    TextEditingController textController = TextEditingController(text: adText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تعديل الإعلان',
          textAlign: TextAlign.right,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'تعديل النص:',
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textController,
                maxLines: 3,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'تغيير الصورة:',
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  _pickImage();
                },
                icon: const Icon(Icons.image),
                label: const Text('اختر صورة جديدة'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF556B2F),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF556B2F),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                adText = textController.text;
                editAdvertisement(adId, adText, imageBytes);
              });
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF556B2F),
            ),
          ),
        ],
      ),
    );
  }

  // نافذة حذف الإعلان
  void _showDeleteDialog(String adId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الإعلان'),
        content: const Text('هل أنت متأكد من حذف هذا الإعلان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteAdvertisement(adId);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
