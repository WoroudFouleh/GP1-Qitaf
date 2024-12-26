import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // For rating stars

class EditLand2 extends StatefulWidget {
  const EditLand2({super.key});

  @override
  State<EditLand2> createState() => _EditLand2State();
}

class _EditLand2State extends State<EditLand2> {
  final TextEditingController _landnameController = TextEditingController();
  final TextEditingController _treenameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _moneyController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _worknumController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String landname = ' اسم الارض';
  String treename = 'زيتون';
  String address = 'نابلس، شارع 24';
  String money = '10 NIS';
  String area = '1024 D';
  String workernum = '10 ';
  String date = '10/12/2024 - 15/12/2024';
  String time = '9:00 AM - 4:00 PM';

  Uint8List? _image;
  File? selectedImage;
  bool agreePersonalData = true;

  // Sample worker data
  List<Map<String, String>> workers = [
    {"name": "محمد علي", "profilePic": "assets/images/profile.png"},
    {"name": "خالد بدر", "profilePic": "assets/images/profile.png"},
    {"name": "سامي مسعود", "profilePic": "assets/images/profile.png"},
  ];

  @override
  void initState() {
    super.initState();
    _landnameController.text = landname;
    _treenameController.text = treename;
    _addressController.text = address;
    _moneyController.text = money;
    _areaController.text = area;
    _worknumController.text = workernum;
    _dateController.text = date;
    _timeController.text = time;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 12, 123, 17),
            ),
            titleTextStyle: const TextStyle(
              color: Color.fromARGB(255, 11, 130, 27),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            elevation: 0,
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                ' تعديل معلومات الأرض',
                textAlign: TextAlign.right,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              _image!,
                              width: 200,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: Image.asset(
                              "assets/images/p1.jpg",
                              width: 250,
                              height: 190,
                              fit: BoxFit.cover,
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      left: 200,
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

                // New button under the image
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showWorkersDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.green,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'عرض العمال',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Editable fields and buttons
                buildEditableItem(
                    'اسم الأرض', _landnameController, CupertinoIcons.crop),
                const SizedBox(height: 10),
                buildEditableItem(
                    'ثمار المحصول ', _treenameController, CupertinoIcons.tree),
                const SizedBox(height: 10),
                buildEditableItem(
                    'العنوان', _addressController, CupertinoIcons.location),
                const SizedBox(height: 10),
                buildEditableItem('اجرة العامل / ساعة', _moneyController,
                    CupertinoIcons.money_dollar),
                const SizedBox(height: 10),
                buildEditableItem('مساحة الأرض (دونم)', _areaController,
                    CupertinoIcons.device_phone_landscape),
                const SizedBox(height: 10),
                buildEditableItem(
                    'عدد العمّال', _worknumController, CupertinoIcons.group),
                const SizedBox(height: 10),
                buildEditableItem(
                    'تاريخ العمل', _dateController, CupertinoIcons.calendar),
                const SizedBox(height: 10),
                buildEditableItem(
                    'ساعة العمل ', _timeController, CupertinoIcons.time),
                const SizedBox(height: 20),

                // Save changes button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Save changes logic here
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                    child: const Text(
                      'حفظ التغييرات',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Delete button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDeleteConfirmationDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.red,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    child: const Text(
                      'حذف المنشور',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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

  // Editable item widget
  Widget buildEditableItem(
      String title, TextEditingController controller, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: const Color.fromARGB(255, 14, 101, 23).withOpacity(.2),
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

  void showWorkersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'قائمة العمال',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                children: [
                  // Title with border and frame
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'العمّال الذين تم قبولهم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Worker list
                  Expanded(
                    child: ListView.builder(
                      itemCount: workers.length,
                      itemBuilder: (context, index) {
                        var worker = workers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(worker["profilePic"]!),
                          ),
                          title: Text("${worker['name']} "),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red, // Red color for delete icon
                            ),
                            onPressed: () {
                              showDeleteConfirmationDialog2(context, worker);
                            },
                          ),
                          subtitle: RatingBar.builder(
                            initialRating: 3,
                            minRating: 1,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green, // Text color (white)
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold, // Bold text
                  ),
                ),
                child: const Text("إغلاق"),
              ),
            ],
          ),
        );
      },
    );
  }

// Delete confirmation dialog
  void showDeleteConfirmationDialog2(
      BuildContext context, Map<String, String> worker) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'هل أنت متأكد أنك تريد حذف هذا العامل؟',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the confirmation dialog
                },
                child: const Text("إلغاء"),
              ),
              TextButton(
                onPressed: () {
                  // Logic to delete the worker
                  // You can remove the worker from the list here
                  workers.remove(worker);
                  Navigator.pop(context); // Close the confirmation dialog
                  // Optionally close the workers dialog as well
                  Navigator.pop(context);
                },
                child: const Text("حذف"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Delete confirmation dialog
  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'هل أنت متأكد من حذف المنشور؟',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("إلغاء"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Delete post logic
                },
                child: const Text("حذف"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Image picker options
  void showImagePickerOption(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("اختيار صورة"),
          actions: [
            TextButton(
              onPressed: () async {
                final ImagePicker _picker = ImagePicker();
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    _image = File(image.path).readAsBytesSync();
                    selectedImage = File(image.path);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("كاميرا"),
            ),
            TextButton(
              onPressed: () async {
                final ImagePicker _picker = ImagePicker();
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _image = File(image.path).readAsBytesSync();
                    selectedImage = File(image.path);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("مكتبة الصور"),
            ),
          ],
        );
      },
    );
  }
}
