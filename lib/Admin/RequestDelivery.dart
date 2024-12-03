import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class RequestDelivery extends StatefulWidget {
  const RequestDelivery({super.key});

  @override
  State<RequestDelivery> createState() => _RequestDeliveryState();
}

class _RequestDeliveryState extends State<RequestDelivery> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedCity;
  String? _idNumber;
  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedYear;
  PlatformFile? _selectedLicenseFile;

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
        backgroundColor: const Color(0xFF556B2F),
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
                            value: '+970',
                            items: ['+970', '+972'].map((code) {
                              return DropdownMenuItem(
                                value: code,
                                child: Text(code),
                              );
                            }).toList(),
                            onChanged: (value) {},
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
                        backgroundColor: const Color(0xFF556B2F), // لون الزر
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
                          // handle form submission
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF556B2F),
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
