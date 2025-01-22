import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/config.dart';
import 'package:login_page/services/notification_service.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class RequestDelivery extends StatefulWidget {
  final token;
  const RequestDelivery({@required this.token, Key? key}) : super(key: key);

  @override
  State<RequestDelivery> createState() => _RequestDeliveryState();
}

class _RequestDeliveryState extends State<RequestDelivery> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phoneCode;
  String? _phoneNumber;
  String? _selectedCity;
  String? _idNumber;
  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedYear;
  PlatformFile? _selectedLicenseFile;
  String? username;
  late String adminFCM;
  late String adminID;
  final List<String> cities = [
    'القدس',
    'رام الله',
    'نابلس',
    'الخليل',
    'بيت لحم',
    'غزة',
    'طولكرم',
    'جنين',
    'قلقيلية',
    'سلفيت',
    'أريحا',
    'القدس الشرقية'
  ];

  final List<String> days =
      List.generate(31, (index) => (index + 1).toString());
  final List<String> months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];
  final List<String> years =
      List.generate(100, (index) => (2024 - index).toString());
  Future<void> fetchAdminFcmToken() async {
    try {
      print("on fetch");
      // Query Firestore for a user with the same email as the owner
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: 'qitaf2025@gmail.com')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        setState(() {
          adminFCM = userDoc['fcmToken'] ?? "";
          adminID = userDoc.id; // Get the FCM token
        });
        print("Owner's FCM token: $adminFCM");
        print("Owner's document ID: $adminID");

        await NotificationService.instance.sendNotificationToSpecific(
          adminFCM,
          'طلب عامل توصيل جديد',
          'طلب عمل جديد كعامل توصيل مع قطاف',
        );
        await NotificationService.instance.saveNotificationToFirebase(
            adminFCM,
            'طلب عامل توصيل جديد',
            'لقد تلقيت طلب عمل جديد كعامل توصيل في قطاف. اضغط لمراجعة الطلب',
            adminID,
            'delivery');
      } else {
        print("failed");
      }
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _selectedLicenseFile = result.files.first;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedLicenseFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى رفع رخصة القيادة')),
        );
        return;
      }

      _formKey.currentState?.save();

      final url = Uri.parse(sendDeliveryWorkRequest); // Backend endpoint

      try {
        final request = http.MultipartRequest('POST', url)
          ..fields['firstName'] = _firstName ?? ''
          ..fields['lastName'] = _lastName ?? ''
          ..fields['email'] = _email ?? ''
          ..fields['phoneNumber'] = '${_phoneCode ?? ''}${_phoneNumber ?? ''}'
          ..fields['city'] = _selectedCity ?? ''
          ..fields['idNumber'] = _idNumber ?? ''
          ..fields['birthDate'] = jsonEncode({
            'day': _selectedDay ?? '',
            'month': _selectedMonth ?? '',
            'year': _selectedYear ?? '',
          });

        // Attach the file
        request.files.add(
          await http.MultipartFile.fromPath(
            'licenseFile',
            _selectedLicenseFile!.path!,
            filename: _selectedLicenseFile!.name,
          ),
        );

        final response = await request.send();

        final responseData = await response.stream.bytesToString();

        if (response.statusCode == 201) {
          final data = jsonDecode(responseData);
          final expirationDate = data['expirationDate'];
          _showResultDialog(
              context,
              'تم التأكد من صلاحية الرخصة، يرجى انتظار رد من مالكي التطبيق للتأكيد على قبولك',
              'تاريخ انتهاء الرخصة: $expirationDate',
              isSuccess: true);
          fetchAdminFcmToken();
        } else {
          final data = jsonDecode(responseData);
          final expirationDate = data['expirationDate'];
          _showResultDialog(
              context,
              'لم يتم قبول الطلب بسبب عدم صلاحبية تاريخ الرخصة',
              'تاريخ انتهاء الرخصة (إن وجد): ${expirationDate ?? "غير متوفر"}',
              isSuccess: false);
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الإرسال: $error')),
        );
      }
    }
  }

  void _showResultDialog(BuildContext context, String title, String content,
      {bool isSuccess = true}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Rounded corners
        ),
        titlePadding: EdgeInsets.zero, // Remove default padding
        contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            // Success or Error Icon
            CircleAvatar(
              radius: 30,
              backgroundColor: isSuccess ? Colors.green : Colors.red,
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 40,
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSuccess
                    ? const Color.fromARGB(255, 0, 0, 0)
                    : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          content,
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'طلب توصيل',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // الصورة المربعة
              Center(
                child: Container(
                  width: 450,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/delivery.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // First Name
                    TextFormField(
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        label: const Align(
                          alignment: Alignment.centerRight,
                          child: Text('الاسم الأول'),
                        ),
                        hintText: 'أدخل اسمك الأول',
                        hintStyle: const TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSaved: (value) => _firstName = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال اسمك الأول';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25.0),
                    // Last Name
                    TextFormField(
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        label: const Align(
                          alignment: Alignment.centerRight,
                          child: Text('اسم العائلة'),
                        ),
                        hintText: 'أدخل اسم العائلة',
                        hintStyle: const TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSaved: (value) => _lastName = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال اسم العائلة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25.0),
                    // Last Name
                    TextFormField(
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        label: const Align(
                          alignment: Alignment.centerRight,
                          child: Text('البريد الإلكتروني '),
                        ),
                        hintText: 'أدخل بريدك الإلكتروني ',
                        hintStyle: const TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSaved: (value) => _email = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى  ادخال البريد الالكتروني';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25.0),
                    // Phone Number with Country Code
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: DropdownButtonFormField<String>(
                            value: _phoneCode ??
                                '+970', // Ensure _phoneCode has an initial value
                            onChanged: (value) {
                              setState(() {
                                _phoneCode = value;
                              });
                            },
                            items: ['+970', '+972'].map((code) {
                              return DropdownMenuItem(
                                value: code,
                                child: Text(code),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              label: const Text('المقدمة'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            textAlign:
                                TextAlign.right, // Right alignment for Arabic
                            decoration: InputDecoration(
                              label: const Align(
                                alignment: Alignment.centerRight,
                                child: Text('رقم الهاتف'),
                              ),
                              hintText: 'أدخل رقم هاتفك',
                              hintStyle: const TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onSaved: (value) => _phoneNumber = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال رقم الهاتف';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25.0),
                    // ID Number
                    TextFormField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        label: const Align(
                          alignment: Alignment.centerRight,
                          child: Text('رقم الهوية'),
                        ),
                        hintText: 'أدخل رقم الهوية',
                        hintStyle: const TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSaved: (value) => _idNumber = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال رقم الهوية';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25.0),
                    // City Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                      items: cities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        label: const Align(
                          alignment: Alignment.centerRight,
                          child: Text('اختار المدينة'),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'يرجى اختيار المدينة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25.0),
                    // Date Dropdowns
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedYear,
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value;
                              });
                            },
                            items: years.map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              label: const Align(
                                alignment: Alignment.centerRight,
                                child: Text('السنة'),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'يرجى اختيار السنة';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedMonth,
                            onChanged: (value) {
                              setState(() {
                                _selectedMonth = value;
                              });
                            },
                            items: months.map((month) {
                              return DropdownMenuItem(
                                value: month,
                                child: Text(month),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              label: const Align(
                                alignment: Alignment.centerRight,
                                child: Text('الشهر'),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'يرجى اختيار الشهر';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDay,
                            onChanged: (value) {
                              setState(() {
                                _selectedDay = value;
                              });
                            },
                            items: days.map((day) {
                              return DropdownMenuItem(
                                value: day,
                                child: Text(day),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              label: const Align(
                                alignment: Alignment.centerRight,
                                child: Text('اليوم'),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'يرجى اختيار اليوم';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                    // رفع رخصة القيادة
                    const Text(
                      'رفع رخصة القيادة',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(
                        Icons.upload_file,
                        color: Colors.white, // لون الأيقونة أبيض
                      ),
                      label: const Text(
                        'اختر ملف',
                        style: TextStyle(
                          color: Colors.white, // لون النص أبيض
                          fontWeight: FontWeight.bold, // النص بولد
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromRGBO(15, 99, 43, 1), // لون الزر
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              0), // زوايا مستقيمة (مربع الشكل)
                        ),
                        minimumSize: const Size(
                            double.infinity, 50), // عرض كامل وارتفاع مناسب
                      ),
                    ),

                    if (_selectedLicenseFile != null) ...[
                      const SizedBox(height: 10.0),
                      Text(
                        ' ${_selectedLicenseFile!.name} :الملف المحدد',
                        style: const TextStyle(color: Colors.black54),
                        textAlign: TextAlign.right,
                      ),
                    ],
                    const SizedBox(height: 25.0),
                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (_selectedLicenseFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى رفع رخصة القيادة'),
                              ),
                            );
                          } else {
                            // Handle form submission
                          }
                        }
                      },
                      child: ElevatedButton(
                        onPressed: () {
                          _submitForm();
                          // handle form submission
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0), // تقليل المسافة داخل الزر
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // زوايا مستديرة
                          ),
                          textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold), // النص بولد
                          minimumSize: const Size(400, 50), // تقليل حجم الزر
                        ),
                        child: const Text(
                          '  إرسال الطلب ',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
