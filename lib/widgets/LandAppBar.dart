import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LandAppBar extends StatelessWidget {
  const LandAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(15, 99, 43, 1), // لون الأرضية زيتي
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      child: Row(
        children: [
          // السهم على اليسار
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              size: 30,
              color: Colors.white, // لون السهم أبيض
            ),
          ),
          const Spacer(), // Push the text to the right
          // النص
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text(
              "الأرض الزراعية",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.white, // لون النص أبيض
              ),
            ),
          ),
          // أيقونة سلة المشتريات
          const Icon(
            Icons.landscape, // أيقونة تدل على أرض زراعية
            color: Colors.white, // لون الأيقونة أبيض
          )
        ],
      ),
    );
  }
}
