import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_page/screens/booking.dart';

class LineBottonBar extends StatelessWidget {
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
  const LineBottonBar(
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
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ElevatedButton on the left
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingPage(
                    price: price,
                    quantityUnit: quantityUnit,
                    lineName: lineName,
                    lineId: lineId,
                    lineRate: lineRate,
                    location: location,
                    city: city,
                    cropType: cropType,
                    startTime: startTime,
                    endTime: endTime,
                    days: days,
                    description: description,
                    preparationTime: preparationTime,
                    preparationUnit: preparationUnit,
                    image: image,
                    token: token,
                    ownerUsername: ownerUsername,
                  ), // Pass data if needed
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                const Color.fromRGBO(15, 99, 43, 1), // لون كبسة زيتي
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
              ),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            label: const Text(
              "إضافة حجز",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // لون النص أبيض
              ),
            ),
            icon: const Icon(
              Icons.add_circle_outline, // أيقونة تدل على إضافة حجز
              color: Colors.white, // لون الأيقونة أبيض
            ),
          ),
          // Price on the right with separate currency and weight text
          Row(
            children: [
              // Weight text
              Text(
                quantityUnit, // نص الوزن
                style: TextStyle(
                  fontSize: 18, // حجم الخط أقل من السعر
                  color: Color(0xFF7C7C7C), // لون أقل شدة
                ),
              ),
              SizedBox(width: 5), // إضافة مسافة بين السلاش و"كغم"
              Text(
                "/", // السلاش
                style: TextStyle(
                  fontSize: 18, // حجم الخط للسلاش
                  color: Color(0xFF7C7C7C), // لون أقل شدة
                ),
              ),
              SizedBox(width: 5), // إضافة مسافة بين السلاش والرقم
              // Price
              Text(
                price.toString(), // الرقم فقط
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(15, 99, 43, 1), // لون الرقم زيتي
                ),
              ),
              SizedBox(width: 5), // إضافة مسافة بين الرقم والعملة
              // Currency
              Text(
                "₪", // العملة
                style: TextStyle(
                  fontSize: 20, // حجم الخط للعملة
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(15, 99, 43, 1), // لون العملة زيتي
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
