import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding
import 'package:login_page/screens/config.dart';

class DealWidget extends StatefulWidget {
  const DealWidget({Key? key}) : super(key: key);

  @override
  State<DealWidget> createState() => _DealWidgetState();
}

class _DealWidgetState extends State<DealWidget> {
  List<dynamic> advertisements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdvertisements(); // Fetch ads when the widget initializes
  }

  Future<void> fetchAdvertisements() async {
    try {
      final response = await http.get(
        Uri.parse(getProductAds),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            advertisements = data['ads'];
            isLoading = false;
          });
        } else {
          print('Error fetching advertisements: ${data['message']}');
        }
      } else {
        print('Failed to fetch advertisements: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : advertisements.isEmpty
            ? const Center(
                child: Text(
                  'لا توجد إعلانات متاحة حالياً.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: advertisements.map((ad) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD1E7D6)
                                  .withOpacity(0.5), // Light olive green glow
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(0, 3), // Position of shadow
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              15), // Ensure image corners match the container
                          child: ad['image'] != null
                              ? FutureBuilder<Widget>(
                                  future: _loadImage(ad['image']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Image.asset(
                                        'assets/images/placeholder.jpg',
                                        height: 220,
                                        width: 300,
                                        fit: BoxFit.cover,
                                      );
                                    } else {
                                      return snapshot.data!;
                                    }
                                  },
                                )
                              : Image.asset(
                                  'assets/images/placeholder.jpg',
                                  height: 220,
                                  width: 300,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
  }

  Future<Widget> _loadImage(String base64String) async {
    try {
      final imageBytes = base64Decode(base64String);
      return Image.memory(
        imageBytes,
        height: 220,
        width: 300,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Image.asset(
        'assets/images/placeholder.jpg',
        height: 220,
        width: 300,
        fit: BoxFit.cover,
      );
    }
  }
}
