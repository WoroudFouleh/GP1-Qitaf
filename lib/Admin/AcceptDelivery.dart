import 'package:flutter/material.dart';
import 'package:login_page/Admin/Admin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/config.dart';

class DeliveryRequestsPage extends StatefulWidget {
  const DeliveryRequestsPage({super.key});

  @override
  State<DeliveryRequestsPage> createState() => _DeliveryRequestsPageState();
}

class _DeliveryRequestsPageState extends State<DeliveryRequestsPage> {
  List<dynamic> requests = [];
  bool isLoading = true;
  final Uri pdfUri = Uri.parse(
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'); // رابط لملف PDF

  @override
  void initState() {
    super.initState();
    fetchRequests(); // Fetch ads when the widget initializes
  }

  String transliterateArabicToEnglish(String arabicText) {
    Map<String, String> arabicToLatin = {
      'ا': 'a', 'ب': 'b', 'ت': 't', 'ث': 'th', 'ج': 'j', 'ح': 'h', 'خ': 'kh',
      'د': 'd', 'ذ': 'dh',
      'ر': 'r', 'ز': 'z', 'س': 's', 'ش': 'sh', 'ص': 's', 'ض': 'd', 'ط': 't',
      'ظ': 'z', 'ع': 'a',
      'غ': 'gh', 'ف': 'f', 'ق': 'q', 'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n',
      'ه': 'h', 'و': 'w',
      'ي': 'y', 'ى': 'a', 'ئ': 'y', 'ؤ': 'w', 'لا': 'la', 'ل': 'l', 'آ': 'aa',
      'ئ': 'y', 'ؤ': 'w',
      // Add more letters or combinations as needed
    };

    String transliteratedText = '';
    arabicText.split('').forEach((char) {
      transliteratedText += arabicToLatin[char] ??
          char; // If no match, keep the original character
    });

    return transliteratedText;
  }

// Calculate Age
  int calculateAge(Map<String, dynamic> birthDate) {
    // Map of Arabic month names to their numeric values
    final monthMap = {
      'يناير': 1,
      'فبراير': 2,
      'مارس': 3,
      'أبريل': 4,
      'مايو': 5,
      'يونيو': 6,
      'يوليو': 7,
      'أغسطس': 8,
      'سبتمبر': 9,
      'أكتوبر': 10,
      'نوفمبر': 11,
      'ديسمبر': 12,
    };

    try {
      final now = DateTime.now();

      // Convert month name to its numeric value
      final month =
          monthMap[birthDate['month']] ?? 1; // Default to January if invalid
      final day = int.parse(birthDate['day']);
      final year = int.parse(birthDate['year']);

      final birthDateTime = DateTime(year, month, day);

      int age = now.year - birthDateTime.year;
      if (now.month < birthDateTime.month ||
          (now.month == birthDateTime.month && now.day < birthDateTime.day)) {
        age--;
      }
      return age;
    } catch (e) {
      debugPrint('Error calculating age: $e');
      return 0; // Default to 0 if an error occurs
    }
  }

  Future<void> generateUserPass(
      String requestId,
      String firstName,
      String lastName,
      String email,
      String location,
      String phone,
      String license,
      BuildContext context) async {
    // Transliterate the first and last names to English
    String transliteratedFirstName = transliterateArabicToEnglish(firstName);
    String transliteratedLastName = transliterateArabicToEnglish(lastName);

    try {
      // Make the HTTP POST request to generate username and password
      final response = await http.post(
        Uri.parse(generateCredentials),
        headers: {
          'Content-Type': 'application/json', // Set content type to JSON
        },
        body: jsonEncode({
          'firstName': transliteratedFirstName,
          'lastName': transliteratedLastName,
          'userId': requestId, // Assuming the request ID is the user ID
        }),
      );

      // Check if the response status code is 200 (success)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String username = data['username'];
        String password = data['password'];

        // Show username and password to the admin (or handle however you like)
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Username: $username\nPassword: $password')),
        // );
        registerDeliveryMan(username, email, password, firstName, lastName,
            location, phone, license);
        // _showAcceptDialog(username, password, firstName, lastName, requestId,
        //     email, location, phone, license);

        // You can also send the credentials to the user via SMS/email or save them in the database
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['message']}')),
        );
      }
    } catch (error) {
      // Handle any error (e.g., network issues)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  Future<void> sendEmailAPI(
      String username, String password, String email) async {
    try {
      final response = await http.post(
        Uri.parse(sendInfoByEmail), // Replace with actual API URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال البريد الإلكتروني بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${responseData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('حدث خطأ أثناء إرسال البريد الإلكتروني: $error'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }

  Future<void> updateRequestStatus(
      String requestId, String status, BuildContext context) async {
    // Define the URL for the API

    try {
      // Make the HTTP PUT request to the backend
      final response = await http.put(
        Uri.parse(changeRequestStatue),
        headers: {
          'Content-Type':
              'application/json', // Make sure to set the content type
        },
        body: jsonEncode({
          'requestId': requestId,
          'status': status,
        }),
      );

      // Check if the response status code is 200 (success)
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Show a success message or handle response as needed
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //       content: Text('Status updated to: ${responseData['status']}')),
        // );
      } else {
        final responseData = jsonDecode(response.body);
        // Handle error response from the API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['message']}')),
        );
      }
    } catch (error) {
      // Handle any error (e.g., network issues)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  // فتح ملف PDF

  Future<void> _openImage(String url, BuildContext context) async {
    Uri uri = Uri.parse(url);
    print("uri: $uri");

    // Show a dialog to display the image
    showDialog(
      context: context,
      barrierDismissible: true, // Allows closing the dialog by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  url,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 50,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchRequests() async {
    final response = await http.get(
      Uri.parse(getDeliveryWorkRequests),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          requests = data['requests'];
          isLoading = false; // Update the lands list with the response data
        });
      } else {
        print("Error fetching req: ${data['message']}");
      }
    } else {
      print("Failed to load req: ${response.statusCode}");
    }
  }

  Future<void> registerDeliveryMan(
      String username,
      String email,
      String password,
      String firstName,
      String lastName,
      String location,
      String phoneNumber,
      String licenceFile) async {
    // Define the URL for the API

    try {
      // Make the HTTP PUT request to the backend
      final response = await http.post(
        Uri.parse(registerDeliveruMan),
        headers: {
          'Content-Type':
              'application/json', // Make sure to set the content type
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'location': location,
          'phoneNumber': phoneNumber,
          'licenseFile': licenceFile
        }),
      );

      // Check if the response status code is 200 (success)
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Delivery man registered successfully: ${data['message']}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPage(),
          ),
        );
      } else {
        print('Failed to register delivery man: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while registering delivery man: $e');
    }
  }

  // بناء طلب فردي
  Widget _buildOrderCard(Map<String, dynamic> request) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFEFFAF1),
              Color(0xFFDFF2E0),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.description, color: Colors.blue),
                Text(
                  'رقم الطلب: ${request['reqId'] ?? 'غير متوفر'}',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            const Divider(thickness: 1.5),
            _buildOrderDetailWithIcon(Icons.account_circle, 'الاسم',
                '${request['firstName']} ${request['lastName']}', Colors.brown),
            _buildOrderDetailWithIcon(Icons.email, 'البريد الإلكتروني',
                request['email'] ?? 'غير متوفر', Colors.teal),
            _buildOrderDetailWithIcon(Icons.phone, 'رقم الجوال',
                request['phoneNumber'] ?? 'غير متوفر', Colors.orange),
            _buildOrderDetailWithIcon(Icons.location_city, 'المدينة',
                request['city'] ?? 'غير متوفر', Colors.blue),
            _buildOrderDetailWithIcon(
                Icons.calendar_today,
                'تاريخ الميلاد',
                '${request['birthDate']['year']}-${request['birthDate']['day']}-${request['birthDate']['month']}',
                Colors.red),
            _buildOrderDetailWithIcon(
                Icons.timeline,
                'العمر',
                '${calculateAge(request['birthDate'])} سنة',
                Colors.purpleAccent),
            _buildOrderDetailWithIcon(
                Icons.card_membership,
                'رقم الهوية',
                request['idNumber'] ?? 'غير متوفر',
                Colors.purple), // إضافة حقل رقم الهوية
            _buildOrderDetailWithIcon(
              Icons.attach_file,
              ' رخصة القيادة',
              'عرض الملف',
              Colors.green,
              isFile: true,
              filePath: 'http://192.168.88.5:3000/${request['licenseFile']}',
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      updateRequestStatus(request['_id'], "approved", context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم قبول الطلب.'),
                          backgroundColor: Color.fromARGB(255, 32, 131, 53),
                        ),
                      );
                      // _showAcceptDialog(); // عرض نافذة تأكيد القبول
                      generateUserPass(
                          request['_id'],
                          request['firstName'],
                          request['lastName'],
                          request['email'],
                          request['city'],
                          request['phoneNumber'],
                          request['licenseFile'],
                          context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                            color: Colors.green.shade800, width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'قبول',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      updateRequestStatus(request['_id'], "rejected", context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم رفض الطلب.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side:
                            BorderSide(color: Colors.red.shade800, width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'رفض',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // إنشاء عنصر تفاصيل الطلب مع أيقونة
  Widget _buildOrderDetailWithIcon(
      IconData icon, String title, String value, Color color,
      {bool isFile = false, String? filePath}) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: isFile
              ? TextButton.icon(
                  onPressed: () {
                    if (filePath != null) {
                      print("file path: $filePath");
                      // Construct the full file path dynamically
                      String fileUri = Uri.encodeFull(filePath);
                      _openImage(filePath, context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لا يمكن العثور على الملف.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.file_open, color: Colors.green),
                  label: Text(
                    value,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.right,
                ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  // عرض نافذة تأكيد القبول
  void _showAcceptDialog(
      String username,
      String password,
      String firstName,
      String lastName,
      String requestId,
      String email,
      String location,
      String phone,
      String license) {
    TextEditingController usernameController =
        TextEditingController(text: username);
    TextEditingController passwordController =
        TextEditingController(text: password);
    bool _isPasswordVisible = false;

    // Close any existing dialog and open a new one
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                'إرسال رسالة قبول عبر SMS',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم المستخدم',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Close the current dialog
                          generateUserPass(
                              requestId,
                              firstName,
                              lastName,
                              email,
                              location,
                              phone,
                              license,
                              context); // Regenerate credentials
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible =
                                      !_isPasswordVisible; // Toggle visibility
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Close the current dialog
                          generateUserPass(
                              requestId,
                              firstName,
                              lastName,
                              email,
                              location,
                              phone,
                              license,
                              context); // Regenerate credentials
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      String finalUsername = usernameController.text;
                      String finalPassword = passwordController.text;
                      sendEmailAPI(finalUsername, finalPassword, email);
                      registerDeliveryMan(finalUsername, email, finalPassword,
                          firstName, lastName, location, phone, license);
                      // Logic to send the SMS using finalUsername and finalPassword
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم إرسال رسالة القبول عبر Email!\n'
                            'اسم المستخدم: $finalUsername\n'
                            'كلمة المرور: $finalPassword',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'إرسال',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'طلبات التوصيل',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF556B2F),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Colors.white), // السهم الأبيض
          onPressed: () {
            Navigator.pop(context); // الرجوع إلى الصفحة السابقة
          },
        ),
      ),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) => _buildOrderCard(requests[index]),
      ),
    );
  }
}
