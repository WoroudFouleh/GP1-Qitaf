import 'package:flutter/material.dart';
import 'package:login_page/Auth/signin_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import JSON decoding
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'config.dart';

class NewPassword extends StatefulWidget {
  final String username; // Username passed to identify the user

  const NewPassword({super.key, required this.username});

  @override
  State<NewPassword> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPassword> {
  final _formNewPasswordKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  bool _isLoading = false; // To manage the loading state
  String? email;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    print("username: ${widget.username}");
  }

  // Fetch user email based on username

  // Function to reset the user's password
  void resetPassword() async {
    if (widget.username == null || widget.username!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر العثور على البريد الإلكتروني')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Update password in Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw "No authenticated user found in Firebase.";
      }

      await user.updatePassword(_passwordController.text);
      print("Password updated in Firebase Authentication.");

      // 2. Update password in the backend database
      final response = await http.patch(
        Uri.parse(
            '$updatePassword/${widget.username}'), // API to update password
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('! تم تعديل كلمة السر بنجاح')),
        );

        // Navigate to the sign-in page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SigninScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الخادم: ${response.statusCode}')),
        );
      }
    } catch (e) {
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
                  key: _formNewPasswordKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'ادخل كلمة السر الجديدة',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(15, 99, 43, 1),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى ادخال كلمة السر الجديدة';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('كلمة السر الجديدة'),
                          ),
                          hintText: 'أدخل كلمة السر الجديدة',
                          alignLabelWithHint: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _isConfirmObscured,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء تأكيد كلمة السر';
                          }
                          if (value != _passwordController.text) {
                            return 'كلمات السر غير متطابقة';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('تأكيد كلمة السر'),
                          ),
                          hintText: 'تأكيد كلمة السر',
                          alignLabelWithHint: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmObscured = !_isConfirmObscured;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formNewPasswordKey.currentState!
                                      .validate()) {
                                    resetPassword();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(15, 99, 43, 1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            textStyle: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('تعديل كلمة السر'),
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
                                color: Color.fromRGBO(15, 99, 43, 1),
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
