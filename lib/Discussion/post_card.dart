import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:login_page/Discussion/Home.dart';
import 'comment_section.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/config.dart';

class PostCard extends StatefulWidget {
  final String token;
  final String postId;
  final String userName;
  final String userImage;
  final String postUsername;
  String postText;
  final String? postImage;
  final Map<String, dynamic> reactions; // For reactions
  final List<dynamic> comments; // For comments
  final String createdAt; // For creation date

  PostCard({
    required this.userName,
    required this.userImage,
    required this.postText,
    required this.postImage,
    required this.token,
    required this.postId,
    required this.reactions,
    required this.comments,
    required this.createdAt,
    required this.postUsername,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  //List<Map<String, String>> comments = [];
  Set<String> userReactions = {}; // نوع التفاعل الحالي للمستخدم
  late int likes;
  int loved = 0;
  late int interested;
  XFile? _pickedImage;
  TextEditingController _postTextController = TextEditingController();
  late String username;
  @override
  void initState() {
    super.initState();
    print(widget.postImage);
    likes = widget.reactions['like'];
    interested = widget.reactions['interested'];
    _postTextController.text = widget.postText; // تعبئة النص الحالي عند البداية
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No First Name';
  }

  void addNewReaction(String postId, String react, String operation) async {
    try {
      // Validate the input fields

      // Create request body
      var reqBody = {
        'postId': postId,
        "reactionType": react,
        "operation": operation,
      };

      var response = await http.post(
        Uri.parse(addReaction), // Ensure this URL matches your backend route
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          // showNotification('تم إضافة الأرض بنجاح');
          print("reaction added successfuly");
          // // _publishPost();
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => HomeDiscussion(token: widget.token),
          //   ),
          // );

          // Optionally clear fields or navigate away
        } else {
          print('حدث خطأ أثناء إضافة التعليق');
        }
      } else {
        var errorResponse = jsonDecode(response.body);
        print("here");
        print('حدث خطأ: ${errorResponse['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  void removePost() async {
    try {
      // Prepare the order details

      // Send the request to your backend API
      final response = await http.delete(
        Uri.parse('$deletePost/${widget.postId}'), // Replace with your API URL
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
            builder: (context) => HomeDiscussion(token: widget.token),
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

  void postUpdate(String text) async {
    try {
      Map<String, dynamic> requestBody = {
        'text': text,
      };

      // Convert the request body to JSON format
      String jsonBody = jsonEncode(requestBody);

      // Send the request to the backend
      var response = await http.put(
        Uri.parse(
            '$editPost/${widget.postId}'), // Replace with your backend URL
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

  void _toggleReaction(String type) {
    setState(() {
      if (userReactions.contains(type)) {
        // If the reaction is already active, remove it
        userReactions.remove(type);
        if (type == 'like') {
          likes--;
          addNewReaction(widget.postId, "like", "remove");
        }

        if (type == 'interested') {
          interested--;
          addNewReaction(widget.postId, "interested", "remove");
        }
      } else {
        // Add the new reaction
        userReactions.add(type);
        if (type == 'like') {
          likes++;
          addNewReaction(widget.postId, "like", "add");
        }
        if (type == 'interested') {
          interested++;
          addNewReaction(widget.postId, "interested", "add");
        }
      }
    });
  }

  // دالة لفتح نافذة اختيار الصورة
  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _pickImageFromGallery();
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        color: Color.fromRGBO(15, 99, 43, 1),
                        size: 35,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'من المعرض',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _pickImageFromCamera();
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera,
                        color: Color.fromRGBO(15, 99, 43, 1),
                        size: 35,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'من الكاميرا',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getElapsedTime(String createdAt) {
    DateTime postDate = DateTime.parse(createdAt);
    Duration difference = DateTime.now().difference(postDate);

    if (difference.inMinutes < 1) {
      return "الآن";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} دقيقة";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} ساعة";
    } else {
      return "${difference.inDays} يوم";
    }
  }

  _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
    Navigator.pop(context);
  }

  _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
    Navigator.pop(context);
  }

  // عرض خيارات تعديل أو حذف المنشور
  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('تعديل المنشور'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPostDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('حذف المنشور'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

// تعديل نافذة تعديل المنشور
  void _showEditPostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تعديل المنشور', textAlign: TextAlign.right),
          content: TextField(
            controller: _postTextController,
            maxLines: 5,
            textDirection: TextDirection.rtl, // الكتابة من اليمين لليسار
            decoration: InputDecoration(
              hintText: 'أدخل النص المعدل هنا',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 5),
                      Text('إلغاء', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      // تحديث النص
                      widget.postText = _postTextController.text;
                      postUpdate(_postTextController.text);
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.save, color: Color.fromRGBO(15, 99, 43, 1)),
                      SizedBox(width: 5),
                      Text('حفظ',
                          style:
                              TextStyle(color: Color.fromRGBO(15, 99, 43, 1))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

// تعديل نافذة حذف المنشور
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('هل أنت متأكد؟', textAlign: TextAlign.right),
          content:
              Text('هل ترغب في حذف هذا المنشور؟', textAlign: TextAlign.right),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 5),
                      Text('إلغاء', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // هنا يمكنك إضافة الكود لحذف المنشور
                    removePost();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 5),
                      Text('حذف', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color.fromRGBO(15, 99, 43, 1).withOpacity(0.7),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 243, 247, 243).withOpacity(0.7),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات المستخدم
            Row(
              textDirection: TextDirection.rtl,
              children: [
                CircleAvatar(
                  backgroundImage: MemoryImage(base64Decode(widget.userImage)),
                  radius: 25,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      getElapsedTime(widget.createdAt), // Display elapsed time
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Spacer(),
                if (widget.postUsername == username)
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: _showPostOptions,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(),
            // محتوى المنشور
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                widget.postText,
                style: TextStyle(fontSize: 16),
              ),
            ),
            // Check if there is a post image
            if (widget.postImage != null && widget.postImage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: SizedBox(
                  width: double.infinity, // Set the width to fill the parent
                  height: 200.0, // Specify the desired height for the image
                  child: Image.memory(
                    base64Decode(widget.postImage!),
                    fit: BoxFit
                        .cover, // Ensures the image covers the specified size
                  ),
                ),
              ),

            Divider(),

            // شريط التفاعلات الإجمالية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.comment, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text('${widget.comments.length}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Icon(Icons.thumb_up, color: Colors.green),
                    const SizedBox(width: 5),
                    Text('$likes',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Icon(Icons.star, color: Colors.yellow),
                    const SizedBox(width: 5),
                    Text('$interested',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),

            Divider(),

            // التفاعلات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _reactionButton('like', Icons.thumb_up, Colors.green, likes),
                _reactionButton(
                    'interested', Icons.star, Colors.amber, interested),
              ],
            ),
            Divider(),
            // قسم التعليقات
            CommentSection(
              postId: widget.postId,
              token: widget.token,
              comments: widget.comments,
              onAddComment: (String text, String image) {
                setState(() {
                  widget.comments.add({
                    'text': text,
                    'image': image,
                    'userName': 'محمد علي', // اسم صاحب التعليق (مؤقت)
                    'userImage':
                        'assets/images/profile.png', // صورة صاحب التعليق (مؤقت)
                  });
                });
              },
              onDeleteComment: (int index) {
                setState(() {
                  widget.comments.removeAt(index);
                });
              },
              onEditComment: (int index, String updatedText) {
                setState(() {
                  widget.comments[index]['text'] = updatedText;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _reactionButton(
      String type, IconData icon, Color activeColor, int count) {
    return GestureDetector(
      onTap: () => _toggleReaction(type),
      child: Row(
        children: [
          Icon(
            icon,
            color: userReactions.contains(type) ? activeColor : Colors.grey,
          ),
          const SizedBox(width: 5),
          Text(
            _getReactionLabel(type),
            style: TextStyle(
              color: userReactions.contains(type) ? activeColor : Colors.grey,
              fontWeight: userReactions.contains(type)
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getReactionLabel(String type) {
    switch (type) {
      case 'like':
        return 'إعجاب';
      case 'love':
        return 'أحببته';
      case 'interested':
        return 'مهتم';
      default:
        return '';
    }
  }
}
