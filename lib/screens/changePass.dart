import 'package:flutter/material.dart';
import 'package:login_page/screens/changePass2.dart';
import 'package:login_page/screens/custom_drawer.dart';

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
          endDrawer: const CustomDrawer(), // استخدام الـ CustomDrawer هنا
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
                              'أدخل كلمة السر الحالية',
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
                            textAlign: TextAlign
                                .right, // محاذاة النص داخل الحقل إلى اليمين
                          ),
                          const SizedBox(height: 25.0),
                          const SizedBox(height: 25.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formNewPasswordKey.currentState!
                                    .validate()) {
                                  // التحقق من كلمة السر والانتقال إلى الشاشة الجديدة
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Changepass2(),
                                    ),
                                  );
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
                              child: const Text('التحقق من كلمة السر الحالية'),
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
