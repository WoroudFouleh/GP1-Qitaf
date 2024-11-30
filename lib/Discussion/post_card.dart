import 'package:flutter/material.dart';
import 'comment_section.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PostCard extends StatefulWidget {
  final String userName;
  final String userImage;
  String postText;
  final String? postImage;

  PostCard({
    required this.userName,
    required this.userImage,
    required this.postText,
    this.postImage,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  List<Map<String, String>> comments = [];
  String userReaction = ''; // نوع التفاعل الحالي للمستخدم
  int likes = 0;
  int loved = 0;
  int interested = 0;
  XFile? _pickedImage;
  TextEditingController _postTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _postTextController.text = widget.postText; // تعبئة النص الحالي عند البداية
  }

  void _toggleReaction(String type) {
    setState(() {
      if (userReaction == type) {
        // إذا كان التفاعل الحالي هو نفسه، قم بإزالته
        if (type == 'like') likes--;
        if (type == 'love') loved--;
        if (type == 'interested') interested--;
        userReaction = '';
      } else {
        // إزالة التفاعل القديم (إن وجد)
        if (userReaction == 'like') likes--;
        if (userReaction == 'love') loved--;
        if (userReaction == 'interested') interested--;

        // إضافة التفاعل الجديد
        if (type == 'like') likes++;
        if (type == 'love') loved++;
        if (type == 'interested') interested++;
        userReaction = type;
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
                        color: Colors.green,
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
                        color: Colors.green,
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
                title: Text('تعديل البوست'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPostDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('حذف البوست'),
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
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.save, color: Colors.green),
                      SizedBox(width: 5),
                      Text('حفظ', style: TextStyle(color: Colors.green)),
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
                    Navigator.pop(context);
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
            color: const Color.fromARGB(255, 120, 181, 42).withOpacity(0.7),
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
                  backgroundImage: AssetImage(widget.userImage),
                  radius: 25,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
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
            if (widget.postImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(widget.postImage!),
              ),
            if (_pickedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Image.file(File(_pickedImage!.path)),
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
                    Text('${comments.length}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Icon(Icons.thumb_up, color: Colors.green),
                    const SizedBox(width: 5),
                    Text('$likes',
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
                _reactionButton('love', Icons.favorite, Colors.red, loved),
                _reactionButton(
                    'interested', Icons.star, Colors.amber, interested),
              ],
            ),
            Divider(),
            // قسم التعليقات
            CommentSection(
              comments: comments,
              onAddComment: (String text, String image) {
                setState(() {
                  comments.add({
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
                  comments.removeAt(index);
                });
              },
              onEditComment: (int index, String updatedText) {
                setState(() {
                  comments[index]['text'] = updatedText;
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
            color: userReaction == type ? activeColor : Colors.grey,
          ),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              color: userReaction == type ? activeColor : Colors.grey,
              fontWeight:
                  userReaction == type ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _getReactionLabel(type),
            style: TextStyle(
              color: userReaction == type ? activeColor : Colors.grey,
              fontWeight:
                  userReaction == type ? FontWeight.bold : FontWeight.normal,
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
