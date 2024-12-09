import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_page/Customers/CustomerDrawer2.dart';
import 'chat_screen.dart';
import 'dart:math'; // استيراد مكتبة العشوائية

class InboxScreen extends StatefulWidget {
  final String userId;
  final token;

  const InboxScreen({Key? key, required this.userId, this.token})
      : super(key: key);

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String searchQuery = '';
  Random _random = Random(); // لتعريف مولد الأرقام العشوائية

  // دالة لاختيار لون عشوائي من مجموعة ألوان
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

  // دالة لحساب الوقت المنقضي منذ آخر رسالة
  String _getTimeAgo(Timestamp timestamp) {
    DateTime messageTime = timestamp.toDate();
    Duration difference = DateTime.now().difference(messageTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم ';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة ';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة ';
    } else {
      return 'الآن';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'صندوق الرسائل',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.green),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.green),
              onPressed: () async {
                var result = await showSearch<String>(
                  context: context,
                  delegate: UserSearchDelegate(userId: widget.userId),
                );
                if (result != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        currentUserId: widget.userId,
                        otherUserId: result,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      endDrawer: CustomDrawer(token: widget.token),
      body: Directionality(
        textDirection: TextDirection.rtl,
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

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
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
                    isSeen = (chatData['seen'] as List).contains(widget.userId);
                  } else if (chatData['seen'] is bool) {
                    isSeen = chatData['seen'];
                  }
                }
                // الحصول على وقت الرسالة الأخيرة
                Timestamp lastMessageTime = chat['lastMessageTime'];

                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(otherUserId)
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (!userSnapshot.hasData) return const SizedBox.shrink();
                    var user = userSnapshot.data!;
                    var name = user['name'] ?? '';
                    var familyName = user['familyName'] ?? '';
                    var profileImage = user['profileImage'];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16), // زيادة الارتفاع بين العناصر
                      tileColor:
                          isSeen ? Colors.green.shade50 : Colors.grey.shade200,
                      leading: CircleAvatar(
                        radius: 26, // تكبير حجم الدائرة
                        backgroundColor:
                            _getRandomColor(), // تعيين اللون العشوائي
                        backgroundImage:
                            profileImage != null && profileImage.isNotEmpty
                                ? NetworkImage(profileImage)
                                : null,
                        child: profileImage == null || profileImage.isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0] : '?',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18), // زيادة حجم الحرف
                              )
                            : null,
                      ),
                      title: Text(
                        '$name $familyName',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15, // زيادة حجم النص
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
                                  fontSize: 14, // تكبير حجم الخط
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5), // مسافة بين الوقت والرسالة
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
                                      color:
                                          isSeen ? Colors.green : Colors.grey,
                                      size: 18, // حجم الأيقونة
                                    ),
                                  const SizedBox(
                                      width:
                                          5), // مسافة صغيرة بين الأيقونة والنص
                                  Text(
                                    lastMessage,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700], // تكبير الخط
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
        icon: const Icon(Icons.clear, color: Colors.green), // أخضر
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.green), // أخضر
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('لا يوجد نتائج.'));
        }

        var users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            var name = user['name'] ?? '';
            var familyName = user['familyName'] ?? '';
            var profileImage = user['profileImage'];
            var otherUserId = user.id;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: profileImage != null && profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : null,
                child: profileImage == null || profileImage.isEmpty
                    ? Text(name.isNotEmpty ? name[0] : '?')
                    : null,
              ),
              title: Text('$name $familyName', textAlign: TextAlign.right),
              subtitle: const Text('اضغط للبدء بالمحادثة',
                  textAlign: TextAlign.right),
              onTap: () {
                Navigator.pop(context, otherUserId);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
