import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:login_page/screens/config.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/workerProfile.dart';
import 'package:login_page/services/notification_service.dart';
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class OwnerWorkingPage extends StatefulWidget {
  final String token;
  final String userId;
  const OwnerWorkingPage({required this.token, Key? key, required this.userId})
      : super(key: key);

  @override
  _OwnerWorkingPageState createState() => _OwnerWorkingPageState();
}

class _OwnerWorkingPageState extends State<OwnerWorkingPage> {
  int quantity = 1; // الكمية الحالية
  List<dynamic> requests = [];
  late String username;
  late String userfirstName = "";
  late String userlastName = "";
  late String userFcmToken = "";
  late String workerId = "";
  late String useremail = "";
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No username';

    fetchRequests(); // Call the fetch function when the page is loaded
  }

//////TO GET THE WORKER
  void fetchUser(String workerUsername) async {
    try {
      final response = await http.get(
        Uri.parse('$getUser/${workerUsername}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final userInfo = data['data'];
          setState(() {
            userfirstName = userInfo['firstName'] ?? "";
            userlastName = userInfo['lastName'] ?? "";
            useremail = userInfo['email'] ?? "";
          });

          // Fetch owner FCM token after updating owneremail
          fetchWorkerFcmToken();
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

  void initializeNotificationService() async {
    await NotificationService.instance.initialize();
  }

  Future<void> fetchWorkerFcmToken() async {
    try {
      print("on fetch");
      // Query Firestore for a user with the same email as the owner
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: useremail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        setState(() {
          userFcmToken = userDoc['fcmToken'] ?? "";
          workerId = userDoc.id; // Get the FCM token
        });
        print("Owner's FCM token: $userFcmToken");
        print("Owner's document ID: $workerId");
      } else {
        print("No user found with the email: $useremail");
      }
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
  }

  void requestDecision(String requestId, String status, String landId,
      String workerUsername, String landName) async {
    try {
      fetchUser(workerUsername);
      print('Request ID: $requestId, Status: $status');
      // Convert image to base64 if an image is selected
      //String? base64Image = _image != null ? base64Encode(_image!) : null;

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'status': status,
        'requestId': requestId,
      };

      // Convert the request body to JSON format
      String jsonBody = jsonEncode(requestBody);

      // Send the request to the backend
      var response = await http.put(
        Uri.parse(takeDecision), // Replace with your backend URL
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonBody,
      );

      // Check the response status
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Success - show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح!')),
        );
        if (status == "accepted") {
          updateWorkersNum(landId);
          await NotificationService.instance.sendNotificationToSpecific(
            userFcmToken,
            'قبول طلب العمل في أرض ',
            '. تم قبول طلب عملك في $landName',
          );
          await NotificationService.instance.saveNotificationToFirebase(
              userFcmToken,
              'قبول طلب العمل في أرض ',
              'لقد وافق مالك أرض  "$landName "على طلبك للعمل فيها. اضغط لرؤية التفاصيل ',
              workerId,
              'workDecision');
        } else if (status == "rejected") {
          // updateWorkersNum(landId);
          await NotificationService.instance.sendNotificationToSpecific(
            userFcmToken,
            'رفض طلب العمل في أرض ',
            '. تم رفض طلب عملك في $landName',
          );
          await NotificationService.instance.saveNotificationToFirebase(
              userFcmToken,
              'رفض طلب العمل في أرض ',
              'لقد رفض مالك أرض  "$landName " طلبك للعمل فيها. اضغط لرؤية التفاصيل ',
              workerId,
              'workDecision');
        }
      } else {
        // Server error - handle accordingly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Handle any exceptions during the API call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void updateWorkersNum(String landId) async {
    try {
      // Prepare the order details

      // Send the request to your backend API
      final response = await http.put(
        Uri.parse('$updateWorkers/${landId}'), // Replace with your API URL
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حذف المنشور بنجاح")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OwnerWorkingPage(token: widget.token, userId: widget.userId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("حدث خطأ أثناء حذف المنشور")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الاتصال بالخادم")),
      );
    }
  }

  void fetchRequests() async {
    final response = await http.get(
      Uri.parse('$getOwnerRequests/$username'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          requests =
              data['requests']; // Update the lands list with the response data
        });
      } else {
        print("Error fetching requests: ${data['message']}");
      }
    } else {
      print("Failed to load requests: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl, // جعل الكتابة من اليمين لليسار
        child: ListView(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.event, // أيقونة تدل على الحجز
                        size: 30,
                        color: Color.fromRGBO(15, 99, 43, 1), // لون زيتي
                      ),
                      SizedBox(width: 8),
                      Text(
                        " طلبات عمل العمّال ",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(15, 99, 43, 1), // لون زيتي
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_forward, // سهم يتجه لليسار ليكون ع الشمال
                      size: 30,
                      color: Color.fromRGBO(15, 99, 43, 1), // لون زيتي
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEDECF2),
              ),
              child: Column(
                children: [
                  for (var request in requests)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(15, 99, 43, 1)
                                .withOpacity(0.6), // تأثير إضاءة زيتي
                            spreadRadius: 2,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // اسم خط الانتاج مع التصميم
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Workerprofile(
                                              username:
                                                  request['workerUsername'],
                                              userId: widget
                                                  .userId // Pass the worker's username
                                              ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  Color.fromRGBO(15, 99, 43, 1),
                                              width: 2, // زيتي إطار
                                            ),
                                            image: DecorationImage(
                                              image: request[
                                                          'workerProfileImage'] !=
                                                      null
                                                  ? MemoryImage(base64Decode(
                                                      request[
                                                          'workerProfileImage']))
                                                  : const AssetImage(
                                                          'assets/images/profilew.png')
                                                      as ImageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${request['workerFirstname']} ${request['workerLastname']}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    15, 99, 43, 1), // زيتي لون
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                SizedBox(width: 5),
                                                Text(
                                                  request[
                                                      'workerUsername'], // التقييم
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color.fromARGB(
                                                        255, 100, 96, 96),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  // ضع الوظيفة التي تريد تنفيذها عند الضغط على الأيقونة
                                  print('Delete icon pressed');
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red, // لون الأيقونة
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              SizedBox(width: 15),
                              // Text(
                              //   "تقييم العامل: ",
                              //   style: TextStyle(
                              //     fontSize: 18,
                              //     color: Colors.black,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              RatingBarIndicator(
                                rating: double.parse(request['workerRate']
                                    .toString()), // Ensure the rating is a double
                                //rating: 3.0,
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 25.0, // Size of the stars
                                direction: Axis.horizontal,
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.pin,
                                    color: Color.fromRGBO(15, 99, 43, 1),
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "اسم الأرض: ${request['landName']}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    color: Color.fromRGBO(15, 99, 43, 1),
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "عدد العمال المتبقي: ${request['numOfWorkers']}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.money_outlined,
                                    color: Color.fromRGBO(15, 99, 43, 1),
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "أجرة العامل بالساعة: ${request['workerWage']} شيكل",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Color.fromRGBO(15, 99, 43, 1),
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "الموقع: ${request['landLocation']}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: Color.fromRGBO(15, 99, 43, 1),
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "تاريخ الطلب: ${request['requestDate'].toString().substring(0, 10)}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),

                          SizedBox(height: 15),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    //fetchUser(request['workerUsername']);
                                    requestDecision(
                                        request['_id'],
                                        "accepted",
                                        request['landId'],
                                        request['workerUsername'],
                                        request['landName']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                        color: Color.fromRGBO(15, 99, 43, 1),
                                        width: 2),
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check,
                                          color: Color.fromRGBO(15, 99, 43, 1)),
                                      SizedBox(width: 5),
                                      Text(
                                        "قبول",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10), // مسافة بين الأزرار
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    requestDecision(
                                        request['_id'],
                                        "rejected",
                                        request['landId'],
                                        request['workerUsername'],
                                        request['landName']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side:
                                        BorderSide(color: Colors.red, width: 2),
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.close, color: Colors.red),
                                      SizedBox(width: 5),
                                      Text(
                                        "رفض",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
