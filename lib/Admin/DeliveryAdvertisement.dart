import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/config.dart';

class DeliveryAdvertisements extends StatefulWidget {
  const DeliveryAdvertisements({super.key});

  @override
  State<DeliveryAdvertisements> createState() => _DeliveryAdvertisementsState();
}

class _DeliveryAdvertisementsState extends State<DeliveryAdvertisements> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _buttonTextController =
      TextEditingController(); // النص الخاص بالزر
  String? _imagePath; // لتخزين المسار للصورة التي يتم اختيارها
  Uint8List? imageBytes;
  Future<void> addAdvertisement() async {
    try {
      final response = await http.post(
        Uri.parse(addCustomerAd),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': _titleController.text,
          'text': _descriptionController.text,
          'buttonText': _buttonTextController.text,
          'image': imageBytes != null ? base64Encode(imageBytes!) : null,
        }),
      );

      if (response.statusCode == 201) {
        //await fetchAdvertisements(); // Refresh the ads
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Advertisement added successfully")),
        );
      } else {
        print("Failed to add ad: ${response.statusCode}");
      }
    } catch (error) {
      print("Error adding ad: $error");
    }
  }

  Future<void> _pickImage({String? id}) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Read the image as bytes
      imageBytes = await pickedFile.readAsBytes();
    }
  }

  void _submitAdvertisement() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        imageBytes == null ||
        _buttonTextController.text.isEmpty) {
      // إظهار رسالة إذا كانت الحقول غير مكتملة
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة جميع الحقول!')),
      );
    } else {
      addAdvertisement();
      // تنفيذ عملية إرسال الإعلان
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الإعلان بنجاح!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
        title: const Text(
          'إنشاء إعلان جديد',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 800), // تحديد العرض الأقصى
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // عنوان الإعلان
                const Text(
                  'عنوان الإعلان',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'أدخل عنوان الإعلان',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: const Color.fromRGBO(15, 99, 43, 1)),
                    ),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),

                // نص الإعلان
                const Text(
                  'نص الإعلان',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'أدخل نص الإعلان',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: const Color.fromRGBO(15, 99, 43, 1)),
                    ),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),

                // نص الزر
                const Text(
                  'نص الزر',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _buttonTextController,
                  decoration: InputDecoration(
                    hintText: 'أدخل نص الزر',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: const Color.fromRGBO(15, 99, 43, 1),
                      ),
                    ),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),

                // إضافة صورة
                const Text(
                  'إضافة صورة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo, color: Colors.white),
                  label: const Text(
                    'إضافة صورة للإعلان',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
                  ),
                ),
                const SizedBox(height: 16),

                // عرض الصورة
                if (_imagePath != null)
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 300, // عرض محدد للصورة
                          height: 200, // ارتفاع محدد للصورة
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromRGBO(15, 99, 43, 1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                // زر الإرسال
                Center(
                  child: ElevatedButton(
                    onPressed: _submitAdvertisement,
                    child: const Text(
                      'إنشاء الإعلان',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
                      minimumSize: const Size(200, 50), // تحديد حجم الزر
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
