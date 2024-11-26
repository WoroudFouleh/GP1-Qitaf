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
  const QatafPage({required this.token, Key? key}) : super(key: key);

  @override
  State<QatafPage> createState() => _QatafPageState();
}

class _QatafPageState extends State<QatafPage> {
  List<dynamic> lands = [];
  late String username;
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
                    child: TextField(
                      textDirection: TextDirection.rtl, // تعيين اتجاه النص
                      textAlign: TextAlign.right, // محاذاة النص لليمين
                      decoration: InputDecoration(
                        hintText: 'البحث باستخدام اسم الثمار أو المدينة',
                        prefixIcon: const Icon(Icons.search,
                            color: Color.fromARGB(255, 12, 123, 17)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: const Offset(0.0, 10.0),
            blurRadius: 10.0,
            spreadRadius: -6.0,
          ),
        ],
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.35),
            BlendMode.multiply,
          ),
          image: MemoryImage(base64Decode(thumbnailUrl)),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 247, 246, 246)
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_city,
                        color: Colors.yellow,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        city,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 254, 254)
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.group,
                        color: Colors.yellow,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        workernum,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 254, 254)
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.apple,
                        color: Colors.yellow,
                        size: 16,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        crops,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
