import 'package:cloud_firestore/cloud_firestore.dart';
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
  late String ownerEmail;
  late String ownerFCM;
  late String ownerID;
  @override
  void initState() {
    super.initState();
    fetchUser();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    //print(jwtDecoderToken);
    workerUserName = jwtDecoderToken['username'] ?? 'No username';
    workerCity = jwtDecoderToken['city'] ?? 'No city';
    workerGender = jwtDecoderToken['gender'] ?? 'No gender';
    workerFirstname = jwtDecoderToken['firstName'] ?? 'No gender';
    workerLastname = jwtDecoderToken['lastName'] ?? 'No gender';
    workerProfileImage = jwtDecoderToken['profilePhoto'] ?? 'No gender';
    userRate = jwtDecoderToken['rate'] ?? 0.0;
  }

  void fetchUser() async {
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
            // customerFirstname = userInfo['firstName'] ?? "";
            // customerLasttname = userInfo['lastName'] ?? "";
            ownerEmail = userInfo['email'] ?? "";
          });
          fetchCustomerFcmToken();

          // Fetch owner FCM token after updating owneremail
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

  Future<void> fetchCustomerFcmToken() async {
    try {
      print("on fetch");
      // Query Firestore for a user with the same email as the owner
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: ownerEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        setState(() {
          ownerFCM = userDoc['fcmToken'] ?? "";
          ownerID = userDoc.id; // Get the FCM token
        });
        print("Customer's FCM token: $ownerFCM");
        print("Customer's document ID: $ownerID");
        // Send the notification

        // Save the notification
      } else {
        print("No user found with the email: $ownerEmail");
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
          await NotificationService.instance.saveNotificationToFirebase(
              ownerFCM,
              'طلب عمل جديد في أرض  ',
              'طلب عمل جديد في "${widget.landName}". اضغط لمراجعة الطلب',
              ownerID,
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
                const Color.fromRGBO(15, 99, 43, 1),
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
                  color: const Color.fromRGBO(15, 99, 43, 1),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "₪",
                style: TextStyle(
                  fontSize: 25, // Larger font for currency symbol
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(15, 99, 43, 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
