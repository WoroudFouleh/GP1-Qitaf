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
  late String ownerfirstName = "";
  late String ownerlastName = "";
  late String ownerFcmToken = "";
  late String ownerId = "";
  late String owneremail = "";

  void fetchUser() async {
    print("Sending username: ${widget.ownerUserName}");

    try {
      final response = await http.get(
        Uri.parse('$getUser/${widget.ownerUserName}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final userInfo = data['data'];
          setState(() {
            ownerfirstName = userInfo['firstName'] ?? "";
            ownerlastName = userInfo['lastName'] ?? "";

            owneremail = userInfo['email'] ?? "";
          });
        } else {
          print("Error fetching user: ${data['message']}");
        }
      } else {
        print("Failed to load user: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
    initializeNotificationService();
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

  void initializeNotificationService() async {
    await NotificationService.instance.initialize();
  }

  Future<void> fetchOwnerFcmToken() async {
    try {
      // Query Firestore for a user with the same email as the owner
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: owneremail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        setState(() {
          ownerFcmToken = userDoc['fcmToken'] ?? "";
          ownerId = userDoc.id; // Get the FCM token
        });
        print("Owner's FCM token: $ownerFcmToken");
        print("Owner's document ID: $ownerId");
      } else {
        print("No user found with the email: $owneremail");
      }
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
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
          await NotificationService.instance.sendNotificationToSpecific(
            ownerFcmToken,
            'طلب عمل جديد في أرض  ',
            'اضغط لمراجعة الطلب .${widget.landName}طلب عمل جديد في ',
          );
          await NotificationService.instance.saveNotificationToFirebase(
              ownerFcmToken,
              'طلب عمل جديد في أرض  ',
              '.${widget.landName}طلب عمل جديد في ',
              ownerId,
              'workRequest');
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
                const Color(0xFF556B2F),
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
              const SizedBox(width: 5),
              const Text(
                "/",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF7C7C7C),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                widget.workersWages.toString(),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF556B2F),
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                "₪",
                style: TextStyle(
                  fontSize: 20,
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
