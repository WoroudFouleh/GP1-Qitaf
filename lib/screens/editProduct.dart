import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/screens/ProfilePage.dart';
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:http/http.dart' as http;
import 'custom_drawer.dart'; // استدعاء الـ Drawer المخصص
import 'changepass.dart'; // استدعاء صفحة تغيير كلمة السر

class EditProduct extends StatefulWidget {
  final String productName;
  final String productType;
  final String productDescription;
  final String city;
  final String location;
  final String profilePhotoBase64;
  final int productPrice;
  final String quantityType;
  final quantityAvailable;
  final String token;
  final String productId;
  final String preparationTime;
  final String preparationUnit;
  const EditProduct(
      {super.key,
      required this.productName,
      required this.productType,
      required this.productDescription,
      required this.city,
      required this.location,
      required this.profilePhotoBase64,
      required this.productPrice,
      required this.quantityType,
      this.quantityAvailable,
      required this.token,
      required this.productId,
      required this.preparationTime,
      required this.preparationUnit});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productCategoryController =
      TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TextEditingController _preparationUnit = TextEditingController();
  // قيم افتراضية للحقول

  Uint8List? _image;
  File? selectedImage;
  bool agreePersonalData = true;
  void ProductUpdate() async {
    try {
      Map<String, dynamic> requestBody = {
        'name': _productNameController.text,
        'type': _productCategoryController.text,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'quantityType': _unitController.text,
        'price': int.tryParse(_priceController.text) ?? 0,
        'city': _cityController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'preparationTime': _durationController.text,
        'preparationTimeUnit': _preparationUnit.text,
        'image': _image != null ? base64Encode(_image!) : null,
      };

      // Convert the request body to JSON format
      String jsonBody = jsonEncode(requestBody);

      // Send the request to the backend
      var response = await http.put(
        Uri.parse(
            '$updateProduct/${widget.productId}'), // Replace with your backend URL
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

  void removeProduct() async {
    try {
      // Prepare the order details

      // Send the request to your backend API
      final response = await http.delete(
        Uri.parse(
            '$deleteProduct/${widget.productId}'), // Replace with your API URL
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
    _productNameController.text = widget.productName;
    _productCategoryController.text = widget.productType;
    _unitController.text = widget.quantityType;
    _quantityController.text = widget.quantityAvailable.toString();
    _durationController.text = widget.preparationTime;
    _priceController.text = widget.productPrice.toString();
    _cityController.text = widget.city;
    _locationController.text = widget.location;
    _descriptionController.text = widget.productDescription;
    _preparationUnit.text = widget.preparationUnit;
    if (widget.profilePhotoBase64 != null) {
      setState(() {
        _image = base64Decode(widget.profilePhotoBase64);
      });
    }
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
                'تعديل معلومات المنتج',
                textAlign: TextAlign.right,
              ),
            ),
          ),
          // endDrawer: const CustomDrawer(), // استخدام الـ CustomDrawer هنا
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    widget.profilePhotoBase64 != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              _image!,
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
                buildEditableItem(
                    'اسم المنتج', _productNameController, CupertinoIcons.cart),
                const SizedBox(height: 10),
                buildEditableItem('صنف المنتج', _productCategoryController,
                    CupertinoIcons.folder),
                const SizedBox(height: 10),
                buildEditableItem(' الكمية المتوفرة', _quantityController,
                    CupertinoIcons.shopping_cart),
                const SizedBox(height: 10),
                buildEditableItem(
                    'الوحدة', _unitController, CupertinoIcons.square_on_square),
                const SizedBox(height: 10),
                buildEditableItem('  السعر للوحدة بالشيكل', _priceController,
                    CupertinoIcons.money_dollar),
                const SizedBox(height: 10),
                buildEditableItem('المدة الزمنية لتحضير الطلب للاستلام ',
                    _durationController, CupertinoIcons.calendar),
                const SizedBox(height: 10),
                buildEditableItem(
                    'وحدة الزمن', _preparationUnit, CupertinoIcons.calendar),
                const SizedBox(height: 10),
                buildEditableItem(
                    'المدينة', _cityController, CupertinoIcons.location),
                const SizedBox(height: 10),
                buildEditableItem('الموقع', _locationController,
                    CupertinoIcons.location_fill),
                const SizedBox(height: 10),
                buildEditableItem('وصف المنتج', _descriptionController,
                    CupertinoIcons.text_bubble),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ProductUpdate();
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
                        Icons.camera_alt,
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

  // التقاط الصورة من المعرض
  Future<void> _pickImageFromGallery() async {
    try {
      final returnImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (returnImage == null) return;

      // Convert to Uint8List to update the image preview
      final imageBytes = await returnImage.readAsBytes();
      setState(() {
        _image = imageBytes;
        selectedImage = File(returnImage.path);
      });
    } catch (e) {
      // Handle the case when there's already an active image picking process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

// Camera
  Future<void> _pickImageFromCamera() async {
    try {
      final returnImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (returnImage == null) return;

      // Convert to Uint8List to update the image preview
      final imageBytes = await returnImage.readAsBytes();
      setState(() {
        _image = imageBytes;
        selectedImage = File(returnImage.path);
      });
    } catch (e) {
      // Handle the case when there's already an active image picking process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  // دالة تأكيد الحذف
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
                    child: Row(
                      children: const [
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
                      removeProduct();
                      // تنفيذ عملية الحذف هنا
                      Navigator.of(context).pop();
                    },
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
