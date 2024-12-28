import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LandBottonBar extends StatefulWidget {
  final String token;
  final String ownerUserName;
  final int workersWages;
  final int numOfWorkers;
  final String landLocation;
  final String landName;
  final String landId;

  const LandBottonBar({
    super.key,
    required this.token,
    required this.ownerUserName,
    required this.workersWages,
    required this.numOfWorkers,
    required this.landLocation,
    required this.landName,
    required this.landId,
  });

  @override
  State<LandBottonBar> createState() => _LandBottonBarState();
}

class _LandBottonBarState extends State<LandBottonBar> {
  late String workerUserName;
  late String workerFirstname = "";
  late String workerLastname = "";
  late String workerProfileImage = "";
  late String workerCity;
  late String workerGender;
  late double userRate;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    workerUserName = jwtDecoderToken['username'] ?? 'No username';
    workerCity = jwtDecoderToken['city'] ?? 'No city';
    workerGender = jwtDecoderToken['gender'] ?? 'No gender';
    workerFirstname = jwtDecoderToken['firstName'] ?? 'No gender';
    workerLastname = jwtDecoderToken['lastName'] ?? 'No gender';
    workerProfileImage = jwtDecoderToken['profilePhoto'] ?? 'No gender';
    userRate = jwtDecoderToken['rate'] ?? 0.0;
  }

  void sendWorkRequest() async {
    try {
      // Prepare the request body
      var reqBody = {
        'ownerUsername': widget.ownerUserName,
        "workerUsername": workerUserName,
        "workerFirstname": workerFirstname,
        "workerLastname": workerLastname,
        "workerProfileImage": workerProfileImage,
        "workerCity": workerCity,
        "workerGender": workerGender,
        "workerRate": userRate,
        "landId": widget.landId,
        "landName": widget.landName,
        "landLocation": widget.landLocation,
        "numOfWorkers": widget.numOfWorkers,
        "workerWage": widget.workersWages,
      };

      // Make the POST request
      var response = await http.post(
        Uri.parse(registerWorkRequest), // Ensure the URL is correct
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Increased height for better web readability
      padding: const EdgeInsets.symmetric(
          horizontal: 30), // Adjusted horizontal padding for web
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15), // Slightly more rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius:
                4, // Increased spread radius for a more prominent shadow
            blurRadius: 15, // Increased blur radius
            offset: const Offset(0, 5), // Adjusted offset to match web feel
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              sendWorkRequest();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                const Color(0xFF556B2F),
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20), // Adjusted padding for bigger buttons
              ),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      25), // Larger rounded corners for web-friendly design
                ),
              ),
            ),
            label: const Text(
              "طلب الإنضمام إلى العمل",
              style: TextStyle(
                fontSize: 18, // Larger font for web readability
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            icon: const Icon(
              CupertinoIcons.person_add,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              const Text(
                "ساعة",
                style: TextStyle(
                  fontSize: 20, // Slightly larger font for web
                  color: Color(0xFF7C7C7C),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "/",
                style: TextStyle(
                  fontSize: 20, // Slightly larger font for web
                  color: Color(0xFF7C7C7C),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.workersWages.toString(),
                style: const TextStyle(
                  fontSize: 30, // Increased font size for better readability
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF556B2F),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "₪",
                style: TextStyle(
                  fontSize: 25, // Larger font for currency symbol
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF556B2F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
