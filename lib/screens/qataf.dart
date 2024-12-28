import 'package:flutter/material.dart';
import 'package:login_page/screens/custom_drawer.dart';
import 'package:login_page/widgets/DealWidget.dart';
import 'package:login_page/screens/LandPage.dart'; // تأكد من إضافة LandPage هنا
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class QatafPage extends StatefulWidget {
  final String token;
  final String userId;
  const QatafPage({required this.token, Key? key, required this.userId})
      : super(key: key);

  @override
  State<QatafPage> createState() => _QatafPageState();
}

class _QatafPageState extends State<QatafPage> {
  List<dynamic> lands = [];
  late String username;
  String searchQuery = '';
  String searchCategory = 'crop'; // Default category is 'crop'
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No username';

    fetchLands(); // Call the fetch function when the page is loaded
  }

  void fetchLands() async {
    final response = await http.get(
      Uri.parse('$getLands/$username'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          lands = data['lands']; // Update the lands list with the response data
        });
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

  void searchLands() async {
    final response = await http.get(
      Uri.parse(
          '$getLands/$username?search=$searchQuery&category=$searchCategory'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          lands = data['lands']; // Update the lands list with the search result
        });
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تعيين اتجاه النص من اليمين إلى اليسار
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 12, 123, 17),
          ),
          titleTextStyle: const TextStyle(
              color: Color.fromARGB(255, 11, 130, 27),
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'CustomArabicFont'),
          elevation: 0,
          title: const Align(
            alignment: Alignment.centerRight,
            child: Text(
              ' الأراضي الزراعية ',
              textAlign: TextAlign.right,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.center, // لجعل شريط البحث في المنتصف
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: searchCategory,
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 12, 123, 17)),
                          underline: Container(
                            height: 2,
                            color: Color.fromARGB(255, 12, 123, 17),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              searchCategory = newValue!;
                              searchQuery =
                                  ''; // Clear the previous query when changing category
                            });
                          },
                          items: <String>['name', 'crop', 'location']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value == 'name'
                                    ? 'الاسم'
                                    : value == 'crop'
                                        ? 'المحصول  '
                                        : 'الموقع',
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            width: 400, // Adjust the width as needed
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255,
                                  255), // Background color of the TextField
                              borderRadius:
                                  BorderRadius.circular(8.0), // Rounded corners
                            ),
                            child: TextField(
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              onChanged: (text) {
                                setState(() {
                                  searchQuery = text;
                                });
                              },
                              onSubmitted: (text) {
                                setState(() {
                                  searchQuery =
                                      text; // Update the search query with the entered text
                                });
                                searchLands(); // Trigger the search function
                              },
                              decoration: InputDecoration(
                                hintText: searchCategory == 'name'
                                    ? 'ابحث عن الاسم'
                                    : searchCategory == 'crop'
                                        ? 'ابحث حسب المحصول '
                                        : 'ابحث عن الموقع',
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color.fromARGB(255, 12, 123, 17),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(right: 10, bottom: 10),
                child: const Text(
                  "الأراضي الزراعية المتاحة للقطف",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF556B2F),
                    shadows: [
                      Shadow(
                        color: Color(0xFFD1E7D6),
                        blurRadius: 10.0,
                        offset: Offset(0, 5),
                      ),
                      Shadow(
                        color: Color(0xFFF5F5DC),
                        blurRadius: 5.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Build RecipeCard for each land dynamically
              ...lands.map((land) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to LandPage and pass the land info
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LandPage(
                          userId: widget.userId,
                          token: widget.token,
                          landName: land['landName'],
                          image: land['image'],
                          username: land['username'],
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
                          coordinates: land['coordinates'] != null
                              ? {
                                  'lat': land['coordinates']['lat'],
                                  'lng': land['coordinates']['lng']
                                }
                              : {
                                  'lat': 0.0,
                                  'lng': 0.0
                                }, // يمكنك وضع قيم افتراضية مثل 0.0 في حال كانت null
                        ),
                      ),
                    );
                  },
                  child: RecipeCard(
                      title: land[
                          'landName'], // Assuming landName is the field in the response
                      workernum: "${land['numOfWorkers']} عمّال",
                      crops: land['cropType'],
                      city: land['city'],
                      thumbnailUrl:
                          land['image'] ?? '' // Assuming image URL is available
                      ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String title;
  final String city;
  final String workernum;
  final String crops;
  final String thumbnailUrl;

  const RecipeCard({
    super.key,
    required this.title,
    required this.workernum,
    required this.city,
    required this.crops,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      // لضمان تمركز الـ Container في وسط الصفحة
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 30, vertical: 20), // تعديل المارجين لتناسب شاشات الويب
        width: MediaQuery.of(context).size.width *
            0.9, // جعل العرض 90% من عرض الشاشة لظهور العناصر بشكل جيد
        height: MediaQuery.of(context).size.height *
            0.4, // زيادة الارتفاع بنسبة 40% من ارتفاع الشاشة لتظهر الصورة بشكل أكبر
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(
              20), // زيادة نصف القطر لجعل الحواف أكثر استدارة
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(0.0, 15.0), // تعديل الإزاحة لتناسب الويب
              blurRadius: 15.0, // زيادة التمويه للظل
              spreadRadius: -8.0,
            ),
          ],
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black
                  .withOpacity(0.5), // تقليل الشفافية لتكون الصورة أكثر وضوحًا
              BlendMode.multiply,
            ),
            image: MemoryImage(
                base64Decode(thumbnailUrl)), // إذا كانت الصورة بتنسيق base64
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24, // زيادة حجم النص
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2, // تحديد الحد الأقصى لعدد الأسطر
                  textAlign: TextAlign.center, // محاذاة النص في المنتصف
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft, // محاذاة العنصر إلى أقصى اليسار
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0), // إضافة بعض الهوامش من الأسفل
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // محاذاة العناصر في اليسار
                  children: [
                    _buildInfoContainer(
                        Icons.location_city, city, 22), // العنصر في أقصى اليسار
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter, // محاذاة العنصر في المنتصف
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // محاذاة العناصر في المنتصف
                  children: [
                    _buildInfoContainer(
                        Icons.access_time, workernum, 22), // العنصر في المنتصف
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight, // محاذاة العنصر إلى أقصى اليمين
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // محاذاة العناصر في اليمين
                  children: [
                    _buildInfoContainer(
                        Icons.apple, crops, 20), // العنصر في أقصى اليمين
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// دالة مساعدة لبناء العناصر المكررة
  Widget _buildInfoContainer(IconData icon, String text, double iconSize) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 246, 246).withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.yellow,
            size: iconSize, // تحديد حجم الأيقونة
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18, // حجم النص
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
