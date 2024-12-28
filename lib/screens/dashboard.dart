import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class dashboard extends StatefulWidget {
  const dashboard({Key? key}) : super(key: key);

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  String username = "ahmad";
  String email = "ali";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(username),
            Text(email),
          ],
        ),
      ),
    );
  }
}
