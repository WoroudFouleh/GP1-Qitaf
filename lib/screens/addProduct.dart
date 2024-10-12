import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

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

  String? _selectedCity;
  String? _selectedCategory;
  String? _selectedUnit;
  String? _selectedPriceUnit;

  final List<String> cities = ['رام الله', 'نابلس', 'الخليل', 'جنين'];
  final List<String> categories = ['محصول', 'منتج غذائي', 'منتج غير غذائي'];
  final List<String> units = ['كيلو', 'لتر', 'علبة'];

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
          color: Color.fromARGB(255, 11, 108, 45), // لون الأيقونات
        ),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 11, 110, 29), // لون العنوان
          fontWeight: FontWeight.bold, // جعل العنوان غامق
          fontSize: 20, // حجم الخط
        ),
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'إضافة منتج زراعي ',
            textAlign: TextAlign.right, // محاذاة النص لليمين
          ),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            // Drawer options as per your original code...
          ],
        ),
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
                  showImagePickerOption(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 50), // تكبير حجم الزر
                  backgroundColor: const Color.fromARGB(255, 18, 116, 22),
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
                        labelText: 'الكمية',
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
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriceUnit,
                      items: units.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPriceUnit = newValue;
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
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      textDirection:
                          TextDirection.rtl, // النص من اليمين إلى الشمال
                      decoration: InputDecoration(
                        labelText: 'السعر',
                        labelStyle: const TextStyle(fontSize: 14),
                        hintText: 'ادخل السعر',
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
              DropdownButtonFormField<String>(
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
              const SizedBox(height: 25.0),

              // وصف موقع المنتج
              TextFormField(
                controller: _locationDescriptionController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl, // النص من اليمين إلى الشمال
                decoration: InputDecoration(
                  labelText: 'وصف الموقع',
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

              // وصف المنتج
              TextFormField(
                controller: _productDescriptionController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl, // النص من اليمين إلى الشمال
                decoration: InputDecoration(
                  labelText: 'وصف المنتج',
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
                  // منطق الإضافة
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 50), // تكبير حجم الزر
                  backgroundColor: const Color.fromARGB(255, 18, 116, 22),
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
