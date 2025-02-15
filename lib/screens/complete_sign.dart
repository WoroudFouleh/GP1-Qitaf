import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/screens/welcome_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';

class CompleteSignUpScreen extends StatefulWidget {
  const CompleteSignUpScreen({super.key});

  @override
  State<CompleteSignUpScreen> createState() => _CompleteSignUpScreenState();
}

class _CompleteSignUpScreenState extends State<CompleteSignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  Uint8List? _image;
  File? selectedImage;
  bool agreePersonalData = true;
  String _userType = 'مستخدم';

  final TextEditingController _usernameController =
      TextEditingController(); // Username controller

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 3,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'أكمل عملية إنشاء حسابك',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w300,
                          color: Color.fromARGB(255, 21, 80, 13),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Add this text above the profile picture
                      const Text(
                        'قم بتحميل صورة ملفك الشخصي',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 15.0),

                      Stack(
                        children: [
                          _image != null
                              ? CircleAvatar(
                                  radius: 120,
                                  backgroundImage: MemoryImage(_image!))
                              : const CircleAvatar(
                                  radius: 120,
                                  backgroundImage: NetworkImage(
                                      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"),
                                ),
                          Positioned(
                              bottom: -0,
                              left: 160,
                              child: IconButton(
                                  onPressed: () {
                                    showImagePickerOption(context);
                                  },
                                  icon: const Icon(Icons.add_a_photo))),
                        ],
                      ),
                      const SizedBox(height: 15.0),

                      TextFormField(
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء ادخال اسم المستخدم';
                          }
                          // Regex to allow only alphanumeric characters
                          final RegExp usernameRegExp =
                              RegExp(r'^[a-zA-Z0-9]+$');
                          if (!usernameRegExp.hasMatch(value)) {
                            return 'يجب أن يكون اسم المستخدم مكونًا من أحرف وأرقام، ولا يمكن أن يحتوي على مسافات أو رموز';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('اسم المستخدم'),
                          ),
                          hintText: ' اسم المستخدم ',
                          alignLabelWithHint: true,
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
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
                      const SizedBox(height: 25.0),

                      const SizedBox(height: 25.0),
                      Row(
                        children: [
                          const Text(':الدخول كَـ'),
                          const SizedBox(width: 10.0),
                          // "Normal" option
                          Row(
                            children: [
                              Radio<String>(
                                value: 'مستخدم',
                                groupValue: _userType,
                                onChanged: (value) {
                                  setState(() {
                                    _userType = value!;
                                  });
                                },
                              ),
                              const Text('مستخدم'),
                            ],
                          ),
                          const SizedBox(width: 20.0),
                          // "Owner" option
                          Row(
                            children: [
                              Radio<String>(
                                value: 'مالك',
                                groupValue: _userType,
                                activeColor:
                                    const Color.fromARGB(255, 18, 92, 27),
                                onChanged: (value) {
                                  setState(() {
                                    _userType = value!;
                                  });
                                },
                              ),
                              const Text('مالك'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Signup button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formSignupKey.currentState!.validate() &&
                    agreePersonalData) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
                  );
                } else if (!agreePersonalData) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please agree to the processing of personal data'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 17, 118, 21),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                textStyle: const TextStyle(
                  fontSize: 18.0, // Font size for the button
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('إنهاء'),
            ),
          ),

          const SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: const Color.fromARGB(255, 241, 243, 246),
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4.5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromGallery();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.image,
                              size: 70,
                            ),
                            Text("المعرض")
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromCamera();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 70,
                            ),
                            Text("الكاميرا")
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Gallery
  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop(); // close the modal sheet
  }

  // Camera
  Future _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }
}
