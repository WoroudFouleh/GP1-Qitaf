import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:login_page/Discussion/Home.dart';
import 'package:login_page/screens/config.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

class PostComposer extends StatefulWidget {
  final String token;
  const PostComposer({required this.token, Key? key}) : super(key: key);
  @override
  _PostComposerState createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  final TextEditingController _postController = TextEditingController();
  XFile? _pickedImage;
  late String firstName;
  late String lastName;
  late String username;
  late String writerImage;
  @override
  void initState() {
    super.initState();

    // Decode the token using jwt_decoder and extract necessary fields
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No First Name';
    firstName = jwtDecoderToken['firstName'] ?? 'No First Name';
    lastName = jwtDecoderToken['lastName'] ?? 'No Last Name';
    writerImage = jwtDecoderToken['profilePhoto'];
  }

  void registerPost() async {
    try {
      // Validate the input fields
      if (_postController.text.isNotEmpty) {
        String? encodedImage;
        if (_pickedImage != null) {
          final File imageFile = File(_pickedImage!.path);
          final List<int> imageBytes = await imageFile.readAsBytes();
          encodedImage = base64Encode(imageBytes);
        }
        // Create request body
        var reqBody = {
          'username': username,
          "firstName": firstName,
          "lastName": lastName,
          "writerImage": writerImage,
          "text": _postController.text,
          "image": encodedImage,
        };

        var response = await http.post(
          Uri.parse(puplishPost), // Ensure this URL matches your backend route
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(reqBody),
        );

        if (response.statusCode == 201) {
          var jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status']) {
            // showNotification('تم إضافة الأرض بنجاح');
            print("post added successfuly");
            // _publishPost();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeDiscussion(token: widget.token),
              ),
            );

            // Optionally clear fields or navigate away
          } else {
            print('حدث خطأ أثناء إضافة الأرض');
          }
        } else {
          var errorResponse = jsonDecode(response.body);
          print("here");
          print('حدث خطأ: ${errorResponse['message'] ?? response.statusCode}');
        }
      } else {
        print('يرجى ملء جميع الحقول');
      }
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('الكاميرا'),
                onTap: () async {
                  Navigator.pop(context);
                  final image =
                      await picker.pickImage(source: ImageSource.camera);
                  setState(() {
                    _pickedImage = image;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('المعرض'),
                onTap: () async {
                  Navigator.pop(context);
                  final image =
                      await picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    _pickedImage = image;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      shadowColor:
          const Color.fromARGB(255, 113, 149, 48), // اللون الأخضر للتوهج
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: const Color.fromARGB(255, 120, 181, 42).withOpacity(0.7),
              width: 2), // الحدود الخضراء
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 234, 244, 234)
                  .withOpacity(0.6), // اللون الأخضر المتوهج
              spreadRadius: 5,
              blurRadius: 15,
              offset: Offset(0, 3), // موضع التوهج
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // المحاذاة من اليمين
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
                      textDirection: TextDirection.rtl, // النص من اليمين لليسار
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.image, color: Colors.green[800]),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_pickedImage != null)
                Image.file(
                  File(_pickedImage!.path),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ElevatedButton(
                onPressed: registerPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  minimumSize: Size(double.infinity, 45), // عرض الزر بالكامل
                ),
                child: Text(
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
