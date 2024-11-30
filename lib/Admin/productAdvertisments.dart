import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/Admin/admin_drawer.dart';

class Productadvertisments extends StatefulWidget {
  const Productadvertisments({super.key});

  @override
  State<Productadvertisments> createState() => _ProductAdvertisementsState();
}

class _ProductAdvertisementsState extends State<Productadvertisments> {
  final List<String> _imagePaths = [
    'assets/images/c1.jpg',
    'assets/images/c2.jpg',
    'assets/images/c3.jpg',
  ];

  Future<void> _pickImage({int? index}) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (index != null) {
          // تعديل صورة موجودة
          _imagePaths[index] = pickedFile.path;
        } else {
          // إضافة صورة جديدة
          _imagePaths.add(pickedFile.path);
        }
      });
    }
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذه الصورة؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _imagePaths.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  void _showFullImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain, // لتوسيع الصورة بما يتناسب مع حجم الشاشة
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF556B2F),
        title: const Text(
          'إعلانات المنتجات ',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.right, // جعل العنوان من جهة اليمين
        ),
        actions: const [
          SizedBox(width: 10), // للمحاذاة من اليمين
        ],
        iconTheme: const IconThemeData(
            color: Colors.white), // تغيير لون السهم إلى الأبيض
      ),
      endDrawer: AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: _imagePaths.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _showFullImage(context, _imagePaths[index]),
                        child: Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xFF556B2F), width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            _imagePaths[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _pickImage(index: index),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        left: 5,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _showDeleteConfirmation(context, index),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(),
                  icon: const Icon(Icons.add_a_photo, color: Colors.white),
                  label: const Text('إضافة صورة',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF556B2F),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ التعديلات!')),
                    );
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('حفظ التعديلات',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF556B2F),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
