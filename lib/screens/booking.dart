import 'package:flutter/material.dart';
import 'package:login_page/widgets/BookingWidget.dart';
import 'package:login_page/widgets/BookingAppBar.dart';
import 'package:login_page/widgets/CartItemSamples.dart';
import 'package:login_page/widgets/OrderWidget.dart';

class BookingPage extends StatelessWidget {
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
  const BookingPage(
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
    return Scaffold(
      body: ListView(
        children: [
          BookingAppBar(),
          Container(
            // padding: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Color(0xFFEDECF2),
            ),
            child: Column(
              children: [
                BookingWidget(
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
                    ownerUsername: ownerUsername),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
