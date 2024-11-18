import 'package:flutter/material.dart';
import 'package:login_page/screens/NewPass.dart';
import 'package:login_page/Auth/signin_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';

import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert'; // Import JSON decoding

class OpcodeScreen extends StatefulWidget {
  final String username; // Accept email as a parameter

  const OpcodeScreen({super.key, required this.username});

  @override
  State<OpcodeScreen> createState() => _OpcodeScreenState();
}

class _OpcodeScreenState extends State<OpcodeScreen> {
  final _formSignInKey = GlobalKey<FormState>(); // Correct form key
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  bool _isLoading = false; // To manage the loading state

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void verifytoken() async {
    setState(() {
      _isLoading = true;
    });

    // Combine the 4 digits entered by the user
    String code =
        _codeControllers.map((controller) => controller.text).join('');

    try {
      var reqBody = {"username": widget.username, "code": code};

      var response = await http.post(
        Uri.parse(verifyCode), // Ensure you're pointing to the login endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        // Check if 'status' exists and is a boolean
        if (jsonResponse['status'] != null && jsonResponse['status'] is bool) {
          if (jsonResponse['status']) {
            // If code is correct, navigate to the New Password screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewPassword(
                    username:
                        widget.username), // Pass email to NewPassword screen
              ),
            );
          } else {
            // Show error message if code is incorrect
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('رمز الأمان غير صحيح')),
            );
          }
        } else {
          // Handle the case where 'status' is null or not a boolean
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('استجابة غير صحيحة من الخادم')),
          );
        }
      } else {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الخادم: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            child: SizedBox(
              height: 10,
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
                  key: _formSignInKey, // Use the correct form key here
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end, // محاذاة للنهاية
                    children: [
                      const Text(
                        'أدخل رمز الأمان الخاص بك',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 21, 80, 13),
                        ),
                        textAlign: TextAlign.right, // محاذاة للنص لليمين
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'أدخل الرمز المكوّن من 4 أرقام الذي أرسلناه إلى بريدك الإلكتروني',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.right, // محاذاة للنص لليمين
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 50,
                            child: TextFormField(
                              controller: _codeControllers[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ادخل رقماً';
                                }
                                return null;
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null // Disable button when loading
                              : () {
                                  if (_formSignInKey.currentState!.validate()) {
                                    verifytoken(); // Call the verification function
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
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'تأكيد'), // Show loading spinner when verifying
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
