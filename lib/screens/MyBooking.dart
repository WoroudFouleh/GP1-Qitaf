import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/profile3.dart';
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class MyBookingPage extends StatefulWidget {
  final userId;
  final String token;
  const MyBookingPage({required this.token, Key? key, this.userId})
      : super(key: key);

  @override
  _MyBookingPageState createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  int quantity = 1; // الكمية الحالية
  double rating = 0; // قيمة التقييم الافتراضية (نجمة 4)
  List<dynamic> bookings = [];
  late String username;
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No username';

    fetchBookings(); // Call the fetch function when the page is loaded
  }

  void fetchBookings() async {
    final response = await http.get(
      Uri.parse('$getCustomerBookings/$username'),
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

  void deleteBooked(String bookId) async {
    try {
      print("request id: $bookId");
      final response = await http.delete(
        Uri.parse(
            '$deleteBooking/${bookId}'), // Send the URL without the username
        headers: {'Content-Type': 'application/json'},
        // Send the username in the body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          print("request deleted successfully");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyBookingPage(token: widget.token),
            ),
          );
        } else {
          print("Error deleting request1");
        }
      } else {
        print("Error deleting request2 ");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void rateProductionLine(String lineId, double rate) async {
    print("line id: $lineId");
    try {
      // Prepare the request body
      var reqBody = {
        'productionLineId': lineId,
        "newRate": rate,
      };

      // Make the POST request
      var response = await http.post(
        Uri.parse(rateLine), // Ensure the URL is correct
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          print('Product rated successfully');
          _showSuccessDialog();
          // setState(() {
          //   userRate = jsonResponse['product']
          //       ['rate']; // Access the rate from the response
          // });
        } else {
          print('Error rating product: ${jsonResponse['message']}');
        }
      } else {
        var errorResponse = jsonDecode(response.body);
        print('Error: ${errorResponse['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  void showRatingDialog(BuildContext context, String lineId, String lineName) {
    double rating = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(" ($lineName) قيّم خط الإنتاج"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("الرجاء تقييم خط الإنتاج"),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle the rating submission here
                print("User rated $rating stars for item $lineName");
                rateProductionLine(lineId, rating);
              },
              child: const Text("تقييم"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // زوايا مدورة
          ),
          contentPadding: EdgeInsets.all(20),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle, // أيقونة صح
                color: Colors.green,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                "تم تقييم خط الإنتاج بنجاح",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF556B2F), // لون زيتي
                ),
              ),
            ],
          ),
          actions: [
            Center(
              // لجعل الزر في المنتصف
              child: Container(
                width: double.infinity, // عرض الزر ليملأ النافذة
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF556B2F), // لون زيتي
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // زوايا مدورة
                    ),
                  ),
                  child: const Text(
                    "موافق",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // لون النص أبيض
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFailedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // زوايا مدورة
          ),
          contentPadding: EdgeInsets.all(20),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error, // أيقونة صح
                color: Colors.red,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                " تقييم خط الإنتاج غير متاح",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // لون زيتي
                ),
              ),
            ],
          ),
          actions: [
            Center(
              // لجعل الزر في المنتصف
              child: Container(
                width: double.infinity, // عرض الزر ليملأ النافذة
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // لون زيتي
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // زوايا مدورة
                    ),
                  ),
                  child: const Text(
                    "موافق",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // لون النص أبيض
                    ),
                  ),
                ),
              ),
            ),
          ],
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
                        "حجوزاتي",
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
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Color(0xFF556B2F),
                                          width: 2), // إطار زيتي
                                      image: const DecorationImage(
                                        image: AssetImage(
                                            'assets/images/q2.jpg'), // استبدل الصورة بمسارك
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ' ${booking['lineName']}', // اسم خط الإنتاج مع رقم مميز
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Color(0xFF556B2F), // لون زيتي
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.orange,
                                                size: 16,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "4.25", // التقييم
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 90),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // اسم المحصول
                                  Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .local_florist, // أيقونة تدل على المحصول
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'المادة الخام: ${booking['cropType']}',
                                        style: TextStyle(
                                          fontSize: 18, // حجم النص أكبر
                                          color: Colors.black, // لون النص أسود
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // موعد الحجز مع أيقونة ساعة
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.date_range,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'تاريخ الحجز  : ${booking['date'].toString().substring(0, 10)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black, // لون النص أسود
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // الكمية بالكيلو
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
                                          color: Colors.black, // لون النص أسود
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
                                        '  الكمية:  ${booking['quantity']}كيلو ',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black, // لون النص أسود
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // السعر
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        '  السعر:  ${booking['totalPrice']} NIS ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black, // لون النص أسود
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // الحساب
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_circle,
                                        color: Color(0xFF556B2F),
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      GestureDetector(
                                        onTap: () {
                                          // Navigate to the profile page and pass the username
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Ownerprofile2(
                                                userId: widget.userId,
                                                username: booking[
                                                    'ownerUsername'], // Pass the owner's username
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          '  حساب مالك خط الإنتاج:  ${booking['ownerUsername']} ',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors
                                                .black, // لون النص أزرق للإشارة إلى إمكانية التفاعل
                                            fontWeight: FontWeight.bold,
                                            // خط تحت النص للإشارة إلى رابط
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 15),

                              ElevatedButton(
                                onPressed:
                                    () {}, // Add your desired functionality here
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      booking['status'] == 'pending'
                                          ? Icons
                                              .hourglass_empty // Loading icon
                                          : booking['status'] == 'confirmed'
                                              ? Icons.check_circle // Check icon
                                              : Icons.cancel, // Cancelled icon
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      booking['status'] == 'pending'
                                          ? "لم يتحقق بعد"
                                          : booking['status'] == 'confirmed'
                                              ? "انتهت العملية"
                                              : "ملغي",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: booking['status'] ==
                                          'pending'
                                      ? Colors.amber // Amber color for pending
                                      : booking['status'] == 'confirmed'
                                          ? Colors
                                              .green // Green color for confirmed
                                          : Colors
                                              .red, // Red color for cancelled
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  minimumSize: Size(
                                      double.infinity, 0), // Full-width button
                                ),
                              ),
                            ],
                          ),
                        ),
                        // أيقونة النجمة داخل الدائرة في أعلى اليسار
                        Positioned(
                          top: 5,
                          left: 5,
                          child: InkWell(
                            onTap: () {
                              if (booking['status'] == "confirmed") {
                                showRatingDialog(context, booking['lineId'],
                                    booking['lineName']);
                              } else {
                                _showFailedDialog();
                              }
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFD700),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 5,
                          child: InkWell(
                            onTap: () {
                              deleteBooked(booking['_id']);
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 255, 0, 0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
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
