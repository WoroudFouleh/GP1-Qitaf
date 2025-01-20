import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:login_page/Admin/Admin.dart';

import 'package:login_page/Customers/customerBar.dart';
import 'package:login_page/Delivery/DileveryHome.dart';
import 'package:login_page/screens/animition_notification_bar.dart';

import 'package:login_page/screens/first_screen.dart';
import 'package:login_page/screens/forget_password_screen.dart';

import 'package:login_page/screens/signup_screen.dart';
import 'package:login_page/services/notification_service.dart';

import 'package:login_page/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/config.dart';
import 'dart:convert';
//import 'animition_notification_bar.dart'; // Import the animated notification bar
import 'package:firebase_auth/firebase_auth.dart';

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
    initializeNotificationService();
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

// Initialize the notification service
  void initializeNotificationService() async {
    await NotificationService.instance.initialize();
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

// Example Function to Show the Suspension Dialog
  void showSuspensionDialog(BuildContext context, int remainingTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          title: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center align title
                children: [
                  // Icon(Icons.warning_amber_rounded,
                  //     color: Colors.red, size: 30),
                  // SizedBox(width: 10),
                  Text(
                    'الحساب معلق',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center, // Center align title text
                  ),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                color: Colors.red,
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                'تم تعليق حسابك بسبب حصولك على ثلاثة تنبيهات',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'يرجى المحاولة مرة أخرى بعد $remainingTime ساعة',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              icon: Icon(Icons.close,
                  size: 18, color: Colors.white), // White icon color
              label: Text(
                'موافق',
                style: TextStyle(color: Colors.white), // White text color
              ),
            ),
          ],
        );
      },
    );
  }

  void loginUser() async {
    try {
      var myToken2;
      String? fcmToken; // Declare variable for FCM token

      if (_usernameController.text.isNotEmpty &&
          _passController.text.isNotEmpty) {
        bool firebaseLoginSuccess = false;

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
//Check for user suspension
        var suspensionCheckResponse = await http.post(
          Uri.parse(
              checkUserSuspension), // Replace with your suspension check endpoint
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": _usernameController.text}),
        );
        print("heree");
        print(suspensionCheckResponse);
        if (suspensionCheckResponse.statusCode == 200) {
          print("in suss");
          var suspensionCheckResult = jsonDecode(suspensionCheckResponse.body);

          if (suspensionCheckResult['suspended'] == true) {
            int remainingTime =
                (suspensionCheckResult['remainingTime'] / (60 * 60 * 1000))
                    .ceil();
            String message =
                'تم تعليق حسابك. يرجى المحاولة مرة أخرى بعد $remainingTime ساعة.';

            showSuspensionDialog(context, remainingTime);
            return; // Stop further execution
          }
        } else {
          showNotification(
            'Error checking account suspension: ${suspensionCheckResponse.body}',
            backgroundColor: Colors.red,
          );
          return; // Stop further execution
        }
        try {
          // Firebase login
          UserCredential firebaseUser = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: _usernameController.text,
                  password: _passController.text);

          if (firebaseUser.user != null) {
            myToken2 = await firebaseUser.user!.getIdToken();

            // Get the FCM token
            fcmToken = await FirebaseMessaging.instance.getToken();

            User? firebaseUser2 = FirebaseAuth.instance.currentUser;
            String userId = firebaseUser2?.uid ?? ''; // Get the UID

            if (fcmToken != null) {
              // Update Firestore with FCM token
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                'fcmToken': fcmToken,
              });
            }

            showNotification('تم تسجيل الدخول عبر Firebase بنجاح');
            firebaseLoginSuccess = true;
          }
        } catch (e) {
          showNotification('خطأ في تسجيل الدخول عبر Firebase',
              backgroundColor: Colors.red);
        }

        // Proceed with API call for other users
        var reqBody = {
          "email": _usernameController.text,
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
                  builder: (context) =>
                      HomePage(token: myToken, token2: myToken2),
                ),
              );
            } else if (userType == '1') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CustomerBar(token: myToken, token2: myToken2),
                ),
              );
            } else if (userType == '3') {
              // Show dialog for account selection
              var deliveryToken = jsonResponse['deliveryToken'];
              _showAccountSelectionDialog(myToken, deliveryToken, myToken2);
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

  void _showAccountSelectionDialog(
      String myToken, String deliveryToken, String myToken2) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          // Ensures proper RTL alignment
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'اختر نوع الحساب',
              textAlign: TextAlign.right,
            ),
            content: const Text(
              'هذا البريد الإلكتروني له حسابين: عميل وتوصيل. مع أي منهما تريد تسجيل الدخول؟',
              textAlign: TextAlign.right,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleAccountSelection('customer', myToken, myToken2);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 52, 125, 54),
                        foregroundColor: Colors.white,
                        fixedSize:
                            const Size.fromHeight(50), // Ensures equal height
                      ),
                      icon: const Icon(Icons.person, size: 18), // Customer icon
                      label: const Text('زبون'),
                    ),
                  ),
                  const SizedBox(width: 10), // Adds spacing between buttons
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleAccountSelection(
                            'delivery', deliveryToken, myToken2);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 52, 125, 54),
                        foregroundColor: Colors.white,
                        fixedSize:
                            const Size.fromHeight(50), // Ensures equal height
                      ),
                      icon: const Icon(Icons.delivery_dining,
                          size: 18), // Delivery icon
                      label: const Text('توصيل'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAccountSelection(
      String accountType, String myToken, String myToken2) {
    if (accountType == 'customer') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerBar(token: myToken, token2: myToken2),
        ),
      );
    } else if (accountType == 'delivery') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DeliveryOrdersPage(token: myToken, token2: myToken2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Stack(
        children: [
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
