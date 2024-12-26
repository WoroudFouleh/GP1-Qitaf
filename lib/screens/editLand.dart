import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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

  List<dynamic> workers = [];

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

  void fetchWorkers() async {
    final response = await http.get(
      Uri.parse('$getWorkers/${widget.landId}'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          workers =
              data['requests']; // Update the lands list with the response data
        });
      } else {
        print("Error fetching requests: ${data['message']}");
      }
    } else {
      print("Failed to load requests: ${response.statusCode}");
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

  void showRatingDialog(BuildContext context, Map<String, dynamic> worker) {
    double rating = 3; // Default initial rating
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'قيّم ${worker['workerFirstname']} ${worker['workerLastname']}',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الرجاء تقييم أداء العامل'),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40,
                onRatingUpdate: (newRating) {
                  rating = newRating; // Update the rating
                },
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Save the rating here if necessary
                print('Rated ${worker['workerFirstname']} with $rating stars');
                rateUser(worker['workerUsername'], rating);
                Navigator.of(context).pop();
              },
              child: const Text('تقييم'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Set the button color
                foregroundColor: Colors.white, // Set the text/icon color
                // padding: const EdgeInsets.symmetric(
                //     horizontal: 10, vertical: 7),
                // Button size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void rateUser(String username, double rate) async {
    print("username: $username");
    try {
      // Prepare the request body
      var reqBody = {
        'username': username,
        "newRate": rate,
      };

      // Make the POST request
      var response = await http.post(
        Uri.parse(rateWorker), // Ensure the URL is correct
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          print('user rated successfully');
          showCustomDialog(
            context: context,
            icon: Icons.check,
            iconColor: Colors.green,
            title: "تمّ بنجاح",
            message: "!تمّ تقييم العامل بنجاح",
            buttonText: "حسناً",
          );
        } else {
          print('Error rating user: ${jsonResponse['message']}');
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
    if (widget.image != null) {
      setState(() {
        _image = base64Decode(widget.image);
      });
    }
    fetchWorkers();
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
              color: Color.fromARGB(255, 11, 108, 45),
            ),
            titleTextStyle: const TextStyle(
              color: Color.fromARGB(255, 11, 108, 45),
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
                                    _image!,
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
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showWorkersDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Color.fromARGB(255, 11, 108, 45),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'عرض العمال',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
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

  void showWorkersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'قائمة العمال',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                children: [
                  // Title with border and frame
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'العمّال الذين تم قبولهم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Worker list
                  Expanded(
                    child: ListView.builder(
                      itemCount: workers.length,
                      itemBuilder: (context, index) {
                        var worker = workers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: MemoryImage(
                                base64Decode(worker['workerProfileImage'])),
                          ),
                          title: Text(
                              "${worker['workerFirstname']} ${worker['workerLastname']}"),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 30, // Red color for delete icon
                            ),
                            onPressed: () {
                              showDeleteConfirmationDialog2(context, worker);
                            },
                          ),
                          subtitle: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            label: const Text('قيّم '),
                            onPressed: () {
                              showRatingDialog(context, worker);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.green, // Set the button color
                              foregroundColor:
                                  Colors.white, // Set the text/icon color
                              // padding: const EdgeInsets.symmetric(
                              //     horizontal: 10, vertical: 7),
                              // Button size
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    30), // Rounded corners
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green, // Text color (white)
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold, // Bold text
                  ),
                ),
                child: const Text("إغلاق"),
              ),
            ],
          ),
        );
      },
    );
  }

  void showDeleteConfirmationDialog2(
      BuildContext context, Map<String, String> worker) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'هل أنت متأكد أنك تريد حذف هذا العامل؟',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the confirmation dialog
                },
                child: const Text("إلغاء"),
              ),
              TextButton(
                onPressed: () {
                  // Logic to delete the worker
                  // You can remove the worker from the list here
                  workers.remove(worker);
                  Navigator.pop(context); // Close the confirmation dialog
                  // Optionally close the workers dialog as well
                  Navigator.pop(context);
                },
                child: const Text("حذف"),
              ),
            ],
          ),
        );
      },
    );
  }
}
