import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatefulWidget {
  final String currentUserId;

  const NotificationsPage({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Function to mark a notification as read
  Future<void> _markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  // Fetch notifications for the current user
  Stream<QuerySnapshot> _fetchNotifications() {
    print("1Fetching notifications for userId: ${widget.currentUserId}");
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: widget.currentUserId) // Query by userId
        .orderBy('timestamp', descending: true) // Order by timestamp
        .snapshots(); // Stream the snapshots
  }

  @override
  Widget build(BuildContext context) {
    print("2Fetching notifications for userId: ${widget.currentUserId}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("الاشعارات"),
        backgroundColor: Color.fromARGB(255, 65, 139, 67),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد إشعارات"));
          }

          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              bool isRead = notification['isRead'] ?? false;

              return GestureDetector(
                onTap: () {
                  // Mark notification as read when tapped
                  if (!isRead) {
                    _markAsRead(notification.id);
                  }

                  // Navigate to the desired screen (optional)
                  // For example, navigate to the chat or other details screen.
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isRead
                        ? Colors.white
                        : Color.fromARGB(255, 246, 255,
                            226), // Light green background for unread notifications
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification['body'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        (notification['timestamp'] as Timestamp)
                            .toDate()
                            .toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
