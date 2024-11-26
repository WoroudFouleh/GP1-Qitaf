import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/ProfilePage.dart';
import 'package:login_page/screens/owner_home.dart';
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'custom_drawer.dart'; // استدعاء الـ Drawer المخصص
import 'changepass.dart'; // استدعاء صفحة تغيير كلمة السر

class EditLand extends StatefulWidget {
  final String landName;
  final String landId;

  final String image;
  final String cropType;
  final int workerWages;
  final int landSpace;
  final int numOfWorkers;
  final String city;
  final String location;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String token;
  final String ownerusername;

  const EditLand(
      {super.key,
      required this.landName,
      required this.landId,
      required this.image,
      required this.cropType,
      required this.workerWages,
      required this.landSpace,
      required this.numOfWorkers,
      required this.city,
      required this.location,
      required this.startDate,
      required this.endDate,
      required this.startTime,
      required this.endTime,
      required this.token,
      required this.ownerusername});

  @override
  State<EditLand> createState() => _EditLandState();
}

class _EditLandState extends State<EditLand> {
  final TextEditingController _landnameController = TextEditingController();
  final TextEditingController _treenameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _moneyController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _worknumController = TextEditingController();
  final TextEditingController _startdateController = TextEditingController();
  final TextEditingController _starttimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  // قيم افتراضية للحقول

  Uint8List? _image;
  File? selectedImage;
  bool agreePersonalData = true;
  void LandUpdate() async {
    try {
      // Convert image to base64 if an image is selected
      //String? base64Image = _image != null ? base64Encode(_image!) : null;

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'landName': _landnameController.text,
        'cropType': _treenameController.text,
        'workerWages': int.tryParse(_moneyController.text) ?? 0,
        'landSpace': int.tryParse(_areaController.text) ?? 0,
        'numOfWorkers': int.tryParse(_worknumController.text) ?? 0,
        'city': _addressController.text,
        'location': _locationController.text,
        'startDate': _startdateController.text,
        'endDate': _endDateController.text,
        'startTime': _starttimeController.text,
        'endTime': _endTimeController.text,
        'image': _image != null ? base64Encode(_image!) : null,
      };

      // Convert the request body to JSON format
      String jsonBody = jsonEncode(requestBody);

      // Send the request to the backend
      var response = await http.put(
        Uri.parse(
            '$updateLand/${widget.landId}'), // Replace with your backend URL
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonBody,
      );

      // Check the response status
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Success - show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح!')),
        );
      } else {
        // Server error - handle accordingly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Handle any exceptions during the API call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void removeLand() async {
    try {
      // Prepare the order details

      // Send the request to your backend API
      final response = await http.delete(
        Uri.parse('$deleteLand/${widget.landId}'), // Replace with your API URL
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حذف المنشور بنجاح")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(token: widget.token),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("حدث خطأ أثناء حذف المنشور")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الاتصال بالخادم")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // تعيين القيم الافتراضية في الـ TextEditingController
    _landnameController.text = widget.landName;
    _treenameController.text = widget.cropType;
    _addressController.text = widget.city;
    _locationController.text = widget.location;
    _moneyController.text = widget.workerWages.toString();
    _areaController.text = widget.landSpace.toString();
    _worknumController.text = widget.numOfWorkers.toString();
    _startdateController.text = widget.startDate.toString().substring(0, 10);
    _endDateController.text = widget.endDate.toString().substring(0, 10);
    _starttimeController.text = widget.startTime;
    _endTimeController.text = widget.endTime;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تعيين اتجاه النص من اليمين إلى اليسار
      child: DefaultTabController(
        length: 4, // عدد التبويبات
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
              fontFamily: 'CustomArabicFont',
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
          //endDrawer: const CustomDrawer(), // استخدام الـ CustomDrawer هنا
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
                            child: widget.image != null
                                ? Image.memory(
                                    base64Decode(widget.image!),
                                    fit: BoxFit.cover,
                                    width: 200.0,
                                    height: 150.0,
                                  )
                                : Image.asset('assets/images/lands.jpg'),
                          )
                        : ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: widget.image != null
                                ? Image.memory(
                                    base64Decode(widget.image!),
                                    fit: BoxFit.cover,
                                    width: 250.0,
                                    height: 190.0,
                                  )
                                : Image.asset('assets/images/lands.jpg'),
                          ),
                    Positioned(
                      bottom: 0,
                      left: 200, // تغيير موضع زر التعديل
                      child: IconButton(
                        onPressed: () {
                          showImagePickerOption(context);
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                const SizedBox(height: 20),
                buildEditableItem(
                    'اسم الأرض', _landnameController, CupertinoIcons.crop),
                const SizedBox(height: 10),
                buildEditableItem(
                    'ثمار المحصول ', _treenameController, CupertinoIcons.tree),
                const SizedBox(height: 10),
                buildEditableItem(
                    ' المدينة', _addressController, CupertinoIcons.location),
                const SizedBox(height: 10),
                buildEditableItem(
                    'الموقع', _locationController, CupertinoIcons.location),
                const SizedBox(height: 10),
                buildEditableItem(' اجرة العامل / ساعة', _moneyController,
                    CupertinoIcons.money_dollar),
                const SizedBox(height: 10),
                buildEditableItem(' مساحة الأرض (دونم) ', _areaController,
                    CupertinoIcons.device_phone_landscape),
                const SizedBox(height: 10),
                buildEditableItem(
                    'عدد العمّال', _worknumController, CupertinoIcons.group),
                const SizedBox(height: 10),
                buildEditableItem('تاريخ بداية العمل', _startdateController,
                    CupertinoIcons.calendar),
                const SizedBox(height: 10),
                buildEditableItem('تاريخ نهايةالعمل', _endDateController,
                    CupertinoIcons.calendar),
                const SizedBox(height: 10),
                buildEditableItem('ساعة بداية العمل ', _starttimeController,
                    CupertinoIcons.time),
                const SizedBox(height: 10),
                buildEditableItem('ساعة نهايةالعمل', _endTimeController,
                    CupertinoIcons.calendar),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      LandUpdate();
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
                        color: Colors.green, // اللون الأخضر للنص
                      ),
                    ),
                    child: const Text(
                      'حفظ التغييرات',
                      style: TextStyle(
                        color: Colors.green, // النص أخضر
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
                      // عرض نافذة تأكيد حذف المنشور
                      showDeleteConfirmationDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10), // تصغير حجم الزر
                      backgroundColor: Colors.red, // اللون الأحمر للخلفية
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, // خط عريض
                        fontSize: 18, // حجم أكبر للنص
                      ),
                    ),
                    child: const Text(
                      'حذف المنشور',
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

  Widget buildEditableItem2(
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
                        color: Colors.green,
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

  // اختيار صورة من المعرض
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _image = bytes;
      });
    }
  }

  // اختيار صورة من الكاميرا
  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _image = bytes;
      });
    }
  }

// عرض نافذة التأكيد قبل الحذف
  Future<void> showDeleteConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl, // جعل اتجاه النص من اليمين لليسار
          child: AlertDialog(
            title: const Text(
              'تأكيد الحذف',
              style: TextStyle(
                fontWeight: FontWeight.bold, // النص عريض
                color: Colors.black, // لون النص أسود
              ),
            ),
            content: const Text(
              'هل أنت متأكد أنك تريد حذف هذا المنشور؟',
              style: TextStyle(
                fontWeight: FontWeight.bold, // النص عريض
                color: Colors.black, // لون النص أسود
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // لجعل الأزرار جنب بعض
                children: [
                  // زر إلغاء
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.cancel,
                            color: Colors.green), // أيقونة الإلغاء
                        SizedBox(width: 8),
                        Text(
                          'إلغاء',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // النص عريض
                            color: Colors.black, // لون النص أسود
                          ),
                        ),
                      ],
                    ),
                  ),
                  // زر حذف
                  TextButton(
                    onPressed: () {
                      removeLand();
                      // تنفيذ عملية الحذف هنا
                      // Navigator.of(context).pop();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.delete,
                            color: Colors.red), // أيقونة الحذف باللون الأحمر
                        SizedBox(width: 8),
                        Text(
                          'حذف',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // النص عريض
                            color: Colors.black, // لون النص أسود
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            backgroundColor: Colors.white, // خلفية النافذة بيضاء
          ),
        );
      },
    );
  }
}
