import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:login_page/Admin/AcceptDelivery.dart';

import 'package:login_page/screens/CustomerWork.dart';
import 'package:login_page/screens/OwnerBooking.dart';
import 'package:login_page/screens/OwnerWorking.dart';
import 'package:login_page/screens/allInbox.dart';
import 'package:login_page/screens/customersBuying.dart'; // Required for formatting relative time.

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({Key? key}) : super(key: key);

  @override
  State<AdminNotificationsPage> createState() => _AdminotificationsPageState();
}

class _AdminotificationsPageState extends State<AdminNotificationsPage> {
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
    // print(widget.currentUserId);
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: 'FtdI4u2El1e9hThkPHhwrwPREFH2')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Helper function to calculate relative time
  String _getRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 1) {
      return DateFormat('EEEE', 'ar').format(timestamp); // e.g., "الاثنين"
    } else if (difference.inDays == 1) {
      return "البارحة";
    } else if (difference.inHours >= 1) {
      return "منذ ${difference.inHours} ساعات";
    } else if (difference.inMinutes >= 1) {
      return "منذ ${difference.inMinutes} دقائق";
    } else {
      return "الآن";
    }
  }

  // Function to handle navigation based on the "page" field
  void _navigateToPage(String page, {String? userId}) {
    if (page == 'delivery') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DeliveryRequestsPage()),
      );
    } else {
      print("Unknown page: $page");
    }
  }

  Widget _getNotificationIcon(String page) {
    switch (page) {
      case 'delivery':
        return Icon(Icons.delivery_dining, color: Colors.blue, size: 24);

      default:
        return Icon(Icons.notifications, color: Colors.grey, size: 24);
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
              "الإشعارات",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(
              width: 10,
            ),
            const Icon(Icons.notifications, color: Colors.white),
          ],
        ),
        backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
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
              DateTime timestamp =
                  (notification['timestamp'] as Timestamp).toDate();
              String page = notification['page'] ?? '';

              return GestureDetector(
                onTap: () {
                  if (!isRead) {
                    _markAsRead(notification.id);
                  }
                  _navigateToPage(page, userId: 'FtdI4u2El1e9hThkPHhwrwPREFH2');
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end, // Align text to the right
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Icon next to the title
                          Row(
                            children: [
                              // _getNotificationIcon(
                              //     page), // The icon for the notification
                              // Space between icon and title
                              Text(
                                "${notification['title'] ?? ''}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _getNotificationIcon(
                                  page), // The icon for the notification
                            ],
                          ),
                          if (!isRead) // Show red dot for unread notifications
                            const Icon(
                              Icons.circle,
                              size: 10,
                              color: Colors.red,
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification['body'] ?? '',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _getRelativeTime(timestamp),
                        textAlign: TextAlign.right,
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
