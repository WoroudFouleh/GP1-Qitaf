import 'package:flutter/material.dart';
import 'package:login_page/screens/nextsign.dart';
import 'package:login_page/Auth/signin_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  bool _isObscured = true;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _familyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String selectedCountryCode = '+970';

  bool _isConfirmObscured = true;
  bool _passwordsMatch = false;
  final List<String> countryCodes = [
    '+970',
    '+972',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _familyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 3),
          ),
          Expanded(
            flex: 100,
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'قم بإدخال بياناتك لإنشاء الحساب الخاص بك',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.w900,
                          color: const Color.fromRGBO(15, 99, 43, 1),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _firstNameController,
                        textAlign: TextAlign.right,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى ادخال اسمك';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('الاسم'),
                          ),
                          hintText: 'ادخل اسمك',
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
                      TextFormField(
                        controller: _familyNameController,
                        textAlign: TextAlign.right,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى ادخال اسم العائلة';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('اسم العائلة'),
                          ),
                          hintText: 'ادخل اسم العائلة',
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
                      TextFormField(
                        controller: _emailController,
                        textAlign: TextAlign.right,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى ادخال البريد الإلكتروني الخاص بك';
                          }
                          if (value != value.toLowerCase()) {
                            return 'يرجى استخدام بريد الكتروني بحروف صغيرة';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('البريد الإلكتروني'),
                          ),
                          hintText: 'Email',
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
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: DropdownButtonFormField<String>(
                              value: selectedCountryCode,
                              items: ['+970', '+972'].map((code) {
                                return DropdownMenuItem(
                                  value: code,
                                  child: Text(code),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCountryCode = value!;
                                });
                              },
                              decoration: InputDecoration(
                                label: const Text('Code'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textAlign: TextAlign.right,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى ادخال رقم الهاتف الخاص بك';
                                }
                                if (value.length < 8 || value.length > 9) {
                                  return 'يجب أن يتكون رقم الهاتف من 8 إلى 9 أرقام';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('الهاتف'),
                                ),
                                hintText: 'ادخل رقم هاتفك',
                                hintStyle:
                                    const TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        obscuringCharacter: '*',
                        textAlign: TextAlign.right,
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
                          hintText: 'ادخل كلمة السر',
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
                            // تغييرها من suffixIcon إلى prefixIcon
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
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _isConfirmObscured,
                        obscuringCharacter: '*',
                        textAlign: TextAlign.right,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى تأكيد كلمة السر';
                          }
                          if (value != _passwordController.text) {
                            return 'كلمات المرور غير متطابقة';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('تأكيد كلمة السر'),
                          ),
                          hintText: 'أعِد ادخال كلمة السر',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _passwordsMatch
                                  ? const Color.fromRGBO(15, 99, 43, 1)
                                  : Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _passwordsMatch
                                  ? const Color.fromRGBO(15, 99, 43, 1)
                                  : Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: IconButton(
                            // تغييرها من suffixIcon إلى prefixIcon
                            icon: Icon(
                              _isConfirmObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmObscured = !_isConfirmObscured;
                              });
                            },
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _passwordsMatch = value == _passwordController.text;
                          });
                        },
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Nextsign(
                                    name: _firstNameController.text,
                                    familyName: _familyNameController.text,
                                    email: _emailController.text,
                                    phone: _phoneController.text,
                                    password: _passwordController.text,
                                    countryCode: selectedCountryCode,
                                  ),
                                ),
                              );
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'يرجى الموافقة على تعديل البيانات الشخصية'),
                                ),
                              );
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
                          child: const Text('التالي'),
                        ),
                      ),
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
                                color: const Color.fromRGBO(15, 99, 43, 1),
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
