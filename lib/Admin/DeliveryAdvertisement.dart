import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;

class DeliveryAdvertisements extends StatefulWidget {
  const DeliveryAdvertisements({super.key});

  @override
  State<DeliveryAdvertisements> createState() => _DeliveryAdvertisementsState();
}

class _DeliveryAdvertisementsState extends State<DeliveryAdvertisements> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _buttonTextController = TextEditingController();
  Uint8List? imageBytes;

  Future<void> addAdvertisement() async {
    try {
      final response = await http.post(
        Uri.parse('YOUR_API_URL_HERE'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': _titleController.text,
          'text': _descriptionController.text,
          'buttonText': _buttonTextController.text,
          'image': imageBytes != null ? base64Encode(imageBytes!) : null,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Advertisement added successfully")),
        );
      } else {
        print("Failed to add ad: ${response.statusCode}");
      }
    } catch (error) {
      print("Error adding ad: $error");
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = html.FileUploadInputElement()..accept = 'image/*';
    imagePicker.click();
    imagePicker.onChange.listen((event) {
      final file = imagePicker.files?.first;
      final reader = html.FileReader();

      if (file != null) {
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            imageBytes = reader.result as Uint8List?;
          });
        });
      }
    });
  }

  void _submitAdvertisement() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        imageBytes == null ||
        _buttonTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة جميع الحقول!')),
      );
    } else {
      addAdvertisement();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF556B2F),
        title: const Text(
          'إنشاء إعلان جديد',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'عنوان الإعلان',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'أدخل عنوان الإعلان',
                        hintTextDirection: TextDirection.rtl,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF556B2F)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'نص الإعلان',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'أدخل نص الإعلان',
                        hintTextDirection: TextDirection.rtl,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF556B2F)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'نص الزر',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _buttonTextController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'أدخل نص الزر',
                        hintTextDirection: TextDirection.rtl,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF556B2F)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'إضافة صورة',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_a_photo, color: Colors.white),
                      label: const Text(
                        'إضافة صورة',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF556B2F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (imageBytes != null)
                      Center(
                        child: Image.memory(
                          imageBytes!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitAdvertisement,
                        child: const Text(
                          'إنشاء الإعلان',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF556B2F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
