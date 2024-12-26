import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:login_page/screens/groupChat.dart';

class GroupInboxScreen extends StatefulWidget {
  final String userId;

  const GroupInboxScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _GroupInboxScreenState createState() => _GroupInboxScreenState();
}

class _GroupInboxScreenState extends State<GroupInboxScreen> {
  Random _random = Random();

  Color _getRandomColor() {
    List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.teal,
      Colors.cyan,
      Colors.pink,
      Colors.indigo
    ];
    return colors[_random.nextInt(colors.length)];
  }

  String _getTimeAgo(Timestamp timestamp) {
    DateTime messageTime = timestamp.toDate();
    Duration difference = DateTime.now().difference(messageTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/inboxx.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .where('members', arrayContains: widget.userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('لا توجد مجموعات.'));
              }

              var groups = snapshot.data!.docs;

              return ListView.separated(
                itemCount: groups.length,
                separatorBuilder: (context, index) => Divider(
                  thickness: 1,
                  color: Colors.grey[300],
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  var group = groups[index];
                  var groupId = group.id;
                  var groupName = group['name'] ?? 'Unnamed Group';
                  var members = List<String>.from(group['members'] ?? []);
                  var createdBy = group['createdBy'] ?? '';
                  var lastMessage = group['lastMessage'] ?? '';
                  var lastMessageSender = group['lastMessageSender'] ?? '';
                  var lastMessageTime = group['lastMessageTime'];

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(lastMessageSender)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) return const SizedBox.shrink();

                      var user = userSnapshot.data!;
                      var senderName = user['name'] ?? '';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        tileColor: Colors.grey.shade200,
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: _getRandomColor(),
                          child: Icon(Icons.group, color: Colors.white),
                        ),
                        title: Text(
                          groupName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .end, // تعديل هنا ليكون الزمن على اليسار
                              children: [
                                Text(
                                  _getTimeAgo(lastMessageTime),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  '$senderName: $lastMessage',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupChatScreen(
                                currentUserId: widget.userId,
                                groupId: groupId,
                                groupName: groupName,
                                members: members,
                                createdBy: createdBy,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}