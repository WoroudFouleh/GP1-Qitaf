import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CommentSection extends StatefulWidget {
  final List<Map<String, String>> comments;
  final Function(String, String) onAddComment;
  final Function(int) onDeleteComment;
  final Function(int, String) onEditComment;

  CommentSection({
    required this.comments,
    required this.onAddComment,
    required this.onDeleteComment,
    required this.onEditComment,
  });

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  XFile? _pickedImage;
  bool _isEditing = false;
  int _editingIndex = -1;

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

  void _addComment() {
    final text = _commentController.text;
    final image = _pickedImage?.path ?? '';

    if (text.isNotEmpty || image.isNotEmpty) {
      widget.onAddComment(text, image);
      _commentController.clear();
      setState(() {
        _pickedImage = null;
      });
    }
  }

  void _showEditCommentDialog(int index) {
    setState(() {
      _isEditing = true;
      _editingIndex = index;
      _commentController.text = widget.comments[index]['text']!;
    });
  }

  void _saveEditComment() {
    final updatedText = _commentController.text;
    if (updatedText.isNotEmpty) {
      widget.onEditComment(_editingIndex, updatedText);
      setState(() {
        _isEditing = false;
        _editingIndex = -1;
      });
    }
  }

  void _showDeleteConfirmationDialog(int index) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // التعليقات الحالية
        ...widget.comments
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
                        backgroundImage: AssetImage(comment['userImage']!),
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
                                  comment['userName']!,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textDirection: TextDirection.rtl,
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () {
                                    _showEditCommentDialog(index);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              comment['text']!,
                              style: TextStyle(fontWeight: FontWeight.w400),
                              textDirection: TextDirection.rtl,
                            ),
                            if (comment['image']!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Image.file(
                                  File(comment['image']!),
                                  height: 100,
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
        // إضافة تعليق جديد
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
              icon: Icon(Icons.image, color: Colors.green),
              onPressed: _pickImage,
            ),
          ],
        ),
      ],
    );
  }
}
