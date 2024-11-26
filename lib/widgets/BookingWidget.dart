import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:login_page/screens/config.dart';

class BookingWidget extends StatefulWidget {
  final int price;
  final String quantityUnit;
  final String lineName;
  final String lineId;
  final double lineRate;
  final String image;
  final String description;
  final String preparationTime;
  final String preparationUnit;
  final String city;
  final String location;
  final String cropType;
  final List<String> days;
  final String startTime;
  final String endTime;
  final String token;
  final String ownerUsername;
  const BookingWidget(
      {super.key,
      required this.price,
      required this.quantityUnit,
      required this.lineName,
      required this.lineId,
      required this.lineRate,
      required this.image,
      required this.description,
      required this.preparationTime,
      required this.preparationUnit,
      required this.city,
      required this.location,
      required this.cropType,
      required this.days,
      required this.startTime,
      required this.endTime,
      required this.token,
      required this.ownerUsername});

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  TextEditingController timeController =
      TextEditingController(); // الحقل الخاص بالوقت
  TextEditingController quantityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cropController = TextEditingController();
  // الحقل الخاص بالوقت
  DateTime _startDate = DateTime.now();

  List<String> bookedTimes = [];
  int flag = 0;
  String selectedTime = ''; // الوقت المحدد
  double totalPrice = 0.0;
  double revenue = 0.0;
  double finalPrice = 0.0;
  int pricePerUnit = 100; // Replace with the actual price per unit
  String? selectedDateAndTime;
  late DateTime endDateTime;
  late DateTime selectedDateTime;
  late String selectedDayInArabic;
  late String customerUsername;
  late String customerImage;
  late String customerFirstName;
  late String customerLastName;

// Function to calculate total price and revenue
  @override
  void initState() {
    super.initState();
    quantityController.text = "0";
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    customerUsername = jwtDecoderToken['username'] ?? 'No username';
    customerImage = jwtDecoderToken['profilePhoto'] ?? 'No username';
    customerFirstName = jwtDecoderToken['firstName'] ?? 'No username';
    customerLastName = jwtDecoderToken['lastName'] ?? 'No username';
  }

  void sendBookingRequest() async {
    try {
      // Prepare the request body
      var reqBody = {
        "lineId": widget.lineId,
        "lineName": widget.lineName,
        'ownerUsername': widget.ownerUsername,
        "userPhone": phoneController.text,
        "userImage": customerImage,
        "userFirstName": customerFirstName,
        "userLastName": customerLastName,
        "customerUsername": customerUsername,
        "quantity": int.tryParse(quantityController.text),
        "date": _startDate.toIso8601String(),
        "startTime": selectedDateTime.toIso8601String(),
        "endTime": endDateTime.toIso8601String(),
        "totalPrice": finalPrice,
        "revenuePrice": revenue,
        "cropType": cropController.text,
      };

      // Make the POST request
      var response = await http.post(
        Uri.parse(newBooking), // Ensure the URL is correct
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          print('Request sent successfully');
        } else {
          print('Error sending request: ${jsonResponse['message']}');
        }
      } else {
        var errorResponse = jsonDecode(response.body);
        print('Error: ${errorResponse['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  void getBooked() async {
    try {
      // Prepare the request body
      var reqBody = {
        "lineId": widget.lineId,
        "date": _startDate.toIso8601String(),
      };

      // Make the POST request
      var response = await http.post(
        Uri.parse(getPrevBooked), // Ensure the URL is correct
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          bookedTimes = List<String>.from(jsonResponse['bookedTimes']);
          print('Booked times fetched successfully: $bookedTimes');
          flag = 1;
        } else {
          print('Error fetching: ${jsonResponse['message']}');
        }
      } else {
        var errorResponse = jsonDecode(response.body);
        print('Error: ${errorResponse['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  bool isDayAndTimeValid(DateTime selectedDate, TimeOfDay selectedTime) {
    // Step 1: Validate the day
    String selectedDay = DateFormat('EEEE', 'en_US').format(selectedDate);
    print("selectedDay in English: $selectedDay");

    Map<String, String> englishToArabicDayMap = {
      'Monday': 'الاثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
    };

    selectedDayInArabic = englishToArabicDayMap[selectedDay] ?? selectedDay;
    print("selectedDay in Arabic: $selectedDayInArabic");

    if (!widget.days.contains(selectedDayInArabic)) {
      print("Invalid day: $selectedDayInArabic");
      return false; // Invalid day
    }

    // Step 2: Validate the time
    DateTime startWorkTime = DateFormat("HH:mm").parse(widget.startTime);
    DateTime endWorkTime = DateFormat("HH:mm").parse(widget.endTime);

    selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    DateTime startWorkDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startWorkTime.hour,
      startWorkTime.minute,
    );

    DateTime endWorkDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endWorkTime.hour,
      endWorkTime.minute,
    );

    if (selectedDateTime.isBefore(startWorkDateTime) ||
        selectedDateTime.isAfter(endWorkDateTime)) {
      return false; // Invalid time
    }

    // Step 3: Calculate the end time based on preparation time and quantity
    // Assuming preparationTime is in minutes as a string, e.g., "20" minutes
    int preparationMinutes = 0;

    try {
      preparationMinutes = int.parse(
          widget.preparationTime); // Parse the preparation time (in minutes)
    } catch (e) {
      print("Invalid preparation time format.");
      return false; // Invalid preparation time
    }

    // Get the quantity input and convert it to an integer
    int quantity = 0;
    try {
      quantity = int.parse(quantityController.text); // Convert quantity to int
    } catch (e) {
      print("Invalid quantity input.");
      return false; // If quantity is invalid, return false
    }

    // Calculate the total duration needed for the selected quantity
    Duration unitTime = Duration(
        minutes: preparationMinutes); // Duration per quantity in minutes
    Duration totalDuration =
        unitTime * quantity; // Multiply by quantity to get total time

    // Calculate the end time by adding the total duration to the selected start time
    endDateTime = selectedDateTime.add(totalDuration);

    print("Start Time: $selectedDateTime");
    print("End Time: $endDateTime");

    // Step 4: Check if the selected time range (start time to end time) conflicts with any already booked time

    for (String bookedTimeRange in bookedTimes) {
      List<String> times = bookedTimeRange.split('-');
      print("Split result: $times");
      if (times.length != 2) {
        print("Invalid format, skipping this entry.");
        continue;
      }
      DateTime bookedStartTime = DateFormat("HH:mm").parse(times[0]);
      DateTime bookedEndTime = DateFormat("HH:mm").parse(times[1]);

      print("Booked Start Time: $bookedStartTime");
      print("Booked End Time: $bookedEndTime");

      DateTime bookedStartDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        bookedStartTime.hour,
        bookedStartTime.minute,
      );
      DateTime bookedEndDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        bookedEndTime.hour,
        bookedEndTime.minute,
      );
//       print("Checking against booked time range: $bookedTimeRange");
// print("Booked Start Time: $bookedStartDateTime");
// print("Booked End Time: $bookedEndDateTime");

      // Check if the selected time range conflicts with the booked time range
      if ((selectedDateTime.isBefore(bookedEndDateTime) &&
              endDateTime.isAfter(bookedStartDateTime)) ||
          (selectedDateTime.isBefore(bookedEndDateTime) &&
              selectedDateTime.isAfter(bookedStartDateTime))) {
        print("Conflict with booked time: $bookedTimeRange");
        return false; // Conflict found
      }
    }

    return true; // Day and time are valid
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: const Color.fromARGB(255, 215, 230, 189),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80, // Increased height
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "قم بتعبئة تفاصيل الحجز",
                    style: TextStyle(
                      fontSize: 25,
                      color: Color(0xFF556B2F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Workdays and Hours Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF475269).withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "أيام العمل وساعات العمل",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF556B2F),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Days Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "أيام العمل",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF475269),
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (String day in widget.days)
                              Text(
                                day,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                      ),
                      // Vertical Divider
                      Container(
                        width: 1,
                        height: 100,
                        color: const Color(0xFF475269),
                      ),
                      // Working Hours Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "ساعات العمل",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF475269),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${widget.startTime} - ${widget.endTime}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.only(left: 15, top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              width: 370,
              child: TextFormField(
                controller: phoneController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "رقم الهاتف",
                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF556B2F),
                    inherit: true, // التأكد من التناسق
                  ),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(left: 15, top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              width: 370,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // لترتيب العناصر من اليمين لليسار
                children: [
                  const Text(
                    "كيلو",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF355E3B),
                      inherit: true, // التأكد من التناسق
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: quantityController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: " الكميّة ",
                        hintStyle: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF556B2F),
                          inherit: true, // التأكد من التناسق
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 15, top: 10, bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              width: 370,
              child: TextFormField(
                controller: cropController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "الثمار",
                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF556B2F),
                    inherit: true, // التأكد من التناسق
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.9, // عرض الزر بالكامل
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _startDate = pickedDate;
                              print("startDate: ${_startDate}");
                            });
                          }
                        },
                        child: Text(
                          _startDate == null
                              ? 'حدد تاريخ الحجز'
                              : DateFormat('yyyy-MM-dd').format(_startDate!),
                          style: const TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 26, 115, 12)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF556B2F),
                          side: BorderSide(color: Color(0xFF556B2F), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ElevatedButton(
                        onPressed: () {
                          getBooked();
                          if (flag == 1) {
                            _showAvailableTimes();
                          }
                        },

                        //_showAvailableTimes,
                        child: const Text(
                          "إضافة موعد",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF556B2F),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF475269).withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            calculatePrice1(int.parse(quantityController.text))
                                .toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475269),
                            ),
                          ),
                          SizedBox(width: 5), // مسافة بين الرقم ورمز العملة
                          Text(
                            "₪", // رمز الشيكل
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475269),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ":الإجمالي الفرعي",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475269),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20, // تقليل ارتفاع الفاصل
                    thickness: 0.5,
                    color: Color(0xFF475269),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            calculateRevenue(calculatePrice1(
                                    int.parse(quantityController.text)))
                                .toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475269),
                            ),
                          ),
                          SizedBox(width: 5), // مسافة بين الرقم ورمز العملة
                          Text(
                            "₪", // رمز الشيكل
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475269),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ":ربح للمنصة(5%)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475269),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20, // تقليل ارتفاع الفاصل
                    thickness: 0.5,
                    color: Color(0xFF475269),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            calculateTotalPrice(
                                    int.parse(quantityController.text))
                                .toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475269),
                            ),
                          ),
                          SizedBox(width: 5), // مسافة بين الرقم ورمز العملة
                          Text(
                            "₪", // رمز الشيكل
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475269),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ":المبلغ الكلي",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475269),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // زر "تأكيد الحجز"
            // Booking Summary

            const SizedBox(height: 10),

            // Confirm Booking Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  confirmBooking();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF556B2F),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  "تأكيد الحجز",
                  style: TextStyle(
                      fontFamily: 'CustomArabicFont', color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

// Confirm booking button logic
  void confirmBooking() {
    if (_startDate != null && selectedTime != null) {
      final timeOfDay = stringToTimeOfDay(selectedTime!);
      if (timeOfDay != null && isDayAndTimeValid(_startDate!, timeOfDay)) {
        selectedDateAndTime =
            "${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${selectedTime!}";

        print("Booking Confirmed: Date and Time: $selectedDateAndTime");
        print("Total Price: $totalPrice");
        print("Revenue: $revenue");
        sendBookingRequest();

        // Add booking logic to save to the database
        _showBookingConfirmation(selectedDateAndTime.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('الرجاء اختيار تاريخ ووقت صالحين.'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('يرجى تعبئة جميع الحقول.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showBookingConfirmation(String selected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          mainAxisAlignment:
              MainAxisAlignment.end, // لجعل العناصر تبدأ من اليمين
          children: [
            Text(
              'تم تثبيت الحجز',
              style: TextStyle(
                fontWeight: FontWeight.bold, // النص بالخط العريض
                fontSize: 18,
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.check_circle,
              color: Color(0xFF556B2F), // أيقونة صح باللون الزيتي
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // جعل النص يبدأ من اليمين
          mainAxisSize: MainAxisSize.min, // لتقليل المساحة المستخدمة في الفقرة
          children: [
            SizedBox(height: 20),
            Text(
              ':موعد الحجز المعتمد ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.normal, // النص بدون خط عريض
              ),
              textAlign: TextAlign.right, // النص من اليمين لليسار
            ),
            SizedBox(height: 10),
            Text(
              'اليوم: $selectedDayInArabic ${_startDate.toString().substring(0, 10)}',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.normal, // النص بدون خط عريض
              ),
              textAlign: TextAlign.right, // النص من اليمين لليسار
            ),
            SizedBox(height: 10),
            Text(
              ' ${endDateTime.toString().substring(11, 16)} - ${selected.split(" - ")[1]} :الوقت',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.normal, // النص بدون خط عريض
              ),
              textAlign: TextAlign.right, // النص من اليمين لليسار
            ),
            SizedBox(height: 10),
            Text(
              'تم تثبيت الحجز. إذا تأخرت عن موعد الحجز لأكثر من 10 دقائق، سوف يتم إلغاؤه.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal, // النص بدون خط عريض
              ),
              textAlign: TextAlign.right, // النص من اليمين لليسار
            ),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          // زر "موافق" مع إطار زيتي والنص باللون الأبيض
          Align(
            alignment: Alignment.centerLeft, // محاذاة الزر إلى اليسار
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'موافق',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white, // النص باللون الأبيض
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF556B2F), // الخلفية باللون الزيتي
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Color(0xFF556B2F), width: 2), // الإطار زيتي
                  borderRadius: BorderRadius.circular(5),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay? stringToTimeOfDay(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null; // Return null if the string format is invalid
    }
  }

  void _showAvailableTimes() {
    getBooked();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF7F7F7), // خلفية خفيفة
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "الأوقات المحجوزة",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF556B2F),
              ),
            ),
            if (_startDate != null)
              Text(
                "للتاريخ: ${DateFormat('yyyy-MM-dd').format(_startDate!)}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
          ],
        ),
        content: Container(
          width: 300, // عرض ثابت
          height: 300, // تحديد ارتفاع ثابت
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // استخدام ListView داخل Expanded لضمان أنه يأخذ المساحة المتاحة
              Expanded(
                child: ListView.builder(
                  itemCount: bookedTimes.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF556B2F),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          bookedTimes[index],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // زر لإضافة وقت جديد
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = '${pickedTime.hour}:${pickedTime.minute}';
                      bookedTimes.add(selectedTime);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "إضافة وقت",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF556B2F),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                flag = 0;
                Navigator.pop(context);
              },
              child: const Text(
                "إغلاق",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF556B2F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double calculatePrice1(int quantity) {
    totalPrice = quantity * (widget.price).toDouble();
    return totalPrice; // Assuming 5% revenue for the platform
  }

  double calculateRevenue(double totalPrice) {
    revenue = totalPrice * 0.05;
    return revenue;
  }

  double calculateTotalPrice(int quantity) {
    totalPrice = quantity * (widget.price).toDouble();
    revenue = totalPrice * 0.05;
    finalPrice = revenue + totalPrice;
    return revenue + totalPrice;
  }
}
