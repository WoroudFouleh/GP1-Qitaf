import 'package:flutter/material.dart';
// استدعاء الصفحة الجديدة
import 'package:login_page/widgets/custom_scaffold.dart';

class Changepass extends StatefulWidget {
  const Changepass({super.key});

  @override
  State<Changepass> createState() => _ChangepassState();
}

class _ChangepassState extends State<Changepass> {
  final _formNewPasswordKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscured = true;
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
                        'ادخل كلمة السر الحالية',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 21, 80, 13),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى ادخال كلمة السر الحالية';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('كلمة السر الحالية'),
                          ),
                          hintText: 'أدخل كلمة السر الحالية',
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
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formNewPasswordKey.currentState!.validate()) {
                              // التحقق من كلمة السر والانتقال إلى الشاشة الجديدة
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => const NewPassword(),
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
                          child: const Text('التحقق من كلمة السر الحالية'),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (e) => const ForgetPasswordScreen(),
                              //   ),
                              // );
                            },
                            child: const Text(
                              ' نعم',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 18, 87, 38),
                              ),
                            ),
                          ),
                          const Text(
                            'هل نسيت كلمة السر؟ ',
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
