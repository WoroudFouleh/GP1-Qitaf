import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:login_page/screens/createGroup.dart';
import 'chat_screen.dart';
import 'dart:math'; // مكتبة العشوائية

class InboxScreen extends StatefulWidget {
  final String userId;

  const InboxScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String searchQuery = '';
  Random _random = Random(); // لتوليد أرقام عشوائية

  // اختيار لون عشوائي من مجموعة ألوان
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

  // حساب الوقت المنقضي منذ الرسالة الأخيرة
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
              image:
                  AssetImage('assets/images/inboxx.png'), // تحديد صورة الخلفية
              fit: BoxFit.cover,
            ),
          ),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('participants', arrayContains: widget.userId)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('لا توجد محادثات.'));
              }

              return ListView.separated(
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (context, index) => Divider(
                  thickness: 1, // سمك الخط الفاصل
                  color: Colors.grey[300], // لون الخط
                  indent: 16, // مسافة من اليسار
                  endIndent: 16, // مسافة من اليمين
                ),
                itemBuilder: (context, index) {
                  var chat = snapshot.data!.docs[index];
                  var otherUserId = (chat['participants'] as List)
                      .firstWhere((id) => id != widget.userId);
                  var lastMessage = chat['lastMessage'] ?? '';
                  var isSeen = false;
                  var isMessageFromCurrentUser =
                      chat['lastMessageFromUser'] == widget.userId;

                  var chatData = chat.data() as Map<String, dynamic>;

                  if (chatData.containsKey('seen')) {
                    if (chatData['seen'] is List) {
                      isSeen =
                          (chatData['seen'] as List).contains(widget.userId);
                    } else if (chatData['seen'] is bool) {
                      isSeen = chatData['seen'];
                    }
                  }

                  Timestamp lastMessageTime = chat['lastMessageTime'];

                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                      if (!userSnapshot.hasData) return const SizedBox.shrink();
                      var user = userSnapshot.data!;
                      var name = user['name'] ?? '';
                      var familyName = user['familyName'] ?? '';
                      var profileImage = user['profileImage'];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        tileColor: isSeen
                            ? Colors.green.shade50
                            : Colors.grey.shade200,
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: _getRandomColor(),
                          backgroundImage:
                              profileImage != null && profileImage.isNotEmpty
                                  ? NetworkImage(profileImage)
                                  : null,
                          child: profileImage == null || profileImage.isEmpty
                              ? Text(
                                  name.isNotEmpty ? name[0] : '?',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                )
                              : null,
                        ),
                        title: Text(
                          '$name $familyName',
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 10),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (isMessageFromCurrentUser)
                                      Icon(
                                        isSeen
                                            ? Icons.check_circle
                                            : Icons.check_circle_outline,
                                        color: isSeen
                                            ? Color.fromARGB(255, 65, 139, 67)
                                            : Colors.grey,
                                        size: 18,
                                      ),
                                    const SizedBox(width: 5),
                                    Text(
                                      lastMessage,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () async {
                          if (otherUserId != widget.userId) {
                            await FirebaseFirestore.instance
                                .collection('chats')
                                .doc(chat.id)
                                .update({
                              'seen': FieldValue.arrayUnion([otherUserId]),
                            });
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                currentUserId: widget.userId,
                                otherUserId: otherUserId,
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

class UserSearchDelegate extends SearchDelegate<String> {
  final String userId;

  UserSearchDelegate({required this.userId});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear,
            color: Color.fromARGB(255, 65, 139, 67)), // أخضر
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back,
          color: Color.fromARGB(255, 65, 139, 67)), // أخضر
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد نتائج.',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            );
          }

          var results = snapshot.data!.docs;

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              var user = results[index];
              var name = user['name'];
              var familyName = user['familyName'];
              var otherUserId = user.id;

              return ListTile(
                title: Text(
                  '$name $familyName',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 21, 21, 21),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  close(context, otherUserId); // غلق البحث عند اختيار مستخدم
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/inboxx.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}