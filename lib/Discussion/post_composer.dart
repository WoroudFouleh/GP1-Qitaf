import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostComposer extends StatefulWidget {
  @override
  _PostComposerState createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  final TextEditingController _postController = TextEditingController();
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('الكاميرا'),
                onTap: () async {
                  Navigator.pop(context);
                  final image =
                      await picker.pickImage(source: ImageSource.camera);
                  setState(() {
                    _pickedImage = image;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('المعرض'),
                onTap: () async {
                  Navigator.pop(context);
                  final image =
                      await picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    _pickedImage = image;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _publishPost() {
    // وظيفة نشر المنشور
    print('نص المنشور: ${_postController.text}');
    if (_pickedImage != null) {
      print('تم اختيار صورة: ${_pickedImage!.path}');
    }
    // تصفية البيانات
    _postController.clear();
    setState(() {
      _pickedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      shadowColor:
          const Color.fromARGB(255, 113, 149, 48), // اللون الأخضر للتوهج
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: const Color.fromARGB(255, 120, 181, 42).withOpacity(0.7),
              width: 2), // الحدود الخضراء
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 234, 244, 234)
                  .withOpacity(0.6), // اللون الأخضر المتوهج
              spreadRadius: 5,
              blurRadius: 15,
              offset: Offset(0, 3), // موضع التوهج
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // المحاذاة من اليمين
                children: [
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/profile.png'),
                    radius: 25,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      decoration: const InputDecoration(
                        hintText: "ماذا يدور في ذهنك؟",
                        border: InputBorder.none,
                      ),
                      textDirection: TextDirection.rtl, // النص من اليمين لليسار
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.image, color: Colors.green[800]),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_pickedImage != null)
                Image.file(
                  File(_pickedImage!.path),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ElevatedButton(
                onPressed: _publishPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  minimumSize: Size(double.infinity, 45), // عرض الزر بالكامل
                ),
                child: Text(
                  "نشر",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
