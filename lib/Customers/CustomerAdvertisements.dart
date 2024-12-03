import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/Admin/RequestDelivery.dart';
import 'dart:io';

class CustomerAdvertisement extends StatefulWidget {
  const CustomerAdvertisement({super.key});

  @override
  State<CustomerAdvertisement> createState() => _CustomerAdvertisementState();
}

class _CustomerAdvertisementState extends State<CustomerAdvertisement> {
  String adText =
      'هذا هو نص الإعلان المقدم من قِطاف. يمكن للمستخدمين قراءة التفاصيل هنا.';
  File? adImageFile; // لتخزين الصورة المختارة من المعرض
  final ImagePicker _picker = ImagePicker(); // مهيّئ اختيار الصور

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 3, // عدد الإعلانات
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.6), // توهج داخلي أبيض
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
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/trees.png', // تعديل المسار للصور
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
                  Text(
                    adText,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),

                  // صورة الإعلان بعرض الشاشة
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: adImageFile != null
                        ? Image.file(
                            adImageFile!,
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
                              builder: (context) => const RequestDelivery()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF556B2F),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('انضم إلينا'),
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
