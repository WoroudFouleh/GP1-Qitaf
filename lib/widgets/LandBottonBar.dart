import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:login_page/services/notification_service.dart';

class LandBottonBar extends StatefulWidget {
  final String token;
  final String ownerUserName;
  final int workersWages;
  final int numOfWorkers;
  final String landLocation;
  final String landName;
  final String landId;
  final String workerUserName;
  final String workerFirstname;
  final String workerLastname;
  final String workerProfileImage;
  final String workerCity;
  final String workerGender;
  final double userRate;

  final String ownerFcmToken;
  final String ownerId;

  const LandBottonBar({
    super.key,
    required this.token,
    required this.ownerUserName,
    required this.workersWages,
    required this.numOfWorkers,
    required this.landLocation,
    required this.landName,
    required this.landId,
    required this.workerUserName,
    required this.workerFirstname,
    required this.workerLastname,
    required this.workerProfileImage,
    required this.workerCity,
    required this.workerGender,
    required this.userRate,
    required this.ownerFcmToken,
    required this.ownerId,
  });

  @override
  State<LandBottonBar> createState() => _LandBottonBarState();
}

class _LandBottonBarState extends State<LandBottonBar> {
  @override
  void initState() {
    super.initState();

    initializeNotificationService();

    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
  }

  void initializeNotificationService() async {
    await NotificationService.instance.initialize();
  }

  void sendWorkRequest() async {
    try {
      // Prepare the request body
      var reqBody = {
        'ownerUsername': widget.ownerUserName,
        "workerUsername": widget.workerUserName,
        "workerFirstname": widget.workerFirstname,
        "workerLastname": widget.workerLastname,
        "workerProfileImage": widget.workerProfileImage,
        "workerCity": widget.workerCity,
        "workerGender": widget.workerGender,
        "workerRate": widget.userRate,
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
          await NotificationService.instance.sendNotificationToSpecific(
            widget.ownerFcmToken,
            'طلب عمل جديد في أرض  ',
            '. طلب عمل جديد في ${widget.landName}',
          );
          await NotificationService.instance.saveNotificationToFirebase(
              widget.ownerFcmToken,
              'طلب عمل جديد في أرض  ',
              'طلب عمل جديد في "${widget.landName}". اضغط لمراجعة الطلب',
              widget.ownerId,
              'workRequest');

          showCustomDialog(
            context: context,
            icon: Icons.check,
            iconColor: Color.fromRGBO(15, 99, 43, 1),
            title: "تمّ بنجاح",
            message: "!تمّ إرسال طلب العمل بنجاح",
            buttonText: "حسناً",
          );
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

  void showCustomDialog({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String buttonText,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 48.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 12.0),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
          ElevatedButton.icon(
            onPressed: () {
              sendWorkRequest();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                const Color.fromRGBO(15, 99, 43, 1),
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
              ),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            label: const Text(
              "طلب الإنضمام إلى العمل",
              style: TextStyle(
                fontSize: 16,
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
                  fontSize: 18,
                  color: Color(0xFF7C7C7C),
                ),
              ),
              const Text(
                "/",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF7C7C7C),
                ),
              ),
              const SizedBox(width: 1),
              Text(
                widget.workersWages.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(15, 99, 43, 1),
                ),
              ),
              const Text(
                "₪",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(15, 99, 43, 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
