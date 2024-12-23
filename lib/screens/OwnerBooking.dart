import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/customerProfile.dart';

import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class OwnerBookingPage extends StatefulWidget {
  final String token;
  final userId;
  const OwnerBookingPage({required this.token, Key? key, this.userId}) : super(key: key);

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
                    backgroundColor: Colors.green,
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
                        color: Color(0xFF556B2F), // لون زيتي
                      ),
                      SizedBox(width: 8),
                      Text(
                        "سجل حجز الزبائن",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF556B2F), // لون زيتي
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
                      color: Color(0xFF556B2F), // لون زيتي
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
                                color: const Color.fromARGB(255, 113, 134, 25)
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
                                            username: booking[
                                                'customerUsername'],
                                                userId: widget.userId, // Pass the worker's username
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
                                              color: Color(0xFF556B2F),
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
                                                color: Color(
                                                    0xFF556B2F), // زيتي لون
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
                                        color: Color(0xFF556B2F),
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
                                        color: Color(0xFF556B2F),
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
                                        color: Color(0xFF556B2F),
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
                                        color: Color(0xFF556B2F),
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
                                        color: Color(0xFF556B2F),
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
                                        color: Color(0xFF556B2F),
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
                                        color: Color(0xFF556B2F),
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
                                  showStatusDialog(
                                      booking['_id']); // Open the dialog
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
