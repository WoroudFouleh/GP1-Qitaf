import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class GroupChatScreen extends StatefulWidget {
  final String currentUserId;
  final String groupId;
  final String groupName;
  final List<String> members;
  final createdBy;

  const GroupChatScreen({
    Key? key,
    required this.currentUserId,
    required this.groupId,
    required this.groupName,
    required this.members,
    this.createdBy,
  }) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? selectedMessageId;

  // Function to generate a random color
  Color _generateRandomColor() {
    final Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  Future<void> _sendMessage(String content) async {
    if (content.isEmpty) return;

    // إرسال الرسالة إلى مجموعة الرسائل
    await FirebaseFirestore.instance
        .collection('groupMessages')
        .doc(widget.groupId)
        .collection('messages')
        .add({
      'content': content,
      'senderId': widget.currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // تحديث مجموعة الرسائل مع آخر رسالة
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .set({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSender': widget.currentUserId, // حفظ معرف المرسل
    }, SetOptions(merge: true));

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end, // تغيير لمحاذاة النص لليمين
          children: [
            Text(
              widget.groupName,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 8), // مسافة بين الاسم وأيقونة الصورة
            CircleAvatar(
              backgroundColor: _generateRandomColor(),
              child: Text(
                widget.groupName.isNotEmpty ? widget.groupName[0] : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.group, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupInfoScreen(
                    currentUserId: widget.currentUserId,
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                    members: widget.members,
                    creatorId: widget.createdBy, // استبدل بـ ID منشئ المجموعة
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/mm2.png',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('groupMessages')
                        .doc(widget.groupId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('لا توجد رسائل بعد.'));
                      }
                      var messages = snapshot.data!.docs;
                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          var message = messages[index];
                          bool isSender =
                              message['senderId'] == widget.currentUserId;
                          return Column(
                            crossAxisAlignment: isSender
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(message['senderId'])
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox();
                                  }
                                  var senderData = snapshot.data;
                                  var senderName =
                                      '${senderData?['name']} ${senderData?['familyName']}';
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      senderName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSender
                                      ? const Color.fromRGBO(15, 99, 43, 1)
                                      : const Color.fromARGB(
                                          255, 246, 255, 226),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(15),
                                    topRight: const Radius.circular(15),
                                    bottomLeft: isSender
                                        ? const Radius.circular(15)
                                        : const Radius.circular(0),
                                    bottomRight: isSender
                                        ? const Radius.circular(0)
                                        : const Radius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  message['content'],
                                  style: TextStyle(
                                    color:
                                        isSender ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالة...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send,
                            color: const Color.fromRGBO(15, 99, 43, 1)),
                        onPressed: () =>
                            _sendMessage(_messageController.text.trim()),
                      ),
                    ],
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

class GroupInfoScreen extends StatelessWidget {
  final String currentUserId;
  final String groupId;
  final String groupName;
  final List<String> members;
  final String creatorId; // ID of the group creator

  const GroupInfoScreen({
    Key? key,
    required this.currentUserId,
    required this.groupId,
    required this.groupName,
    required this.members,
    required this.creatorId,
  }) : super(key: key);

  // Function to delete all messages in the group
  Future<void> _deleteMessages(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('groupMessages')
        .doc(groupId)
        .collection('messages')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف جميع الرسائل')),
    );
  }

  // Function to delete the group
  Future<void> _deleteGroup(BuildContext context) async {
    await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
    await FirebaseFirestore.instance
        .collection('groupMessages')
        .doc(groupId)
        .delete();

    Navigator.of(context).pop(); // Return to previous screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف المجموعة بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the creator is included in the members list
    List<String> updatedMembers = [...members];
    if (!updatedMembers.contains(creatorId)) {
      updatedMembers.add(creatorId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            groupName,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.right,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: updatedMembers)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا يوجد أعضاء.'));
          }

          var memberDocs = snapshot.data!.docs;

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    ' :أعضاء المجموعة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: memberDocs.length,
                  itemBuilder: (context, index) {
                    var member = memberDocs[index];
                    var memberId = member.id;
                    var name = member['name'];
                    var familyName = member['familyName'];
                    bool isCurrentUser = memberId == currentUserId;
                    bool isCreator = memberId == creatorId;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          name.isNotEmpty ? name[0] : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
                      ),
                      title: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          isCurrentUser
                              ? '$name $familyName (أنت)'
                              : isCreator
                                  ? '$name $familyName (المسؤول)'
                                  : '$name $familyName',
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _deleteMessages(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'حذف المحادثة',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _deleteGroup(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'حذف المجموعة',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
