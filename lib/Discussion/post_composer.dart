import 'dart:html' as html; // لتطبيق الويب
import 'dart:io'; // للأنظمة الأخرى
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:login_page/Discussion/Home.dart';
import 'dart:convert';

import 'package:login_page/screens/config.dart';

class PostComposer extends StatefulWidget {
  final String token;
  const PostComposer({required this.token, Key? key}) : super(key: key);

  @override
  _PostComposerState createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  final TextEditingController _postController = TextEditingController();
  Uint8List? _pickedImage; // لحفظ بيانات الصورة
  late String firstName;
  late String lastName;
  late String username;
  late String writerImage;

  @override
  void initState() {
    super.initState();

    // Decode the token using jwt_decoder and extract necessary fields
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    username = jwtDecoderToken['username'] ?? 'No First Name';
    firstName = jwtDecoderToken['firstName'] ?? 'No First Name';
    lastName = jwtDecoderToken['lastName'] ?? 'No Last Name';
    writerImage = jwtDecoderToken['profilePhoto'];
  }

  void registerPost() async {
    try {
      if (_postController.text.isNotEmpty) {
        String? encodedImage;
        if (_pickedImage != null) {
          encodedImage = base64Encode(_pickedImage!); // Use Uint8List directly
        }

        var reqBody = {
          'username': username,
          "firstName": firstName,
          "lastName": lastName,
          "writerImage": writerImage,
          "text": _postController.text,
          "image": encodedImage,
        };

        var response = await http.post(
          Uri.parse(puplishPost), // Backend URL
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(reqBody),
        );

        if (response.statusCode == 201) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status']) {
            print("Post added successfully");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeDiscussion(token: widget.token),
              ),
            );
          } else {
            print('Error: ${jsonResponse['message']}');
          }
        } else {
          print('Error: ${response.body}');
        }
      } else {
        print('Please fill all fields');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _pickedImage = result.files.single.bytes; // Use bytes directly
      });
    } else {
      print('No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      shadowColor: const Color.fromRGBO(15, 99, 43, 1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color.fromRGBO(15, 99, 43, 1).withOpacity(0.7),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 234, 244, 234).withOpacity(0.6),
              spreadRadius: 5,
              blurRadius: 15,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundImage: MemoryImage(base64Decode(writerImage)),
                    radius: 25,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      decoration: const InputDecoration(
                        hintText: "ماذا يدور في ذهنك؟",
                        border: InputBorder.none,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.image,
                        color: const Color.fromRGBO(15, 99, 43, 1)),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_pickedImage != null)
                Image.memory(
                  _pickedImage!, // Use Uint8List directly
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ElevatedButton(
                onPressed: registerPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text(
                  "نشر",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
