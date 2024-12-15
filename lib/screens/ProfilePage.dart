import 'package:flutter/material.dart';
import 'package:login_page/screens/config.dart';
import 'package:login_page/screens/editLand.dart';
import 'package:login_page/screens/editProduct.dart';
import 'package:login_page/screens/editProductionLine.dart';
import 'package:login_page/screens/owner_profile.dart';
import 'dart:convert'; // For base64 decoding
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:login_page/screens/welcome_screen.dart';

class ProfilePage extends StatefulWidget {
  final token;
  final userId;
  const ProfilePage({required this.token, Key? key, this.userId})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String firstName;
  late String lastName;
  late String email;
  late String username;
  String? profilePhotoBase64;
  List<dynamic> products = [];
  List<dynamic> lands = [];
  List<dynamic> lines = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    firstName = jwtDecoderToken['firstName'] ?? 'No First Name';
    lastName = jwtDecoderToken['lastName'] ?? 'No Last Name';
    email = jwtDecoderToken['email'] ?? 'No Email';
    profilePhotoBase64 = jwtDecoderToken['profilePhoto'];
    username = jwtDecoderToken['username'];
    fetchLands();
    fetchLines();
    fetchProducts();
    // تعديل طول TabController إلى 1
  }

  void fetchProducts() async {
    if (username == null) {
      print("Username not available from token.");
      return;
    }
    print("Sending username: $username");

    try {
      final response = await http.get(
        Uri.parse(
            '$getOwnerProducts/$username'), // Send the URL without the username
        headers: {'Content-Type': 'application/json'},
        // Send the username in the body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            products = data['products'];
          });
          print("Fetched cart items: $products");
        } else {
          print("Error fetching items: ${data['message']}");
        }
      } else {
        print("Failed to load items: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void fetchLands() async {
    if (username == null) {
      print("Username not available from token.");
      return;
    }
    print("Sending username: $username");

    try {
      final response = await http.get(
        Uri.parse(
            '$getOwnerLands/$username'), // Send the URL without the username
        headers: {'Content-Type': 'application/json'},
        // Send the username in the body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            lands = data['lands'];
          });
          print("Fetched cart items: $lands");
        } else {
          print("Error fetching items: ${data['message']}");
        }
      } else {
        print("Failed to load items: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  void fetchLines() async {
    if (username == null) {
      print("Username not available from token.");
      return;
    }
    print("Sending username: $username");

    try {
      final response = await http.get(
        Uri.parse(
            '$getOwnerLines/$username'), // Send the URL without the username
        headers: {'Content-Type': 'application/json'},
        // Send the username in the body
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            lines = data['lines'];
          });
          print("Fetched cart items: $lines");
        } else {
          print("Error fetching items: ${data['message']}");
        }
      } else {
        print("Failed to load items: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.green),
          title: const Text(
            'الملف الشخصي',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "edit") {
                  Navigator.pushReplacementNamed(context, '/OwnerProfile');
                } else if (value == "logout") {
                  _showLogoutConfirmationDialog(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "edit",
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OwnerProfile(
                                  token: widget.token,
                                  userId: widget.userId,
                                )),
                      );
                    },
                    child: const Text(
                      "تعديل الملف الشخصي",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // جعل الخط باللون الأسود
                      ),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: "logout",
                  child: Text(
                    "تسجيل الخروج",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // جعل الخط باللون الأسود
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            ClipOval(
              child: profilePhotoBase64 != null
                  ? Image.memory(
                      base64Decode(profilePhotoBase64!),
                      fit: BoxFit.cover,
                      width: 120.0,
                      height: 120.0,
                    )
                  : Image.asset('assets/images/profile.png'),
            ),
            const SizedBox(height: 10),
            Text(
              '$firstName${lastName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              username,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              labelColor: Colors.green,
              unselectedLabelColor: const Color.fromARGB(255, 35, 35, 35),
              indicatorColor: Colors.green,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'CustomArabicFont',
              ), // جعل العناوين بولد
              tabs: const [
                Tab(icon: Icon(Icons.post_add), text: "منشوراتي"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyPostsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPostsTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Color.fromARGB(255, 30, 29, 29),
            indicatorColor: Colors.green,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'CustomArabicFont',
            ), // جعل العناوين بولد
            tabs: [
              Tab(text: "أراضي"),
              Tab(text: "منتجات"),
              Tab(text: "خط إنتاج"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildLandsList(),
                _buildProductsList(),
                _buildProductionLineList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandsList() {
    return GridView.builder(
      itemCount: lands.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final land = lands[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditLand(
                  token: widget.token,
                  landName: land['landName'],
                  image: land['image'],
                  ownerusername: land['username'],
                  cropType: land['cropType'],
                  workerWages: land['workerWages'],
                  landSpace: land['landSpace'],
                  numOfWorkers: land['numOfWorkers'],
                  city: land['city'],
                  location: land['location'],
                  startDate: land['startDate'],
                  endDate: land['endDate'],
                  startTime: land['startTime'],
                  endTime: land['endTime'],
                  landId: land['_id'],
                ), // Pass data if needed
              ),
            );
          },
          child: RecipeCard(
            title: land['landName'],
            thumbnailUrl: land['image'] ?? '',
            publishDate: land['publishingDate'] ?? '7-10-2024',
          ),
        );
      },
    );
  }

  Widget _buildProductsList() {
    return GridView.builder(
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            // الانتقال إلى صفحة EditProduct عند الضغط على العنصر
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProduct(
                  productName: product['name'],
                  productDescription: product['description'],
                  productPrice: product['price'],
                  profilePhotoBase64:
                      product['image'], // Assuming image is base64
                  quantityType: product['quantityType'],
                  quantityAvailable: product['quantity'],
                  token: widget.token,
                  productId: product['_id'],

                  preparationTime: product['preparationTime'],
                  preparationUnit: product['preparationTimeUnit'],
                  city: product['city'],
                  location: product['location'],
                  productType: product['type'],
                ), // Pass data if needed
              ),
            );
          },
          child: RecipeCard(
            title: product['name']!,
            thumbnailUrl: product['image'] ?? '',
            publishDate:
                product['publishingDate'] ?? '7-20-2024', // تمرير تاريخ النشر
          ),
        );
      },
    );
  }

  Widget _buildProductionLineList() {
    return GridView.builder(
      itemCount: lines.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final line = lines[index];
        return GestureDetector(
          onTap: () {
            // الانتقال إلى صفحة EditProductionLine عند الضغط على العنصر
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductionLine(
                  phoneNum: line['phoneNumber'],
                  price: line['price'],
                  quantityUnit: line['quantityUnit'],
                  token: widget.token,
                  lineName: line['lineName'],
                  image: line['image'],
                  cropType: line['materialType'],
                  lineId: line['_id'],
                  description: line['description'],
                  preparationTime: line['timeOfPreparation'],
                  city: line['city'],
                  location: line['location'],
                  days: List<String>.from(line['datesOfWork']),
                  preparationUnit: line['unitTimeOfPreparation'],
                  startTime: line['startWorkTime'],
                  endTime: line['endWorkTime'],
                ), // Pass data if needed
              ),
            );
          },
          child: RecipeCard(
            title: line['lineName']!,
            thumbnailUrl: line['image'] ?? '',
            publishDate:
                line['publishingDate'] ?? '7-10-2024', // تمرير تاريخ النشر
          ),
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl, // الكتابة من اليمين إلى اليسار
          child: AlertDialog(
            title: const Text(
              "تأكيد تسجيل الخروج",
              style: TextStyle(
                fontWeight: FontWeight.bold, // خط بولد
                color: Colors.black, // لون النص أسود
              ),
            ),
            content: const Text(
              "هل أنت متأكد أنك تريد تسجيل الخروج؟",
              style: TextStyle(
                fontWeight: FontWeight.bold, // خط بولد
                color: Colors.black, // لون النص أسود
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  ); // إغلاق النافذة
                  // إضافة منطق تسجيل الخروج هنا
                },
                icon: const Icon(
                  Icons.exit_to_app, // أيقونة تسجيل الخروج
                  color: Color.fromARGB(255, 255, 0, 0), // لون الأيقونة أسود
                ),
                label: const Text(
                  "موافق",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // خط بولد
                    color: Colors.black, // لون النص أسود
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // إغلاق النافذة
                },
                child: const Text(
                  "إلغاء",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // خط بولد
                    color: Color.fromARGB(255, 0, 0, 0), // لون النص رمادي
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String title;
  final String thumbnailUrl;
  final String publishDate; // إضافة الحقل الجديد

  const RecipeCard({
    required this.title,
    required this.thumbnailUrl,
    required this.publishDate, // تمرير الحقل الجديد
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.memory(
              base64Decode(thumbnailUrl),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  "تاريخ النشر: ${publishDate.toString().substring(0, 10)}",
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
