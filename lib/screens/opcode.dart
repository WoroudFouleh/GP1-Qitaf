import 'package:flutter/material.dart';
import 'package:login_page/screens/NewPass.dart';
import 'package:login_page/screens/signin_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';

class OpcodeScreen extends StatefulWidget {
  const OpcodeScreen({super.key});

  @override
  State<OpcodeScreen> createState() => _OpcodeScreenState();
}

class _OpcodeScreenState extends State<OpcodeScreen> {
  final _formSignInKey = GlobalKey<FormState>(); // Correct form key

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
                              textAlign: TextAlign.center, // محاذاة للنص لليمين
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
                          onPressed: () {
                            if (_formSignInKey.currentState!.validate()) {
                              // If validation passes, navigate to NewPasswordScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NewPassword(),
                                ),
                              );
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
                          child: const Text('تأكيد'), // Verify button
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
