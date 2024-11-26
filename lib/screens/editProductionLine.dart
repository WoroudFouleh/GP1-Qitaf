import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/screens/ProfilePage.dart';
import 'config.dart';
import 'package:http/http.dart' as http;
import 'custom_drawer.dart'; // استدعاء الـ Drawer المخصص
import 'changepass.dart'; // استدعاء صفحة تغيير كلمة السر

class EditProductionLine extends StatefulWidget {
  final String lineName;
  final String lineId;
  final String phoneNum;
  final String image;
  final String description;
  final String preparationTime;
  final String preparationUnit;
  final String city;
  final String location;
  final String cropType;
  final int price;
  final String quantityUnit;
  final List<String> days;
  final String startTime;
  final String endTime;
  final String token;
  const EditProductionLine(
      {super.key,
      required this.lineName,
      required this.lineId,
      required this.image,
      required this.description,
      required this.preparationTime,
      required this.preparationUnit,
      required this.city,
      required this.location,
      required this.cropType,
      required this.price,
      required this.quantityUnit,
      required this.days,
      required this.startTime,
      required this.endTime,
      required this.token,
      required this.phoneNum});

  @override
  State<EditProductionLine> createState() => _EditProductionLineState();
}

class _EditProductionLineState extends State<EditProductionLine> {
  final TextEditingController _productionLineController =
      TextEditingController();
  final TextEditingController _fruitTypeController = TextEditingController();
  final TextEditingController _productionLineDescriptionController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _readyHoursController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _phoneNumCont = TextEditingController();
  final TextEditingController _workDaysController = TextEditingController();
  final TextEditingController _startTimesController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _preparationUniy = TextEditingController();

  // قيم افتراضية للحقول

  Uint8List? _image;
  File? selectedImage;
  void LineUpdate() async {
    try {
      // Convert image to base64 if an image is selected
      //String? base64Image = _image != null ? base64Encode(_image!) : null;

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'lineName': _productionLineController.text,
        'materialType': _fruitTypeController.text,
        'description': _productionLineDescriptionController.text,
        'phoneNumber': _phoneNumCont.text,
        'price': int.tryParse(_priceController.text) ?? 0,
        'city': _cityController.text,
        'location': _locationController.text,
        'timeOfPreparation': _readyHoursController.text,
        'unitTimeOfPreparation': _preparationUniy.text,
        'quantityUnit': _unitController.text,
        'startWorkTime': _startTimesController.text,
        'endWorkTime': _endTimeController.text,
        'datesOfWork':
            _workDaysController.text.split(',').map((e) => e.trim()).toList(),
        'image': _image != null ? base64Encode(_image!) : null,
      };

      // Convert the request body to JSON format
      String jsonBody = jsonEncode(requestBody);

      // Send the request to the backend
      var response = await http.put(
        Uri.parse(
            '$updateProductionLine/${widget.lineId}'), // Replace with your backend URL
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

  void removeLine() async {
    try {
      // Prepare the order details

      // Send the request to your backend API
      final response = await http.delete(
        Uri.parse('$deleteLine/${widget.lineId}'), // Replace with your API URL
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
    _productionLineController.text = widget.lineName;
    _fruitTypeController.text = widget.cropType;
    _productionLineDescriptionController.text = widget.description;
    _cityController.text = widget.city;
    _locationController.text = widget.location;
    _readyHoursController.text = widget.preparationTime;
    _priceController.text = widget.price.toString();
    _unitController.text = widget.quantityUnit;
    _workDaysController.text = widget.days.toString();
    _startTimesController.text = widget.startTime.toString().substring(10, 15);
    _endTimeController.text = widget.endTime.toString().substring(10, 15);
    _preparationUniy.text = widget.preparationUnit;
    _phoneNumCont.text = widget.phoneNum;
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
                'تعديل معلومات خط الإنتاج',
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
                    widget.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              base64Decode(widget.image),
                              width: 200, // تكبير عرض الصورة
                              height: 150, // تكبير ارتفاع الصورة
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: Image.asset(
                              "assets/images/q1.jpg",
                              width: 250, // تكبير عرض الصورة
                              height: 190, // تكبير ارتفاع الصورة
                              fit: BoxFit.cover,
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      left: 140, // تغيير موضع زر التعديل
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
                buildEditableItem('اسم خط الإنتاج', _productionLineController,
                    CupertinoIcons.star),
                const SizedBox(height: 10),
                buildEditableItem(
                    'نوع الثمار', _fruitTypeController, CupertinoIcons.heart),
                const SizedBox(height: 10),
                buildEditableItem('وصف خط الإنتاج',
                    _productionLineDescriptionController, CupertinoIcons.info),
                const SizedBox(height: 10),
                buildEditableItem(
                    'المدينة', _cityController, CupertinoIcons.location),
                const SizedBox(height: 10),
                buildEditableItem('الموقع', _locationController,
                    CupertinoIcons.location_fill),
                const SizedBox(height: 10),
                buildEditableItem('المدة الزمنية اللازمة لإنتاج المنتج',
                    _readyHoursController, CupertinoIcons.time),
                const SizedBox(height: 10),
                buildEditableItem(
                    'وحدة الزمن   ', _preparationUniy, CupertinoIcons.time),
                const SizedBox(height: 10),
                buildEditableItem('السعر لإنتاج الوحدة بالشيكل  ',
                    _priceController, CupertinoIcons.money_dollar),
                const SizedBox(height: 10),
                buildEditableItem(
                    'الوحدة', _unitController, CupertinoIcons.square_on_square),
                const SizedBox(height: 10),
                buildEditableItem(' أوقات العمل - البداية',
                    _startTimesController, CupertinoIcons.time),
                const SizedBox(height: 10),
                buildEditableItem('أوقات العمل - نهاية ', _endTimeController,
                    CupertinoIcons.time),
                const SizedBox(height: 10),
                buildEditableItem('  رقم الهاتف للتواصل ', _phoneNumCont,
                    CupertinoIcons.phone),
                const SizedBox(height: 10),
                buildEditableItem('أيام الدوام', _workDaysController,
                    CupertinoIcons.calendar),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      LineUpdate();
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
                        size: 30,
                      ),
                      Text("المعرض"),
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
                        size: 30,
                      ),
                      Text("الكاميرا"),
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

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
      _image = await selectedImage!.readAsBytes();
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
      _image = await selectedImage!.readAsBytes();
      Navigator.of(context).pop();
    }
  }

  // دالة التأكيد على الحذف
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
                      removeLine();
                      // تنفيذ عملية الحذف هنا
                      Navigator.of(context).pop();
                    },
                    // ignore: prefer_const_constructors
                    child: Row(
                      children: const [
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
