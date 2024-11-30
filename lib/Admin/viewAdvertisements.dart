import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ViewAdvertisement extends StatefulWidget {
  const ViewAdvertisement({super.key});

  @override
  State<ViewAdvertisement> createState() => _ViewAdvertisementState();
}

class _ViewAdvertisementState extends State<ViewAdvertisement> {
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
                  // السطر الخاص بالاسم وقائمة الخيارات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog();
                          } else if (value == 'delete') {
                            _showDeleteDialog();
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
                      onPressed: () {},
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

  // نافذة تعديل الإعلان
  void _showEditDialog() {
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
                onPressed: () async {
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      adImageFile = File(pickedFile.path);
                    });
                  }
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
  void _showDeleteDialog() {
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
              // منطق حذف الإعلان
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
