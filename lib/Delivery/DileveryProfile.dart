import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/screens/changepass.dart';

// استدعاء الـ Drawer المخصص

class DeliveryProfile extends StatefulWidget {
  const DeliveryProfile({super.key});

  @override
  State<DeliveryProfile> createState() => _DeliveryProfileState();
}

class _DeliveryProfileState extends State<DeliveryProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // قيم افتراضية للحقول
  String name = 'ورود فوله';
  String phone = '+97256706470';
  String address = 'نابلس، شارع 24';
  String email = 'woroudfouleh@gmail.com';
  Uint8List? _image;
  File? selectedImage;
  bool agreePersonalData = true;

  @override
  void initState() {
    super.initState();
    // تعيين القيم الافتراضية في الـ TextEditingController
    _nameController.text = name;
    _phoneController.text = phone;
    _addressController.text = address;
    _emailController.text = email;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تعيين اتجاه النص من اليمين إلى اليسار
      child: DefaultTabController(
        length: 4, // عدد التبويبات
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 80, backgroundImage: MemoryImage(_image!))
                        : const CircleAvatar(
                            radius: 80,
                            backgroundImage:
                                AssetImage("assets/images/profilew.png"),
                          ),
                    Positioned(
                      bottom: 0,
                      left: 110,
                      child: IconButton(
                        onPressed: () {
                          showImagePickerOption(context);
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                const SizedBox(height: 20),
                buildEditableItem(
                    'الاسم', _nameController, CupertinoIcons.person),
                const SizedBox(height: 10),
                buildEditableItem(
                    'رقم الهاتف', _phoneController, CupertinoIcons.phone),
                const SizedBox(height: 10),
                buildEditableItem(
                    'العنوان', _addressController, CupertinoIcons.location),
                const SizedBox(height: 10),
                buildEditableItem(
                    'البريد الإلكتروني', _emailController, CupertinoIcons.mail),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // استدعاء الدالة لحفظ التغييرات
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10), // تصغير حجم الزر
                      backgroundColor: Colors.white, // اللون الأبيض
                      side: const BorderSide(color: Colors.grey), // حدود رمادية
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, // خط عريض
                        fontSize: 18, // حجم أكبر للنص
                        color: const Color.fromRGBO(
                            15, 99, 43, 1), // اللون الأخضر للنص
                      ),
                    ),
                    child: const Text(
                      'حفظ التغييرات',
                      style: TextStyle(
                        color: const Color.fromRGBO(15, 99, 43, 1), // النص أخضر
                        fontWeight: FontWeight.bold, // خط عريض
                        fontSize: 18, // تكبير الخط
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // الانتقال إلى صفحة تغيير كلمة المرور
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const Changepass(),
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10), // تصغير حجم الزر
                      backgroundColor: const Color.fromRGBO(
                          15, 99, 43, 1), // اللون الأخضر للخلفية
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, // خط عريض
                        fontSize: 18, // حجم أكبر للنص
                      ),
                    ),
                    child: const Text(
                      'تغيير كلمة السر',
                      style: TextStyle(
                        color: Colors.white, // النص أبيض
                        fontWeight: FontWeight.bold, // خط عريض
                        fontSize: 18, // تكبير الخط
                      ),
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

  // عنصر قابل للتعديل
  Widget buildEditableItem(
      String title, TextEditingController controller, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: const Color.fromRGBO(15, 99, 43, 1).withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: ListTile(
        title: Text(title),
        subtitle: TextField(
          controller: controller,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
        leading: Icon(iconData),
        trailing: Icon(Icons.edit, color: Colors.grey.shade400),
      ),
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _pickImageFromGallery();
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        color: Colors.green,
                        size: 35,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'من المعرض',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _pickImageFromCamera();
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera,
                        color: const Color.fromRGBO(15, 99, 43, 1),
                        size: 35,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'من الكاميرا',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Gallery
  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop(); // close the modal sheet
  }

  // Camera
  Future _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }
}
