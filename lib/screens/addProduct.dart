import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';
import 'dart:html' as html; // استيراد html لدعم اختيار الملفات من الويب

import 'package:login_page/screens/custom_drawer.dart';
import 'package:login_page/screens/map_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:login_page/screens/animition_notification_bar.dart';

class AddProduct extends StatefulWidget {
  final String token;
  const AddProduct({required this.token, Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  Uint8List? _image;
  File? selectedImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationDescriptionController =
      TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController(); // حقل لوصف المنتج
  final TextEditingController _ingredientsController =
      TextEditingController(); // حقل للمكونات
  final TextEditingController _preparationTime =
      TextEditingController(); // حقل للمكونات
  String? _selectedCity;
  String? _selectedCategory;
  String? _selectedUnit;
  String? _selectedPriceUnit;
  String? _selectedTimeUnit;

  final List<String> cities = [
    'القدس',
    'بيت لحم',
    'طوباس',
    'رام الله',
    'نابلس',
    'الخليل',
    'جنين',
    'طولكرم',
    'قلقيلية',
    'سلفيت',
    'أريحا',
    'غزة',
    'دير البلح',
    'خان يونس',
    'رفح',
    'الداخل الفلسطيني'
  ];
  final List<String> categories = ['محصول', 'منتج غذائي', 'منتج غير غذائي'];
  final List<String> units = ['كيلو', 'لتر', 'علبة'];
  final List<String> timeUnits = ['دقائق', 'ساعات', 'أيام'];

  late String username;
  LatLng? locationCoordinates;

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No username';
  }

  void registerProduct() async {
    try {
      // Validate the input fields
      if (_nameController.text.isNotEmpty &&
          _quantityController.text.isNotEmpty &&
          _priceController.text.isNotEmpty &&
          _locationDescriptionController.text.isNotEmpty &&
          _productDescriptionController.text.isNotEmpty &&
          _selectedCity != null &&
          _selectedCategory != null &&
          _selectedUnit != null) {
        var reqBody = {
          'image': _image != null ? base64Encode(_image!) : null,
          "username": username,
          "name": _nameController.text,
          "type": _selectedCategory,
          "quantity": int.tryParse(_quantityController.text),
          "quantityType": _selectedUnit,
          "price": int.tryParse(_priceController.text),
          "city": _selectedCity,
          "location": _locationDescriptionController.text,
          "coordinates": {
            "lat": locationCoordinates!.latitude,
            "lng": locationCoordinates!.longitude,
          },
          "description": _productDescriptionController.text,
          "preparationTime": _preparationTime.text,
          "preparationTimeUnit": _selectedTimeUnit
        };

        var response = await http.post(
          Uri.parse(addProduct), // Make sure this URL is correct
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(reqBody),
        );

        if (response.statusCode == 201) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status']) {
            showCustomDialog(
              context: context,
              icon: Icons.check,
              iconColor: const Color.fromRGBO(15, 99, 43, 1),
              title: "تمّ بنجاح",
              message: "تمّ إضافة المنتج بنجاح!",
              buttonText: "حسناً",
            );
            updatePostCount();
            // Optionally clear fields or navigate away
          } else {
            print('حدث خطأ أثناء إضافة المنتج');
          }
        } else {
          var errorResponse = jsonDecode(response.body);
          print('حدث خطأ: ${errorResponse['message'] ?? response.statusCode}');
        }
      } else {
        print('يرجى ملء جميع الحقول');
      }
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  void updatePostCount() async {
    try {
      final response = await http.post(
        Uri.parse(
            '$updatePostNumber/$username'), // Send the URL without the username
        headers: {'Content-Type': 'application/json'},
        // Send the username in the body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          print("posts count updated  successfully");
        } else {
          print("Error updating posts");
        }
      } else {
        print("Error updating posts ");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void _navigateToMap() async {
    // Navigate to the MapScreen and wait for the result
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _locationDescriptionController.text =
            "${result['name']}"; // Fill the TextField
        // _coordController.text =
        //     "${result['position'].latitude}, ${result['position'].longitude}";
        locationCoordinates = result['position'];
        print("Name: ${result['name']}, Coordinates: ${result['position']}");
      });

      // Optionally save the result to the database
      //_saveLocationToDatabase(result['name'], result['position']);
    }
  }

  void showCustomDialog({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String buttonText,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 48.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 12.0),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
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
    // تحقق مما إذا كانت جميع الحقول معبأة
    _quantityController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _locationDescriptionController.text.isNotEmpty &&
        _productDescriptionController.text.isNotEmpty &&
        _ingredientsController.text.isNotEmpty &&
        _selectedCity != null &&
        _selectedCategory != null &&
        _selectedUnit != null &&
        _selectedPriceUnit != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(
          color: const Color.fromRGBO(15, 99, 43, 1), // لون الأيقونات
        ),
        titleTextStyle: const TextStyle(
          color: const Color.fromRGBO(15, 99, 43, 1), // لون العنوان
          fontWeight: FontWeight.bold, // جعل العنوان غامق
          fontSize: 20,
          fontFamily: 'CustomArabicFont', // حجم الخط
        ),
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'إضافة منتج زراعي ',
            textAlign: TextAlign.right, // محاذاة النص لليمين
          ),
        ),
      ),
      endDrawer: CustomDrawer(
        token: widget.token,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 280, // عرض المستطيل
                height: 180, // ارتفاع المستطيل
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), // لتدوير الزوايا
                  image: DecorationImage(
                    image: _image != null
                        ? MemoryImage(_image!)
                        : const NetworkImage(
                                "https://media.istockphoto.com/id/931643150/vector/picture-icon.jpg?s=612x612&w=0&k=20&c=St-gpRn58eIa8EDAHpn_yO4CZZAnGD6wKpln9l3Z3Ok=")
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _pickImageFromDevice(); // استخدام هذه الدالة لاختيار صورة من الجهاز مباشرة
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
                ),
                child: const Text(
                  'إضافة صورة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 25.0),

              // الاسم وصنف المنتج في نفس السطر
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'صنف المنتج',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      textAlign: TextAlign.right,
                      textDirection:
                          TextDirection.rtl, // النص من اليمين إلى الشمال
                      decoration: InputDecoration(
                        label: const Align(
                          alignment: Alignment.centerRight,
                          child: Text('الاسم'),
                        ),
                        labelStyle: const TextStyle(fontSize: 14),
                        hintText: 'ادخل الاسم',
                        hintStyle: const TextStyle(fontSize: 14),
                        hintTextDirection:
                            TextDirection.rtl, // اتجاه الـ hint من اليمين
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25.0),

              // الكمية والوحدة في نفس السطر
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      items: units.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedUnit = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'الوحدة',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      textAlign: TextAlign.right,
                      textDirection:
                          TextDirection.rtl, // النص من اليمين إلى الشمال
                      decoration: InputDecoration(
                        label: const Align(
                          alignment: Alignment.centerRight,
                          child: Text('الكمية'),
                        ),
                        labelStyle: const TextStyle(fontSize: 14),
                        hintText: 'ادخل الكمية',
                        hintStyle: const TextStyle(fontSize: 14),
                        hintTextDirection:
                            TextDirection.rtl, // اتجاه الـ hint من اليمين
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25.0),

              // السعر والوحدة
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      textDirection:
                          TextDirection.rtl, // النص من اليمين إلى الشمال
                      decoration: InputDecoration(
                        label: const Align(
                          alignment: Alignment.centerRight,
                          child: Text(' السعر بالشيكل'),
                        ),
                        labelStyle: const TextStyle(fontSize: 14),
                        hintText: 'أدخل السعر بالشيكل',
                        hintStyle: const TextStyle(fontSize: 14),
                        hintTextDirection:
                            TextDirection.rtl, // اتجاه الـ hint من اليمين
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25.0),
              // اختيار المدينة
              Row(
                children: [
                  Expanded(
                    flex: 2, // تخصيص حجم القائمة المنسدلة
                    child: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      items: cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCity = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'اختر المدينة',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0), // مسافة بين القائمة والزر
                  IconButton(
                    icon: const Icon(
                      Icons.add_location_alt, // أيقونة لإضافة الموقع
                      color: const Color.fromRGBO(15, 99, 43, 1),
                      size: 30,
                    ),
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         MapScreen(), // استدعاء صفحة الخريطة
                      //   ),
                      // );
                      _navigateToMap();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25.0),
              // وصف موقع المنتج
              TextFormField(
                controller: _locationDescriptionController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl, // النص من اليمين إلى الشمال
                decoration: InputDecoration(
                  label: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('وصف الموقع'),
                  ),
                  labelStyle: const TextStyle(fontSize: 14),
                  hintText: 'ادخل وصف الموقع',
                  hintStyle: const TextStyle(fontSize: 14),
                  hintTextDirection:
                      TextDirection.rtl, // اتجاه الـ hint من اليمين
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25.0),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTimeUnit,
                      items: timeUnits.map((String timeUnit) {
                        return DropdownMenuItem<String>(
                          value: timeUnit,
                          child: Text(timeUnit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTimeUnit = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'وحدة الزمن ',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextFormField(
                      controller: _preparationTime,
                      textAlign: TextAlign.right,
                      textDirection:
                          TextDirection.rtl, // النص من اليمين إلى الشمال
                      decoration: InputDecoration(
                        label: const Align(
                          alignment: Alignment.centerRight,
                          child: Text('مدة تحضير الطلب'),
                        ),
                        labelStyle: const TextStyle(fontSize: 14),
                        hintText: 'ادخل المدة اللازمة لجهوزية الطلب',
                        hintStyle: const TextStyle(fontSize: 14),
                        hintTextDirection:
                            TextDirection.rtl, // اتجاه الـ hint من اليمين
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25.0),

              // وصف المنتج
              TextFormField(
                controller: _productDescriptionController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl, // النص من اليمين إلى الشمال
                decoration: InputDecoration(
                  label: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('وصف المنتج'),
                  ),
                  labelStyle: const TextStyle(fontSize: 14),
                  hintText: 'ادخل وصف المنتج',
                  hintStyle: const TextStyle(fontSize: 14),
                  hintTextDirection:
                      TextDirection.rtl, // اتجاه الـ hint من اليمين
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25.0),

              ElevatedButton(
                onPressed: () {
                  registerProduct();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 50), // تكبير حجم الزر
                  backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
                ),
                child: const Text(
                  'إضافة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              // Notification Bar
            ],
          ),
        ),
      ),
    );
  }

  // دالة لاختيار الصورة من الجهاز مباشرة
  void _pickImageFromDevice() async {
    // إنشاء عنصر Input لاختيار الملفات
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*'; // تحديد أن الملفات المقبولة هي الصور فقط
    uploadInput.click(); // محاكاة الضغط على الزر

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files!.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(files[0]);

      reader.onLoadEnd.listen((e) {
        setState(() {
          _image = reader.result as Uint8List?;
        });
      });
    });
  }
}
