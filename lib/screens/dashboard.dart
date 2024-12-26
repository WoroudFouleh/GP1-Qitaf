import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class dashboard extends StatefulWidget {
  final token;
  const dashboard({@required this.token, Key? key}) : super(key: key);

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  late String username;
  late String email;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);

    username = jwtDecoderToken['username'];
    email = jwtDecoderToken['email'];
  }

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
