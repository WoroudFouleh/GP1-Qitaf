import 'package:flutter/material.dart';
import 'package:login_page/screens/custom_drawer.dart';
import 'package:login_page/screens/owner_home.dart';
import 'package:login_page/screens/owner_profile.dart'; // استدعاء صفحة OwnerProfile
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Changepass2 extends StatefulWidget {
  final String token;
  const Changepass2({required this.token, Key? key}) : super(key: key);

  @override
  State<Changepass2> createState() => _Changepass2State();
}

class _Changepass2State extends State<Changepass2> {
  final _formNewPasswordKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isObscured = true;
  bool _isConfirmObscured = true;

  late String username; // This will hold the hashed password from the token

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    username =
        jwtDecoderToken['username']; // Get the hashed password from the token
  }

  void resetPassword() async {
    // Make a request to reset the password
    try {
      var response = await http.patch(
        Uri.parse('$updatePassword/$username'), // Replace with your backend URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String newToken = responseData['token'];
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('! تم تعديل كلمة السر الخاصة بك بنجاح')),
        );

        // Navigate to the main screen (or home screen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OwnerHome(token: newToken), // Replace with your main screen
          ),
        );
      } else {
        // Handle errors from the server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الخادم: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
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
            ),
            elevation: 0,
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'تغيير كلمة السر',
                textAlign: TextAlign.right,
              ),
            ),
          ),
          //endDrawer: const CustomDrawer(), // استخدام الـ CustomDrawer هنا
          body: Column(
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
                          const Align(
                            alignment: Alignment
                                .centerRight, // لضبط النص يبدأ من اليمين تماماً
                            child: Text(
                              'أدخل كلمة السر الجديدة',
                              style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.w900,
                                color: Color.fromARGB(255, 17, 80, 31),
                              ),
                            ),
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
                            textAlign: TextAlign
                                .right, // محاذاة النص داخل الحقل إلى اليمين
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
                            textAlign: TextAlign
                                .right, // محاذاة النص داخل الحقل إلى اليمين
                          ),
                          const SizedBox(height: 25.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formNewPasswordKey.currentState!
                                    .validate()) {
                                  // تعديل كلمة السر والانتقال إلى صفحة OwnerProfile
                                  resetPassword();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 17, 118, 21),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18.0),
                                textStyle: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('تعديل كلمة السر'),
                            ),
                          ),
                          const SizedBox(height: 25.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
