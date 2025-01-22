import 'package:flutter/material.dart';
import 'package:login_page/screens/complete_sign.dart';
import 'package:login_page/Auth/signin_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';

class Nextsign extends StatefulWidget {
  final String name;
  final String familyName;
  final String email;
  final String phone;
  final String password;
  final String countryCode;
  const Nextsign({
    Key? key,
    required this.name,
    required this.familyName,
    required this.email,
    required this.phone,
    required this.password,
    required this.countryCode,
  }) : super(key: key);

  @override
  State<Nextsign> createState() => _NextsignState();
}

class _NextsignState extends State<Nextsign> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  String _gender = 'ذكر'; // القيمة الافتراضية
  String? selectedDay;
  String? selectedMonth;
  String? selectedYear;
  String? selectedCity;

  final TextEditingController _streetController = TextEditingController();

  final List<String> days =
      List.generate(31, (index) => (index + 1).toString());
  final List<String> months =
      List.generate(12, (index) => (index + 1).toString());
  final List<String> years =
      List.generate(100, (index) => (2023 - index).toString());

  final List<String> cities = [
    'القدس',
    'بيت لحم',
    'طوباس',
    'رام الله',
    'نابلس',
    'الخليل',
    'جنين',
    'طولكرم',
    'قلقيلية',
    'سلفيت',
    'أريحا',
    'غزة',
    'دير البلح',
    'خان يونس',
    'رفح',
    'الداخل الفلسطيني'
  ];

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
            flex: 10,
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
                        'قم بإنشاء الحساب الخاص بك',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.w900,
                          color: Color.fromRGBO(15, 99, 43, 1),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 25.0),
                      // City Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCity,
                        hint: const Text('اختار مدينتك',
                            textAlign: TextAlign.right),
                        items: cities.map((city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city, textAlign: TextAlign.right),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCity = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'يرجى اختيار اسم مدينتك';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25.0),
                      // Street Field
                      TextFormField(
                        controller: _streetController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'قم بوصف موقعك (اسم المنطقة..،الخ)';
                          }
                          return null;
                        },
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          label: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('الموقع'),
                          ),
                          hintText: 'ادخل موقعك',
                          hintTextDirection: TextDirection.rtl,
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      // Birthday Fields
                      const Text(
                        'تاريخ الميلاد',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedYear,
                              hint: const Text('السنة',
                                  textAlign: TextAlign.right),
                              items: years.map((year) {
                                return DropdownMenuItem<String>(
                                  value: year,
                                  child: Text(year, textAlign: TextAlign.right),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedYear = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى تحديد السنة';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedMonth,
                              hint: const Text('الشهر',
                                  textAlign: TextAlign.right),
                              items: months.map((month) {
                                return DropdownMenuItem<String>(
                                  value: month,
                                  child:
                                      Text(month, textAlign: TextAlign.right),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedMonth = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى تحديد الشهر';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedDay,
                              hint: const Text('اليوم',
                                  textAlign: TextAlign.right),
                              items: days.map((day) {
                                return DropdownMenuItem<String>(
                                  value: day,
                                  child: Text(day, textAlign: TextAlign.right),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDay = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى تحديد اليوم';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10.0),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      // Gender Radio Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Text('ذكر'),
                              Radio<String>(
                                value: 'ذكر',
                                groupValue: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(width: 20.0),
                          Row(
                            children: [
                              const Text('أنثى'),
                              Radio<String>(
                                value: 'أنثى',
                                groupValue: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Text(':الجنس', textAlign: TextAlign.right),
                          const SizedBox(width: 20.0),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      // Signup Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              String street = _streetController.text;
                              // String dateOfBirth =
                              //     '$selectedYear-$selectedMonth-$selectedDay'; // Format the DOB as needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompleteSignUpScreen(
                                    name: widget.name,
                                    familyName: widget.familyName,
                                    email: widget.email,
                                    phone: widget.phone,
                                    password: widget.password,
                                    countryCode: widget.countryCode,
                                    street: street,
                                    gender: _gender,
                                    dayOfBirth: selectedDay!,
                                    monthOfBirth: selectedMonth!,
                                    yearOfBirth: selectedYear!,
                                    city: selectedCity!,
                                  ),
                                ),
                              );
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'يرجى الموافقة على معالجة البيانات الشخصية'),
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
                      const SizedBox(height: 20.0),
                      // Already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'هل لديك حساب؟',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SigninScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'تسجيل دخول',
                              style: TextStyle(
                                color: Color.fromARGB(255, 17, 80, 31),
                                fontWeight: FontWeight.bold,
                              ),
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
