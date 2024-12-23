import 'package:flutter/material.dart';
import 'package:login_page/screens/changePass2.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
//import 'package:flutter_bcrypt/flutter_bcrypt.dart';
//import 'package:crypt/crypt.dart';

class Changepass extends StatefulWidget {
  final String token;
  final userId;
  const Changepass({required this.token, Key? key, this.userId}) : super(key: key);

  @override
  State<Changepass> createState() => _ChangepassState();
}

class _ChangepassState extends State<Changepass> {
  final _formNewPasswordKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscured = true;
  late String
      hashedPassword1; // This will hold the hashed password from the token

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    hashedPassword1 =
        jwtDecoderToken['password']; // Get the hashed password from the token
    print('Extracted hashed password: $hashedPassword1');
  }

  void checkPass() async {
    String enteredPassword = _passwordController.text;
    String hashedPassword = hashedPassword1;
    var regBody = {
      'enteredPassword': enteredPassword,
      'hashedPassword': hashedPassword
    };
    var response = await http.post(
      Uri.parse(verifyPassword),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization':
        //     'Bearer ${widget.token}', // Pass the token in the Authorization header
      },
      body: jsonEncode(regBody),
    );
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");
    var responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['status'] == true) {
      // If password matches, navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Changepass2(token: widget.token,
          userId: widget.userId,),
        ),
      );
    } else {
      // Show a notification that the password is incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمة السر الحالية غير صحيحة'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
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
                            alignment: Alignment.centerRight,
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
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 25.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formNewPasswordKey.currentState!
                                    .validate()) {
                                  checkPass(); // Call the password check function
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
