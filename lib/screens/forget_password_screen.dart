import 'package:flutter/material.dart';
import 'package:login_page/screens/signin_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';
import 'package:login_page/screens/opcode.dart'; // تأكد من صحة هذا الاستيراد
//import 'animition_notification_bar.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';

class ForgetPasswordScreen extends StatefulWidget {
  final String username; // Accept email as a parameter

  const ForgetPasswordScreen({super.key, required this.username});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  final TextEditingController _resetEmailController = TextEditingController();

  String _notificationMessage = '';
  Color _notificationColor = Colors.green;
  bool _showNotification = false;

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

  void forgetPass() async {
    try {
      if (_resetEmailController.text.isNotEmpty) {
        var reqBody = {
          "email": _resetEmailController.text,
          "username": widget.username
        };

        try {
          var response = await http.post(
            Uri.parse(forgotPass), // Point to the forgot password endpoint
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(reqBody),
          );

          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            if (jsonResponse['status']) {
              showNotification('تم إرسال رمز التحقق إلى البريد الإلكتروني');

              // Navigate to the code input screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OpcodeScreen(username: widget.username),
                ),
              );
            } else {
              showNotification('البريد الإلكتروني غير مسجل',
                  backgroundColor: Colors.red);
            }
          } else {
            showNotification('حدث خطأ: ${response.statusCode}',
                backgroundColor: Colors.red);
          }
        } catch (e) {
          showNotification('حدث خطأ: $e', backgroundColor: Colors.red);
        }
      } else {
        showNotification('يرجى إدخال البريد الإلكتروني',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      // Handle exceptions (like network issues)
      showNotification('حدث خطأ: $e', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            child: SizedBox(height: 10),
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
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end, // محاذاة للنهاية
                    children: [
                      const Align(
                        alignment: Alignment.centerRight, // محاذاة النص لليمين
                        child: Text(
                          'الرجاء ادخال البريد الالكتروني الخاص بك',
                          textAlign:
                              TextAlign.right, // تأكد من محاذاة النص لليمين
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 21, 80, 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _resetEmailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء ادخال البريد الالكتروني الخاص بك';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text(' البريد الالكتروني '),
                          ),
                          hintText: ' أدخل البريد الالكتروني ',
                          alignLabelWithHint: true,
                          hintStyle: const TextStyle(color: Colors.black26),
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formSignInKey.currentState!.validate()) {
                              forgetPass();
                              // إذا كانت التحقق ناجحة، الانتقال إلى OpcodeScreen
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => const OpcodeScreen(email: _resetEmailController.text),
                              //   ),
                              // );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 17, 118, 21),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            textStyle: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('إرسال'),
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
                                  builder: (e) => const SigninScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'تسجيل دخول',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 18, 87, 38),
                              ),
                            ),
                          ),
                          const Text(
                            'هل لديك حساب؟ ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
