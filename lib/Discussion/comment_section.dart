import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:login_page/Discussion/Home.dart';
import 'package:login_page/screens/config.dart';
import 'dart:convert';

class CommentSection extends StatefulWidget {
  final String token;
  final String postId;
  final List<dynamic> comments;
  final Function(String, String) onAddComment;
  final Function(int) onDeleteComment;
  final Function(int, String) onEditComment;

  CommentSection({
    required this.comments,
    required this.onAddComment,
    required this.onDeleteComment,
    required this.onEditComment,
    required this.token,
    required this.postId,
  });

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  XFile? _pickedImage;
  bool _isEditing = false;
  int _editingIndex = -1;
  late String firstName;
  late String lastName;
  late String username;
  late String writerImage;
  late String comentId;
  bool _showAllComments = false;
  bool likePressed = false;
  late int likes;
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

  void addNewComment(String postId, String text) async {
    try {
      // Validate the input fields
      String? encodedImage;
      if (_pickedImage != null) {
        final File imageFile = File(_pickedImage!.path);
        final List<int> imageBytes = await imageFile.readAsBytes();
        encodedImage = base64Encode(imageBytes);
      }
      // Create request body
      var reqBody = {
        'postId': postId,
        "text": text,
        "username": username,
        "userFirstName": firstName,
        "userLastName": lastName,
        "userImage": writerImage,
        "commentImage": encodedImage,
      };

      var response = await http.post(
        Uri.parse(addComment), // Ensure this URL matches your backend route
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          // showNotification('تم إضافة الأرض بنجاح');
          print("comment added successfuly");
          // _publishPost();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeDiscussion(token: widget.token),
            ),
          );

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

  void updateCommentLikes(
      String postId, String commentId, String operation) async {
    try {
      // Validate the input fields
      print(operation);
      // Create request body
      var reqBody = {
        'postId': postId,
        "commentId": commentId,
        "operation": operation,
      };

      var response = await http.post(
        Uri.parse(commentLikes), // Ensure this URL matches your backend route
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          // showNotification('تم إضافة الأرض بنجاح');
          print("comment liked successfuly");
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

  void removeComment(String commentId) async {
    try {
      // Prepare the order details

      // Send the request to your backend API
      final response = await http.delete(
        Uri.parse(
            '$deleteComment/${widget.postId}/comment/${commentId}'), // Replace with your API URL
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حذف التعليق بنجاح")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeDiscussion(token: widget.token),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("حدث خطأ أثناء حذف التعليق")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الاتصال بالخادم")),
      );
    }
  }

  void commentUpdate(String commentId, String text) async {
    try {
      Map<String, dynamic> requestBody = {
        'text': text,
      };

      // Convert the request body to JSON format
      String jsonBody = jsonEncode(requestBody);

      // Send the request to the backend
      var response = await http.put(
        Uri.parse(
            '$editComment/${widget.postId}/comment/${commentId}'), // Replace with your backend URL
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

  Future<void> _pickImage() async {
    // Use FilePicker to pick an image file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Limit to image files
    );

    if (result != null) {
      // Get the picked file
      PlatformFile file = result.files.first;

      // Set the picked image
      setState(() {
        _pickedImage = XFile(file.path!);
      });
    }
  }

  void _addComment() {
    final text = _commentController.text;
    final image = _pickedImage?.path ?? '';
    addNewComment(widget.postId, text);

    if (text.isNotEmpty || image.isNotEmpty) {
      widget.comments.add({
        'text': text,
        'userFirstName': firstName,
        'userLastName': lastName,
        'userImage': writerImage,
        'commentImage': _pickedImage != null
            ? base64Encode(File(_pickedImage!.path).readAsBytesSync())
            : null,
      });
      _commentController.clear();
      setState(() {
        _pickedImage = null;
      });
    }
  }

  void _showCommentOptionsDialog(int index, String commentId) {
    print(index);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('تعديل التعليق'),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  _showEditCommentDialog(index, commentId); // Open edit dialog
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('حذف التعليق'),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  _showDeleteConfirmationDialog(
                      index, commentId); // Open delete confirmation
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditCommentDialog(int index, String commentId) {
    setState(() {
      _isEditing = true;
      _editingIndex = index;
      _commentController.text = widget.comments[index]['text']!;
      comentId = commentId;
    });
  }

  void _saveEditComment() {
    final updatedText = _commentController.text;
    if (updatedText.isNotEmpty) {
      widget.onEditComment(_editingIndex, updatedText);
      setState(() {
        commentUpdate(comentId, _commentController.text);
        _isEditing = false;
        _editingIndex = -1;
        _commentController.text = "";
      });
    }
  }

  void _showDeleteConfirmationDialog(int index, String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('هل أنت متأكد؟'),
          content: Text('هل ترغب في حذف هذا التعليق؟'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog without deleting
                  },
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.black),
                      SizedBox(width: 5),
                      Text('إلغاء'),
                    ],
                  ),
                ),
                SizedBox(width: 20), // Adding space between buttons
                TextButton(
                  onPressed: () {
                    removeComment(commentId);
                    Navigator.pop(context); // Close the dialog
                    widget.onDeleteComment(index); // Delete the comment
                  },
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 5),
                      Text('حذف'),
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

  bool _isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Limit the comments to show based on `_showAllComments`
    final commentsToShow =
        _showAllComments ? widget.comments : widget.comments.take(3).toList();

    return Column(
      children: [
        // Current comments
        ...commentsToShow
            .asMap()
            .map(
              (index, comment) => MapEntry(
                index,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: comment['userImage'] != null &&
                                _isBase64(comment['userImage'])
                            ? MemoryImage(base64Decode(comment['userImage']))
                            : AssetImage('assets/images/profile.png')
                                as ImageProvider,
                        radius: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Text(
                                  '${comment['userFirstName']} ${comment['userLastName']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textDirection: TextDirection.rtl,
                                ),
                                IconButton(
                                  icon: Icon(
                                    (comment['likePressed'] ?? false)
                                        ? Icons.favorite
                                        : Icons.favorite_border_outlined,
                                    color: (comment['likePressed'] ?? false)
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      comment['likePressed'] =
                                          !(comment['likePressed'] ?? false);

                                      // Update likes count locally
                                      if (comment['likePressed']) {
                                        comment['commentlikes'] =
                                            (comment['commentlikes'] ?? 0) + 1;
                                        updateCommentLikes(widget.postId,
                                            comment['_id'], "add");
                                      } else {
                                        comment['commentlikes'] =
                                            (comment['commentlikes'] ?? 0) - 1;
                                        updateCommentLikes(widget.postId,
                                            comment['_id'], "remove");
                                      }
                                    });
                                  },
                                ),
                                Text('${comment['commentlikes']}',
                                    style: TextStyle(fontSize: 14)),
                                Spacer(),
                                if (comment['user'] == username)
                                  IconButton(
                                    icon: Icon(Icons.more_vert),
                                    onPressed: () {
                                      _showCommentOptionsDialog(
                                          index, comment['_id']);
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    comment['text']!,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w400),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  if (comment['commentImage'] != null &&
                                      comment['commentImage']!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Image.memory(
                                        base64Decode(comment['commentImage']!),
                                        height: 100,
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
                ),
              ),
            )
            .values
            .toList(),

        // "View More" or "View Less" button
        if (widget.comments.length > 3)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllComments = !_showAllComments;
              });
            },
            child: Text(
              _showAllComments ? 'عرض أقل' : 'عرض المزيد',
              style: TextStyle(color: Colors.blue),
            ),
          ),

        // Add a new comment section
        Row(
          textDirection: TextDirection.rtl,
          children: [
            IconButton(
              icon: Icon(Icons.send, color: Colors.blue),
              onPressed: _isEditing ? _saveEditComment : _addComment,
            ),
            Expanded(
              child: TextField(
                controller: _commentController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: _isEditing ? "تعديل التعليق..." : "أضف تعليق",
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.image,
                color: const Color.fromRGBO(15, 99, 43, 1),
              ),
              onPressed: _pickImage,
            ),
          ],
        ),
      ],
    );
  }

  // bool _isBase64(String str) {
  //   try {
  //     base64Decode(str);
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }
}
