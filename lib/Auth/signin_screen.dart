import 'package:flutter/material.dart';
import 'package:login_page/Admin/Admin.dart';
import 'package:login_page/Delivery/DileveryHome.dart';
import 'package:login_page/screens/animition_notification_bar.dart';
import 'package:login_page/screens/custom_drawer.dart';
import 'package:login_page/screens/dashboard.dart';
import 'package:login_page/screens/first_screen.dart';
import 'package:login_page/screens/forget_password_screen.dart';
import 'package:login_page/screens/owner_home.dart';
import 'package:login_page/screens/owner_profile.dart';
//import 'package:login_page/screens/forget_password_screen.dart';
//import 'package:login_page/screens/opcode.dart';
import 'package:login_page/screens/signup_screen.dart';
import 'package:login_page/screens/welcome_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/config.dart';
import 'dart:convert';
//import 'animition_notification_bar.dart'; // Import the animated notification bar

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  bool _isObscured = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  late SharedPreferences prefs;

  // State to control the notification visibility
  String _notificationMessage = '';
  Color _notificationColor = Colors.green;
  bool _showNotification = false;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void showNotification(String message,
      {Color backgroundColor = Colors.green}) {
    setState(() {
      _notificationMessage = message;
      _notificationColor = backgroundColor;
      _showNotification = true;
    });

    // Automatically hide the notification after 3 seconds
    Future.delayed(const Duration(seconds: 3), hideNotification);
  }

  void hideNotification() {
    setState(() {
      _showNotification = false;
    });
  }

  void loginUser() async {
    try {
      if (_usernameController.text.isNotEmpty &&
          _passController.text.isNotEmpty) {
        // Check for hardcoded admin credentials
        if (_usernameController.text == "admin" &&
            _passController.text == "admin") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(), // Replace with your AdminPage
            ),
          );
          return;
        }

        // Check for hardcoded delivery credentials
        if (_usernameController.text == "delivery" &&
            _passController.text == "delivery") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DeliveryOrdersPage(), // Replace with your DeliveryPage
            ),
          );
          return;
        }

        // Proceed with API call for other users
        var reqBody = {
          "username": _usernameController.text,
          "password": _passController.text
        };

        var response = await http.post(
          Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody),
        );

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status']) {
            var myToken = jsonResponse['token'];
            var userType = jsonResponse['userType'];
            print('User Type from API: $userType'); // Log userType to debug
            await prefs.setString('token', myToken);
            showNotification('تم تسجيل الدخول بنجاح');

            if (userType == '2') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(token: myToken),
                ),
              );
            } else if (userType == '1') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => dashboard(token: myToken),
                ),
              );
            } else {
              showNotification('خلل في النوع', backgroundColor: Colors.red);
            }

            // Navigate to Welcome Screen or Home Screen
          } else {
            showNotification('بيانات تسجيل الدخول غير صحيحة',
                backgroundColor: Colors.red);
          }
        } else if (response.statusCode == 401) {
          showNotification('خطأ في اسم المستخدم أو كلمة المرور',
              backgroundColor: Colors.red);
        } else {
          var errorResponse = jsonDecode(response.body);
          showNotification(
              'حدث خطأ: ${errorResponse['message'] ?? response.statusCode}',
              backgroundColor: Colors.red);
        }
      } else {
        showNotification('يرجى إدخال البريد الإلكتروني وكلمة المرور',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      showNotification('حدث خطأ: $e', backgroundColor: Colors.red);
    }
  }

  // void forgetPass() async {
  //   try {
  //     if (_usernameController.text.isNotEmpty) {
  //       var reqBody = {
  //         "username": _usernameController.text,
  //       };

  //       try {
  //         var response = await http.post(
  //           Uri.parse(forgotPass), // Point to the forgot password endpoint
  //           headers: {"Content-Type": "application/json"},
  //           body: jsonEncode(reqBody),
  //         );

  //         if (response.statusCode == 200) {
  //           var jsonResponse = jsonDecode(response.body);
  //           if (jsonResponse['status']) {
  //             showNotification('تم إرسال رمز التحقق إلى البريد الإلكتروني');

  //             // Navigate to the code input screen
  //             Navigator.of(context).push(
  //               MaterialPageRoute(
  //                 builder: (context) =>
  //                     OpcodeScreen(email: _usernameController.text),
  //               ),
  //             );
  //           } else {
  //             showNotification('البريد الإلكتروني غير مسجل',
  //                 backgroundColor: Colors.red);
  //           }
  //         } else {
  //           showNotification('حدث خطأ: ${response.statusCode}',
  //               backgroundColor: Colors.red);
  //         }
  //       } catch (e) {
  //         showNotification('حدث خطأ: $e', backgroundColor: Colors.red);
  //       }
  //     } else {
  //       showNotification('يرجى إدخال البريد الإلكتروني',
  //           backgroundColor: Colors.red);
  //     }
  //   } catch (e) {
  //     // Handle exceptions (like network issues)
  //     showNotification('حدث خطأ: $e', backgroundColor: Colors.red);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Stack(
        children: [
          // Container(
          //   decoration: BoxDecoration(
          //     image: DecorationImage(
          //       image:
          //           AssetImage("assets/images/cover.jpg"), // Path to your image
          //       fit: BoxFit.cover, // Cover the whole screen
          //     ),
          //   ),
          // ),

          Column(
            children: [
              const Expanded(child: SizedBox(height: 10)),
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(222, 255, 255, 255),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formSignInKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '! مرحباً بك',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              color: Color.fromARGB(255, 21, 80, 13),
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 25.0),
                          TextFormField(
                            controller: _usernameController,
                            textAlign: TextAlign.right,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى ادخال اسم المستخدم';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              label: const Align(
                                alignment: Alignment.centerRight,
                                child: Text('اسم المستخدم'),
                              ),
                              // filled: true,
                              // fillColor: Color.fromARGB(180, 255, 255, 255),
                              hintText: 'ادخل اسم المستخدم الخاص بك',
                              hintStyle: const TextStyle(
                                color: Colors.black26,
                              ),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black12, width: 3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black12, width: 3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 25.0),
                          TextFormField(
                            controller: _passController,
                            textAlign: TextAlign.right,
                            obscureText: _isObscured,
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى ادخال كلمة السر';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              label: const Align(
                                alignment: Alignment.centerRight,
                                child: Text('كلمة السر'),
                              ),
                              // filled: true,
                              // fillColor: Color.fromARGB(180, 255, 255, 255),
                              hintText: 'ادخل كلمة السر الخاصة بك',
                              hintStyle: const TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black12, width: 3),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black12, width: 3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: IconButton(
                                icon: Icon(
                                  _isObscured
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black54,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscured = !_isObscured;
                                  });
                                },
                              ),
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 25.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberPassword,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        rememberPassword = value ?? true;
                                      });
                                    },
                                    activeColor:
                                        const Color.fromARGB(255, 12, 40, 14),
                                  ),
                                  const Text(
                                    'ذكّرني',
                                    style: TextStyle(color: Colors.black45),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Capture the username text from the controller
                                  String username = _usernameController.text;

                                  // Validate if the username is not empty before navigation
                                  if (username.isNotEmpty) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ForgetPasswordScreen(
                                                username: username),
                                      ),
                                    );
                                  } else {
                                    // If username is empty, show a message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('يرجى إدخال اسم المستخدم')),
                                    );
                                  }
                                },
                                child: const Text(
                                  'هل نسيت كلمة السر؟',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 23, 98, 29),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formSignInKey.currentState!.validate() &&
                                    rememberPassword) {
                                  loginUser();
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   const SnackBar(
                                  //       content:
                                  //           Text('معالجة البيانات الشخصية')),
                                  // );
                                } else if (!rememberPassword) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'يرجى الموافقة على معالجة البيانات الشخصية')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 26, 83, 25),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18.0),
                                textStyle: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'CustomArabicFont'),
                              ),
                              child: const Text('تسجيل الدخول'),
                            ),
                          ),
                          const SizedBox(height: 25.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) => const SignupScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'إنشاء حساب',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 14, 80, 34),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const Text(
                                'ليس لديك حساب؟ ',
                                style: TextStyle(color: Colors.black45),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Show the notification bar if there's a message
          if (_showNotification)
            AnimatedNotificationBar(
              message: _notificationMessage,
              backgroundColor: _notificationColor,
            ),
        ],
      ),
    );
  }
}
