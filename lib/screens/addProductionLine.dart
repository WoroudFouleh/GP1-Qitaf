import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AddProductionLine extends StatefulWidget {
  final String token;
  const AddProductionLine({required this.token, super.key});

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

  final List<String> cities = ['رام الله', 'نابلس', 'الخليل', 'جنين'];
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
        "timeOfPreparation": _preparationTimeController.text,
        "unitTimeOfPreparation": _selectedTimeUnit,
        "price": int.tryParse(_priceController.text),
        "quantityUnit": _selectedUnit,
        "startWorkTime": _startTime.toString(),
        "endWorkTime": _endTime.toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 11, 108, 45)),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 11, 110, 29),
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
                  showImagePickerOption(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  backgroundColor: const Color.fromARGB(255, 18, 116, 22),
                ),
                child: const Text('إضافة صورة',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white)),
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
                        labelText: 'نوع الثمار',
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
              TextFormField(
                controller: _phoneNumber,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف للتواصل  ',
                  labelStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
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
                        labelText: 'عدد ساعات جهوز الطلب (اختياري)',
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
                  backgroundColor: const Color.fromARGB(255, 18, 116, 22),
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
                      Icon(Icons.image, color: Colors.green, size: 35),
                      SizedBox(height: 5),
                      Text('من المعرض',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
                      Icon(Icons.camera, color: Colors.green, size: 35),
                      SizedBox(height: 5),
                      Text('من الكاميرا',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      _image = await selectedImage!.readAsBytes();
      setState(() {});
    }
    Navigator.pop(context);
  }

  void _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      _image = await selectedImage!.readAsBytes();
      setState(() {});
    }
    Navigator.pop(context);
  }
}
