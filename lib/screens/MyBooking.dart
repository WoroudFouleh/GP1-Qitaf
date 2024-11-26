import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class MyBookingPage extends StatefulWidget {
  final String token;
  const MyBookingPage({required this.token, Key? key}) : super(key: key);

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

  void _showRatingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "تقييم خط الإنتاج",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF556B2F), // لون زيتي
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        color: Color(0xFF556B2F),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  itemSize: 40,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      this.rating = rating;
                    });
                  },
                  textDirection: TextDirection.rtl, // النجوم تبدأ من اليمين
                ),
                SizedBox(height: 20),
                // تصغير زر "تم"
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // إغلاق الـ BottomSheet
                    _showSuccessDialog(); // عرض النافذة الجديدة
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF556B2F), // لون زيتي
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20), // تصغير حجم الزر
                  ),
                  child: Text(
                    "تم",
                    style: TextStyle(
                      fontSize: 16, // تصغير النص
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ' ${booking['lineName']}', // اسم خط الإنتاج مع رقم مميز
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF556B2F), // لون زيتي
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
                                      Text(
                                        '  حساب مالك خط الإنتاج:  ${booking['ownerUsername']} ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black, // لون النص أسود
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 15),

                              ElevatedButton(
                                onPressed: () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.pending,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "لم يتحقق بعد",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  minimumSize:
                                      Size(double.infinity, 0), // عرض الزر كامل
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
                            onTap: _showRatingBottomSheet,
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
