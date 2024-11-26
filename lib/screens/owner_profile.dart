import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/screens/owner_home.dart';
import 'custom_drawer.dart';
import 'changepass.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class OwnerProfile extends StatefulWidget {
  final token;
  const OwnerProfile({@required this.token, Key? key}) : super(key: key);

  @override
  State<OwnerProfile> createState() => _OwnerProfileState();
}

class _OwnerProfileState extends State<OwnerProfile> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneCodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Uint8List? _image;
  File? selectedImage;
  late String username;

  void userUpdate() async {
    try {
      // Convert image to base64 if an image is selected

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phoneCode': _phoneCodeController.text,
        'phoneNumber': _phoneNumberController.text,
        'city': _cityController.text,
        'street': _streetController.text,
        'email': _emailController.text,
        'profilePhoto': _image != null
            ? base64Encode(_image!)
            : null, // Add the profile photo conditionally
      };

      // Convert the request body to JSON format
      String jsonBody = jsonEncode(requestBody);

      // Send the request to the backend
      var response = await http.put(
        Uri.parse('$updateUser/$username'), // Replace with your backend URL
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonBody,
      );

      // Check the response status
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final newToken = responseData['token'];
        print(newToken);
        // Success - show success message

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OwnerHome(token: newToken),
          ),
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

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    String code = jwtDecoderToken['phoneCode'];
    String phone = jwtDecoderToken['phoneNumber'];
    String firstName = jwtDecoderToken['firstName'];
    String lastName = jwtDecoderToken['lastName'];
    String city = jwtDecoderToken['city'];
    String street = jwtDecoderToken['street'];
    String email = jwtDecoderToken['email'];
    username = jwtDecoderToken['username'];
    String? base64Image =
        jwtDecoderToken['profilePhoto']; // Get the base64 image string

    // Split full name into first and last name
    // List<String> nameParts = fullName.split(' ');
    _firstNameController.text = firstName; // First name
    _lastNameController.text = lastName;
    _phoneCodeController.text = code; // Phone code
    _phoneNumberController.text = phone; // Phone number
    _cityController.text = city; // City
    _streetController.text = street; // Street
    _emailController.text = email; // Email
    // If base64Image is not null, decode it to Uint8List and set _image
    if (base64Image != null) {
      setState(() {
        _image = base64Decode(base64Image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
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
                'الملف الشخصي',
                textAlign: TextAlign.right,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 80, backgroundImage: MemoryImage(_image!))
                        : const CircleAvatar(
                            radius: 80,
                            backgroundImage:
                                AssetImage("assets/images/profilew.png"),
                          ),
                    Positioned(
                      bottom: 0,
                      left: 110,
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
                    'الاسم الأول', _firstNameController, CupertinoIcons.person),
                const SizedBox(height: 10),
                buildEditableItem(
                    'الاسم الأخير', _lastNameController, CupertinoIcons.person),
                const SizedBox(height: 10),
                buildEditableItem(
                    'كود الدولة', _phoneCodeController, CupertinoIcons.phone),
                const SizedBox(height: 10),
                buildEditableItem(
                    'رقم الهاتف', _phoneNumberController, CupertinoIcons.phone),
                const SizedBox(height: 10),
                buildEditableItem(
                    'المدينة', _cityController, CupertinoIcons.location),
                const SizedBox(height: 10),
                buildEditableItem(
                    'الشارع', _streetController, CupertinoIcons.location),
                const SizedBox(height: 10),
                buildEditableItem(
                    'البريد الإلكتروني', _emailController, CupertinoIcons.mail),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // استدعاء الدالة لحفظ التغييرات
                      userUpdate();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                    child: const Text(
                      'حفظ التغييرات',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // الانتقال إلى صفحة تغيير كلمة المرور
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Changepass(token: widget.token),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.green,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    child: const Text(
                      'تغيير كلمة السر',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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

  // Element for editing
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

  // Gallery
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
}
