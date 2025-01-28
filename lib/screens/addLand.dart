import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // لإضافة مكتبة تنسيق التواريخ
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';
import 'dart:html' as html; // استيراد html لدعم اختيار الملفات من الويب

import 'package:login_page/screens/custom_drawer.dart';
import 'package:login_page/screens/map_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:login_page/screens/animition_notification_bar.dart';

class AddLand extends StatefulWidget {
  final String token;
  final String token2;

  const AddLand({required this.token, Key? key, required this.token2})
      : super(key: key);

  @override
  State<AddLand> createState() => _AddLandState();
}

class _AddLandState extends State<AddLand> {
  Uint8List? _image;
  File? selectedImage;
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

  String? selectedCity;
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cropNameController =
      TextEditingController(); // إضافة حقل لاسم المحصول
  final TextEditingController _landAreaController =
      TextEditingController(); // إضافة حقل لمساحة الأرض بالدونم
  final TextEditingController _workerRateController =
      TextEditingController(); // إضافة حقل لأجرة العامل بالساعة
  final TextEditingController _workersCountController =
      TextEditingController(); // إضافة حقل لعدد العمال
  final TextEditingController _landNameController = TextEditingController();
  // إنشاء مفتاح للنموذج
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // إضافة متغيرات التاريخ والوقت
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  late String username;
  LatLng? locationCoordinates;

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No username';
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
        _streetController.text = "${result['name']}"; // Fill the TextField
        // _coordController.text =
        //     "${result['position'].latitude}, ${result['position'].longitude}";
        locationCoordinates = result['position'];
        print("Name: ${result['name']}, Coordinates: ${result['position']}");
      });

      // Optionally save the result to the database
      //_saveLocationToDatabase(result['name'], result['position']);
    }
  }

  void registerLand() async {
    try {
      // Validate the input fields
      if (_landNameController.text.isNotEmpty &&
          _landAreaController.text.isNotEmpty &&
          _workerRateController.text.isNotEmpty &&
          _workersCountController.text.isNotEmpty &&
          _cropNameController.text.isNotEmpty &&
          selectedCity != null &&
          _startDate != null &&
          _endDate != null &&
          _startTime != null &&
          _endTime != null) {
        // Format start and end dates and times
        String formattedStartDate = _startDate!.toIso8601String();
        String formattedEndDate = _endDate!.toIso8601String();
        String formattedStartTime = _startTime!.format(context);
        String formattedEndTime = _endTime!.format(context);

        // Create request body
        var reqBody = {
          'image': _image != null ? base64Encode(_image!) : null,
          "username": username,
          "landName": _landNameController.text,
          "cropType": _cropNameController.text,
          "workerWages": int.tryParse(_workerRateController.text),
          "landSpace": int.tryParse(_landAreaController.text),
          "numOfWorkers": int.tryParse(_workersCountController.text),
          "city": selectedCity,
          "location": _streetController.text,
          "coordinates": {
            "lat": locationCoordinates!.latitude,
            "lng": locationCoordinates!.longitude,
          },
          "startDate": formattedStartDate,
          "endDate": formattedEndDate,
          "startTime": formattedStartTime,
          "endTime": formattedEndTime,
        };

        var response = await http.post(
          Uri.parse(addLand), // Ensure this URL matches your backend route
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(reqBody),
        );

        if (response.statusCode == 201) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status']) {
            // showNotification('تم إضافة الأرض بنجاح');
            print("land added successfuly");
            showCustomDialog(
              context: context,
              icon: Icons.check,
              iconColor: const Color.fromRGBO(15, 99, 43, 1),
              title: "تمّ بنجاح",
              message: "!تمّ إضافة الأرض بنجاح",
              buttonText: "حسناً",
            );
            updatePostCount();
            // Optionally clear fields or navigate away
          } else {
            print('حدث خطأ أثناء إضافة الأرض');
          }
        } else {
          var errorResponse = jsonDecode(response.body);
          print("here");
          print('حدث خطأ: ${errorResponse['message'] ?? response.statusCode}');
        }
      } else {
        print('يرجى ملء جميع الحقول');
      }
    } catch (e) {
      print('حدث خطأ: $e');
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

  @override
  Widget build(BuildContext context) {
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
            'إضافة أرض زراعية ',
            textAlign: TextAlign.right, // محاذاة النص لليمين
          ),
        ),
      ),
      endDrawer: CustomDrawer(
        token: widget.token,
        token2: widget.token2,
      ),
      body: SingleChildScrollView(
        // إضافة SingleChildScrollView
        child: Center(
          child: Form(
            key: _formKey, // استخدام المفتاح هنا
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // لتقليل حجم العمود
              children: [
                // الصورة في شكل مستطيل
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 50),
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

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly, // محاذاة الحقول بالتساوي
                  children: [
                    const SizedBox(width: 10), // مسافة بين الحقلين
                    // حقل إدخال اسم المحصول
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.4, // تعديل عرض الحقل لاسم المحصول بالنسبة لعرض الشاشة
                      child: TextFormField(
                        controller: _cropNameController, // الربط مع المتغير
                        textAlign:
                            TextAlign.right, // محاذاة النص داخل الحقل لليمين
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى ادخال اسم المحصول';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment
                                .centerRight, // محاذاة النص داخل الـ label لليمين
                            child: Text('اسم المحصول'),
                          ),
                          hintText: 'ادخل اسم المحصول',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          alignLabelWithHint:
                              true, // لمحاذاة الـ label مع الـ hint إذا كان الحقل طويلًا
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.4, // تعديل عرض الحقل لاسم الأرض بالنسبة لعرض الشاشة
                      child: TextFormField(
                        controller: _landNameController, // الربط مع المتغير
                        textAlign:
                            TextAlign.right, // محاذاة النص داخل الحقل لليمين
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى ادخال اسم الأرض';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment
                                .centerRight, // محاذاة النص داخل الـ label لليمين
                            child: Text('اسم الأرض'),
                          ),
                          hintText: 'ادخل اسم الأرض',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          alignLabelWithHint:
                              true, // لمحاذاة الـ label مع الـ hint إذا كان الحقل طويلًا
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25.0),

                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // 80% من عرض الشاشة
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_location_alt,
                          color: const Color.fromRGBO(15, 99, 43, 1),
                          size: 30,
                        ),
                        onPressed: () {
                          _navigateToMap();
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCity,
                          hint: const Text(
                            'اختار مدينتك',
                            textAlign: TextAlign.right,
                          ),
                          items: cities.map((city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city, textAlign: TextAlign.right),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCity = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'يرجى اختيار اسم مدينتك';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25.0),
                // Street Field
                // حقل وصف الموقع
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // عرض مناسب لحجم الشاشة
                  child: TextFormField(
                    controller: _streetController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'قم بوصف موقعك (اسم المنطقة..،الخ)';
                      }
                      return null;
                    },
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      label: const Align(
                        alignment: Alignment.centerRight,
                        child: Text('وصف الموقع '),
                      ),
                      hintText: 'ادخل موقعك',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),

// حقل مساحة الأرض وأجرة العامل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.4, // تعديل عرض الحقل لمساحة الأرض بالنسبة لعرض الشاشة
                      child: TextFormField(
                        controller: _landAreaController, // الربط مع المتغير
                        textAlign: TextAlign.right,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ادخل مساحة الأرض بالدونم';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('مساحة الأرض (دونم)'),
                          ),
                          hintText: 'ادخل المساحة',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.4, // تعديل عرض الحقل لأجرة العامل بالنسبة لعرض الشاشة
                      child: TextFormField(
                        controller: _workerRateController, // الربط مع المتغير
                        textAlign: TextAlign.right,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'أجرة العامل بالساعة';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('أجرة العامل/ساعة'),
                          ),
                          hintText: 'أجرة العامل',
                          hintStyle: const TextStyle(color: Colors.black26),
                          suffixText: '₪', // رمز الشيكل
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25.0),

// حقل إدخال عدد العمال
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // عرض مناسب لحجم الشاشة
                  child: TextFormField(
                    controller: _workersCountController, // الربط مع المتغير
                    textAlign: TextAlign.right,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ادخل عدد العمال';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: const Align(
                        alignment: Alignment.centerRight,
                        child: Text('عدد العمال'),
                      ),
                      hintText: 'ادخل عدد العمال',
                      hintStyle: const TextStyle(color: Colors.black26),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            if (_startDate != null &&
                                pickedDate.isBefore(_startDate!)) {
                              // إذا كان تاريخ الانتهاء قبل تاريخ البدء
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "تاريخ الانتهاء لا يمكن أن يكون قبل تاريخ البدء!")),
                              );
                            } else {
                              _endDate = pickedDate;
                            }
                          });
                        }
                      },
                      child: Text(
                        _endDate == null
                            ? 'حدد تاريخ الانتهاء'
                            : DateFormat('yyyy-MM-dd').format(_endDate!),
                        style: const TextStyle(
                            fontSize: 18,
                            color: const Color.fromRGBO(
                                15, 99, 43, 1)), // تكبير الخط وتغيير اللون
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _startDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        _startDate == null
                            ? 'حدد تاريخ البدء'
                            : DateFormat('yyyy-MM-dd').format(_startDate!),
                        style: const TextStyle(
                            fontSize: 18,
                            color: const Color.fromRGBO(
                                15, 99, 43, 1)), // تكبير الخط وتغيير اللون
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _endTime ?? TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            if (_startTime != null &&
                                (pickedTime.hour < _startTime!.hour ||
                                    (pickedTime.hour == _startTime!.hour &&
                                        pickedTime.minute <
                                            _startTime!.minute))) {
                              // إذا كان وقت الانتهاء قبل وقت البدء
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "وقت الانتهاء لا يمكن أن يكون قبل وقت البدء!")),
                              );
                            } else {
                              _endTime = pickedTime;
                            }
                          });
                        }
                      },
                      child: Text(
                        _endTime == null
                            ? 'حدد وقت الانتهاء'
                            : _endTime!.format(context),
                        style: const TextStyle(
                            fontSize: 18,
                            color: const Color.fromRGBO(
                                15, 99, 43, 1)), // تكبير الخط وتغيير اللون
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _startTime ?? TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _startTime = pickedTime;
                          });
                        }
                      },
                      child: Text(
                        _startTime == null
                            ? 'حدد وقت البدء'
                            : _startTime!.format(context),
                        style: const TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(
                                255, 7, 104, 23)), // تكبير الخط وتغيير اللون
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25.0),

                // زر الإضافة
                ElevatedButton(
                  onPressed: () {
                    // التحقق من صحة النموذج
                    if (_formKey.currentState!.validate()) {
                      // هنا يمكنك إضافة منطق الإضافة
                      registerLand();
                    }
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
              ],
            ),
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
