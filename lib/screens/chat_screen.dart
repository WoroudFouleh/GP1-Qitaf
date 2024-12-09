import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // Import the math library for random number generation

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? messageTime;
  String? selectedMessageId;

  // Function to generate a random color
  Color _generateRandomColor() {
    final Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // Random red value
      random.nextInt(256), // Random green value
      random.nextInt(256), // Random blue value
      1, // Full opacity
    );
  }

  @override
  Widget build(BuildContext context) {
    String chatId = widget.currentUserId.compareTo(widget.otherUserId) < 0
        ? '${widget.currentUserId}_${widget.otherUserId}'
        : '${widget.otherUserId}_${widget.currentUserId}';

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.otherUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('...');
            }

            var userData = snapshot.data;
            String firstName = userData?['name'] ?? 'غير معروف';
            String lastName = userData?['familyName'] ?? '';
            String fullName = '$firstName $lastName';

            return Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align to right
              children: [
                const SizedBox(width: 10),
                Text(
                  fullName,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  child: Text(
                    firstName.isNotEmpty ? firstName[0] : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor:
                      _generateRandomColor(), // Random color for each user
                ),
              ],
            );
          },
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert,
                color: Colors.white), // Replaced arrow with three dots
            onPressed: () {
              // Add any action for the 3 dots here if needed
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(chatId)
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
                      bool isLastMessage =
                          index == 0; // Check if it's the last message

                      String messageStatus = 'تم الإرسال'; // Default status
                      if (isSender && message['seen'] == true) {
                        messageStatus = 'تم القراءة';
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            // Toggle time display for the message
                            if (selectedMessageId == message.id) {
                              messageTime = null; // Hide time if tapped again
                              selectedMessageId = null;
                            } else {
                              messageTime = message['timestamp'] != null
                                  ? (message['timestamp'] as Timestamp)
                                      .toDate()
                                      .toString()
                                  : 'غير متوفر';
                              selectedMessageId = message.id;
                            }
                          });
                        },
                        child: Column(
                          crossAxisAlignment: isSender
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            // فقاعة الرسالة
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSender ? Colors.green : Colors.white,
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
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                message['content'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSender ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            if (messageTime != null &&
                                selectedMessageId == message.id)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 10),
                                child: Text(
                                  messageTime!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            // Display message status for last message
                            if (isLastMessage && isSender)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 10),
                                child: Text(
                                  messageStatus,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
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
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () async {
                      String message = _messageController.text.trim();
                      if (message.isEmpty) return;

                      await FirebaseFirestore.instance
                          .collection('messages')
                          .doc(chatId)
                          .collection('messages')
                          .add({
                        'content': message,
                        'senderId': widget.currentUserId,
                        'receiverId': widget.otherUserId,
                        'timestamp': FieldValue.serverTimestamp(),
                        'seen': false,
                      });

                      await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .set(
                        {
                          'lastMessage': message,
                          'lastMessageTime': FieldValue.serverTimestamp(),
                          'lastMessageFromUser': widget.currentUserId,
                          'seen': false,
                          'participants': [
                            widget.currentUserId,
                            widget.otherUserId,
                          ],
                        },
                        SetOptions(merge: true),
                      );

                      _messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
