import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html; // استيراد html لدعم اختيار الملفات من الويب

import 'package:login_page/screens/custom_drawer.dart';
import 'package:login_page/screens/map_screen.dart'; // To handle JSON decoding
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AddProductionLine extends StatefulWidget {
  final String token;
  final String token2;

  const AddProductionLine(
      {required this.token, super.key, required this.token2});

  @override
  State<AddProductionLine> createState() => _AddProductionLineState();
}

class _AddProductionLineState extends State<AddProductionLine> {
  Uint8List? _image;
  File? selectedImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fruitTypeController = TextEditingController();
  final TextEditingController _lineDescriptionController =
      TextEditingController();
  final TextEditingController _cityDescriptionController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _timeRequiredController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _preparationTimeController =
      TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();

  String? _selectedCity;
  String? _selectedUnit;
  String? _selectedTimeUnit;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final List<String> _selectedDays = [];
  String? selectedCity;
  LatLng? locationCoordinates;

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
  final List<String> timeUnits = ['دقائق ', 'ساعات', 'أيام'];
  final List<String> units = ['كيلو', 'لتر', 'علبة'];
  final List<String> days = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة'
  ];
  late String ownerUsername;

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    ownerUsername = jwtDecoderToken['username'] ?? 'No username';
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
        _locationController.text = "${result['name']}"; // Fill the TextField
        // _coordController.text =
        //     "${result['position'].latitude}, ${result['position'].longitude}";
        locationCoordinates = result['position'];
        print("Name: ${result['name']}, Coordinates: ${result['position']}");
      });

      // Optionally save the result to the database
      //_saveLocationToDatabase(result['name'], result['position']);
    }
  }

  void addProductionLine() async {
    try {
      // Prepare the request body
      var reqBody = {
        'ownerUsername': ownerUsername,
        "image": _image != null ? base64Encode(_image!) : null,
        "lineName": _nameController.text,
        "materialType": _fruitTypeController.text,
        "description": _lineDescriptionController.text,
        "phoneNumber": _phoneNumber.text,
        "city": _selectedCity,
        "location": _locationController.text,
        "coordinates": {
          "lat": locationCoordinates!.latitude,
          "lng": locationCoordinates!.longitude,
        },
        "timeOfPreparation": _preparationTimeController.text,
        "unitTimeOfPreparation": _selectedTimeUnit,
        "price": int.tryParse(_priceController.text),
        "quantityUnit": _selectedUnit,
        "startWorkTime": _startTime.toString().substring(10, 15),
        "endWorkTime": _endTime.toString().substring(10, 15),
        "datesOfWork": _selectedDays,
      };

      // Make the POST request
      var response = await http.post(
        Uri.parse(registerProductionLine), // Ensure the URL is correct
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          print('Request sent successfully');
          showCustomDialog(
            context: context,
            icon: Icons.check,
            iconColor: const Color.fromRGBO(15, 99, 43, 1),
            title: "تمّ بنجاح",
            message: "تمّ إضافة المنتج بنجاح!",
            buttonText: "حسناً",
          );
        } else {
          print('Error sending request: ${jsonResponse['message']}');
        }
      } else {
        var errorResponse = jsonDecode(response.body);
        print('Error: ${errorResponse['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme:
            const IconThemeData(color: const Color.fromRGBO(15, 99, 43, 1)),
        titleTextStyle: const TextStyle(
          color: const Color.fromRGBO(15, 99, 43, 1),
          fontWeight: FontWeight.bold,
          fontSize: 20,
          fontFamily: 'CustomArabicFont',
        ),
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'إضافة خط إنتاج',
            textAlign: TextAlign.right,
          ),
        ),
      ),
      endDrawer: CustomDrawer(
        token: widget.token,
        token2: widget.token2,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                width: 280,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 25),

              // اسم خط الإنتاج ونوع الثمار في سطر واحد
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fruitTypeController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'المادة الخام المطلوبة',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'اسم خط الإنتاج',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // وصف خط الإنتاج
              TextFormField(
                controller: _lineDescriptionController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'وصف خط الإنتاج',
                  labelStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneNumber,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف للتواصل',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                      //         ScreenMap(), // استدعاء صفحة الخريطة
                      //   ),
                      // );
                      _navigateToMap();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // اختيار المدينة

              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCity,
                    items: cities.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCity = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'المدينة',
                      labelStyle: const TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: // الموقع
                      TextFormField(
                    controller: _locationController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: 'الموقع',
                      labelStyle: const TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 25.0),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTimeUnit,
                      items: timeUnits.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTimeUnit = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'وحدة الزمن',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: // وقت الجهوزية الاختياري
                        TextFormField(
                      controller: _preparationTimeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'عدد ساعات جهوز الطلب ',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // السعر والوحدة
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'السعر',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // الوقت المطلوب
              // تحديد ساعات العمل
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onTap: () async {
                        _endTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        setState(() {});
                      },
                      textAlign: TextAlign.right,
                      readOnly: true,
                      controller: TextEditingController(
                          text: _endTime?.format(context) ?? ''),
                      decoration: InputDecoration(
                        labelText: 'إلى الساعة',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      onTap: () async {
                        _startTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        setState(() {});
                      },
                      textAlign: TextAlign.right,
                      readOnly: true,
                      controller: TextEditingController(
                          text: _startTime?.format(context) ?? ''),
                      decoration: InputDecoration(
                        labelText: 'من الساعة',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: days.map((day) {
                  return FilterChip(
                    label: Text(day),
                    selected: _selectedDays.contains(day),
                    onSelected: (bool isSelected) {
                      setState(() {
                        if (isSelected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  addProductionLine();
                  // تنفيذ منطق الإضافة
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
                ),
                child: const Text('إضافة',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white)),
              ),
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
