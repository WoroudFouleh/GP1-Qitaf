import 'package:flutter/material.dart';
import 'package:login_page/screens/forget_password_screen.dart';
import 'package:login_page/screens/signup_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';
import 'package:login_page/screens/first_screen.dart'; // تأكد من استيراد صفحة HomePage

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  bool _isObscured = true;

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
                        textAlign: TextAlign.right, // محاذاة النص لليمين
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        textAlign:
                            TextAlign.right, // محاذاة النص داخل الحقل لليمين
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى ادخال اسم المستخدم';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment
                                .centerRight, // محاذاة النص داخل الـ label لليمين
                            child: Text('اسم المستخدم'),
                          ),
                          hintText: 'ادخل اسم المستخدم الخاص بك',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          alignLabelWithHint:
                              true, // لمحاذاة الـ label مع الـ hint إذا كان الحقل طويلًا
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        textDirection: TextDirection
                            .rtl, // لضبط اتجاه الكتابة للـ hintText
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        textAlign:
                            TextAlign.right, // محاذاة النص داخل الحقل لليمين
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
                          hintText: 'ادخل كلمة السر الخاصة بك',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
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
                        textDirection: TextDirection
                            .rtl, // لضبط اتجاه الكتابة للـ hintText
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
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor:
                                    const Color.fromARGB(255, 25, 94, 29),
                              ),
                              const Text(
                                'ذكّرني',
                                style: TextStyle(color: Colors.black45),
                                textAlign:
                                    TextAlign.right, // محاذاة النص لليمين
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgetPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'هل نسيت كلمة السر؟',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 23, 98, 29),
                              ),
                              textAlign: TextAlign.right, // محاذاة النص لليمين
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('معالجة البيانات الشخصية')),
                              );

                              // الانتقال إلى صفحة HomePage بعد تسجيل الدخول بنجاح
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HomePage(), // صفحة HomePage
                                ),
                              );
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
                                const Color.fromARGB(255, 17, 118, 21),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            textStyle: const TextStyle(
                              fontSize: 18.0, // حجم الخط داخل الزر
                              fontWeight: FontWeight.bold,
                            ),
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
                              textAlign: TextAlign.right, // محاذاة النص لليمين
                            ),
                          ),
                          const Text(
                            'ليس لديك حساب؟ ',
                            style: TextStyle(color: Colors.black45),
                            textAlign: TextAlign.right, // محاذاة النص لليمين
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
    );
  }
}
