import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/customerProfile.dart';
import 'package:login_page/services/notification_service.dart';

import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class OwnerBookingPage extends StatefulWidget {
  final String token;
  final userId;
  const OwnerBookingPage({required this.token, Key? key, this.userId})
      : super(key: key);

  @override
  _OwnerBookingPageState createState() => _OwnerBookingPageState();
}

class _OwnerBookingPageState extends State<OwnerBookingPage> {
  int quantity = 1; // الكمية الحالية
  List<dynamic> bookings = [];
  late String username;
  String selectedStatus = 'Not Yet';
  String buttonStatus = "Not Yet"; // Default status
  Color buttonColor = Colors.red; // Default color
  IconData buttonIcon = Icons.pending; // Default icon
  late String customerEmail;
  late String customerFCM;
  late String customerID;
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No username';

    fetchBookings(); // Call the fetch function when the page is loaded
  }

  void bookingDecision(String bookingId, String status) async {
    try {
      print('Request ID: $bookingId, Status: $status');
      // Convert image to base64 if an image is selected
      //String? base64Image = _image != null ? base64Encode(_image!) : null;

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'status': status,
        'bookingId': bookingId,
      };

      // Convert the request body to JSON format
      String jsonBody = jsonEncode(requestBody);

      // Send the request to the backend
      var response = await http.put(
        Uri.parse(updateBookingStatus), // Replace with your backend URL
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonBody,
      );

      // Check the response status
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Success - show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OwnerBookingPage(token: widget.token),
          ),
        );
      } else {
        // Server error - handle accordingly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Handle any exceptions during the API call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void fetchBookings() async {
    final response = await http.get(
      Uri.parse('$getOwnerBookings/$username'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          bookings =
              data['bookings']; // Update the lands list with the response data
        });
      } else {
        print("Error fetching requests: ${data['message']}");
      }
    } else {
      print("Failed to load requests: ${response.statusCode}");
    }
  }

  void fetchUser(String customerusername, String lineName) async {
    try {
      final response = await http.get(
        Uri.parse('$getUser/${customerusername}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final userInfo = data['data'];
          setState(() {
            customerEmail = userInfo['email'] ?? "";
          });

          // Fetch owner FCM token after updating owneremail
          fetchCustomerFcmToken(customerEmail, lineName);
        } else {
          print("Error fetching user: ${data['message']}");
        }
      } else {
        print("Failed to load user: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> fetchCustomerFcmToken(
      String customerEmail, String lineName) async {
    try {
      print("on fetch");
      // Query Firestore for a user with the same email as the owner
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: customerEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        setState(() {
          customerFCM = userDoc['fcmToken'] ?? "";
          customerID = userDoc.id; // Get the FCM token
        });
        print("Customer's FCM token: $customerFCM");
        print("Customer's document ID: $customerID");
        // Send the notification
        await NotificationService.instance.sendNotificationToSpecific(
          customerFCM,
          'تنبيه للحساب!  ',
          'لقد تلقى حسابك تنبيها جديدا من أحد المالكين',
        );

        // Save the notification
        await NotificationService.instance.saveNotificationToFirebase(
          customerFCM,
          '  تنبيه جديد',
          'لقد تلقيت تنبيها لحسابك نتيجة لعدم لعدم الحضور في الموعد المحدد لحجزك في ${lineName}، يرجى العلم بأنه سيتم تقييد الحساب عند تجاوز ثلاثة تنبيهات',
          customerID,
          'report',
        );
      } else {
        print("No user found with the email: $customerEmail");
      }
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
  }

  Future<void> reportCustomer(String customerUsername, String lineName) async {
    try {
      final response = await http.post(
        Uri.parse(reportUser), // Replace with your API URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': customerUsername}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Report incremented: ${data['updatedReports']}");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('تم إرسال التنبيه بنجاح.')),
        // );
        fetchUser(customerUsername, lineName);
      } else {
        print("Error incrementing reports: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء إرسال التنبيه.')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الاتصال بالخادم.')),
      );
    }
  }

  void handleCancelledItem(
      BuildContext context, String customerusername, String lineName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Text(
                'لم يحضر الزبون في الموعد المخصص له',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.left,
              ),
              SizedBox(width: 10),
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 30,
              ),
            ],
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'هل تريد إعطاء هذا المستخدم تنبيهاً؟',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel,
                    size: 20,
                    color: Colors.black,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'إلغاء',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                reportCustomer(customerusername, lineName);
                Navigator.of(context).pop();
                //print("Report submitted for $productName");
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.report,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'تنبيه المستخدم',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void showStatusDialog(String bookingId) {
    selectedStatus = buttonStatus; // Initialize with the current button status

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'تحديث الحالة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text('تمت'),
                    ),
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    trailing: Radio<String>(
                      value: 'Done',
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text('ملغاة'),
                    ),
                    leading: Icon(Icons.cancel, color: Colors.red),
                    trailing: Radio<String>(
                      value: 'Cancelled',
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text('لم يتحقق بعد'),
                    ),
                    leading: Icon(Icons.hourglass_bottom, color: Colors.orange),
                    trailing: Radio<String>(
                      value: 'Not Yet',
                      groupValue: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromRGBO(15, 99, 43, 1),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      buttonStatus = selectedStatus!;
                      buttonColor = buttonStatus == "Done"
                          ? Colors.green
                          : buttonStatus == "Cancelled"
                              ? Colors.red
                              : Colors.orange;
                      buttonIcon = buttonStatus == "Done"
                          ? Icons.check_circle
                          : buttonStatus == "Cancelled"
                              ? Icons.cancel
                              : Icons.pending;
                    });
                    bookingDecision(bookingId, selectedStatus);
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'حسنًا',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl, // جعل الكتابة من اليمين لليسار
        child: ListView(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.event, // أيقونة تدل على الحجز
                        size: 30,
                        color: Color.fromRGBO(15, 99, 43, 1), // لون زيتي
                      ),
                      SizedBox(width: 8),
                      Text(
                        "سجل حجز الزبائن",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(15, 99, 43, 1), // لون زيتي
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_forward, // سهم يتجه لليسار ليكون ع الشمال
                      size: 30,
                      color: Color.fromRGBO(15, 99, 43, 1), // لون زيتي
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEDECF2),
              ),
              child: Column(
                children: [
                  for (var booking in bookings)
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(15, 99, 43, 1)
                                    .withOpacity(0.6), // تأثير إضاءة زيتي
                                spreadRadius: 2,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // اسم خط الانتاج مع التصميم
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Customerprofile(
                                            username:
                                                booking['customerUsername'],
                                            userId: widget
                                                .userId, // Pass the worker's username
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  Color.fromRGBO(15, 99, 43, 1),
                                              width: 2, // زيتي إطار
                                            ),
                                            image: DecorationImage(
                                              image: booking['userImage'] !=
                                                      null
                                                  ? MemoryImage(base64Decode(
                                                      booking['userImage']))
                                                  : const AssetImage(
                                                          'assets/images/profilew.png')
                                                      as ImageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${booking['userFirstName']} ${booking['userLastName']}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    15, 99, 43, 1), // زيتي لون
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                SizedBox(width: 5),
                                                Text(
                                                  booking[
                                                      'customerUsername'], // التقييم
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color.fromARGB(
                                                        255, 100, 96, 96),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          // ضع الوظيفة التي تريد تنفيذها عند الضغط على الأيقونة
                                          print('Delete icon pressed');
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red, // لون الأيقونة
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.factory,
                                        color: Color.fromRGBO(15, 99, 43, 1),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        ' اسم خط الإنتاج: ${booking['lineName']}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.date_range,
                                        color: Color.fromRGBO(15, 99, 43, 1),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '  تاريخ الحجز : ${booking['date'].toString().substring(0, 10)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.time_to_leave,
                                        color: Color.fromRGBO(15, 99, 43, 1),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        ' وقت الحجز ${booking['startTime'].toString().substring(11, 16)} - ${booking['endTime'].toString().substring(11, 16)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_florist,
                                        color: Color.fromRGBO(15, 99, 43, 1),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'المادة الخام: ${booking['cropType']}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.scale,
                                        color: Color.fromRGBO(15, 99, 43, 1),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        ' الكمية :${booking['quantity']} كيلو',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        color: Color.fromRGBO(15, 99, 43, 1),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'السعر الكلي : ${booking['totalPrice']} ₪',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Color.fromRGBO(15, 99, 43, 1),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'تاريخ إرسال الطلب  : ${booking['createdAt'].toString().substring(0, 10)} ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 15),

                              ElevatedButton(
                                onPressed: () {
                                  if (booking['status'] == "canceled") {
                                    // Show dialog to report customer
                                    handleCancelledItem(
                                        context,
                                        booking['customerUsername'],
                                        booking['lineName']);
                                  } else {
                                    // Open the status dialog for other cases
                                    showStatusDialog(booking['_id']);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: booking['status'] ==
                                          "confirmed"
                                      ? Colors.green
                                      : booking['status'] == "canceled"
                                          ? Colors.red
                                          : Colors
                                              .orange, // Default color for "Not Yet"
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  minimumSize: Size(
                                      double.infinity, 0), // Full-width button
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      booking['status'] == "confirmed"
                                          ? Icons.check_circle
                                          : booking['status'] == "canceled"
                                              ? Icons.cancel
                                              : Icons
                                                  .pending, // Default icon for "Not Yet"
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      booking['status'] == "confirmed"
                                          ? "تمت"
                                          : booking['status'] == "canceled"
                                              ? "ملغاة"
                                              : "لم يتحقق بعد",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
