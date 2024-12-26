import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/Admin/admin_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/config.dart';

class Advertisements extends StatefulWidget {
  const Advertisements({super.key});

  @override
  State<Advertisements> createState() => _AdvertisementsState();
}

class _AdvertisementsState extends State<Advertisements> {
  List<dynamic> advertisements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdvertisements(); // Fetch ads when the widget initializes
  }

  Future<void> fetchAdvertisements() async {
    final response = await http.get(
      Uri.parse(getMainAds),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          advertisements = data['ads'];
          isLoading = false; // Update the lands list with the response data
        });
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

  Future<void> addAdvertisement(Uint8List imagePath) async {
    try {
      final response = await http.post(
        Uri.parse(addMainAd),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'image': imagePath != null ? base64Encode(imagePath!) : null,
        }),
      );

      if (response.statusCode == 201) {
        await fetchAdvertisements(); // Refresh the ads
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Advertisement added successfully")),
        );
      } else {
        print("Failed to add ad: ${response.statusCode}");
      }
    } catch (error) {
      print("Error adding ad: $error");
    }
  }

  Future<void> editAdvertisement(String id, Uint8List imagePath) async {
    try {
      final response = await http.put(
        Uri.parse(editMainAd),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'image': imagePath != null ? base64Encode(imagePath!) : null,
          "id": id
        }),
      );

      if (response.statusCode == 200) {
        await fetchAdvertisements(); // Refresh the ads
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Advertisement updated successfully")),
        );
      } else {
        print("Failed to update ad: ${response.statusCode}");
      }
    } catch (error) {
      print("Error updating ad: $error");
    }
  }

  Future<void> deleteAdvertisement(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$deleteMainAd/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await fetchAdvertisements(); // Refresh the ads
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Advertisement deleted successfully")),
        );
      } else {
        print("Failed to delete ad: ${response.statusCode}");
      }
    } catch (error) {
      print("Error deleting ad: $error");
    }
  }

  Future<void> _pickImage({String? id}) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Read the image as bytes
      Uint8List imageBytes = await pickedFile.readAsBytes();

      if (id != null) {
        // Editing an existing ad
        await editAdvertisement(id, imageBytes);
      } else {
        // Adding a new ad
        await addAdvertisement(imageBytes);
      }
    }
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this ad?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await deleteAdvertisement(id);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showFullImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain, // لتوسيع الصورة بما يتناسب مع حجم الشاشة
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF556B2F),
        title: const Text(
          'إعلانات الصفحة الرئيسية',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.right, // جعل العنوان من جهة اليمين
        ),
        actions: const [
          SizedBox(width: 10), // للمحاذاة من اليمين
        ],
        iconTheme: const IconThemeData(
            color: Colors.white), // تغيير لون السهم إلى الأبيض
      ),
      endDrawer: AdminDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : advertisements.isEmpty
              ? Column(
                  children: [
                    SizedBox(
                      height: 300,
                    ),
                    Center(
                      child: Text(
                        'No advertisements available.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                    SizedBox(
                      height: 320,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(),
                          icon: const Icon(Icons.add_a_photo,
                              color: Colors.white),
                          label: const Text('إضافة صورة',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF556B2F),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('تم حفظ التعديلات!')),
                            );
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('حفظ التعديلات',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF556B2F),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          itemCount: advertisements.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            final ad = advertisements[index];
                            // Check if the ad image exists and is a valid base64 string
                            String? imageBase64 = ad['image'];
                            if (imageBase64 != null && imageBase64.isNotEmpty) {
                              try {
                                // Try to decode the image base64 string
                                var imageBytes = base64Decode(imageBase64);
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          _showFullImage(context, ad['image']),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.green, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Image.memory(
                                          imageBytes,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () =>
                                            _pickImage(id: ad['_id']),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      left: 5,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _showDeleteConfirmation(ad['_id']),
                                      ),
                                    ),
                                  ],
                                );
                              } catch (e) {
                                print('Error decoding base64 image: $e');
                                return Center(
                                    child: Text('Invalid image data'));
                              }
                            } else {
                              return Center(child: Text('No image available'));
                            }
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(),
                            icon: const Icon(Icons.add_a_photo,
                                color: Colors.white),
                            label: const Text('إضافة صورة',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF556B2F),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('تم حفظ التعديلات!')),
                              );
                            },
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('حفظ التعديلات',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF556B2F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
