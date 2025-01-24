import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_page/screens/GroupInboxScreen.dart';
import 'package:login_page/screens/InboxScreen.dart';
import 'package:login_page/screens/chat_screen.dart';
import 'package:login_page/screens/createGroup.dart';

class TabbedInboxScreen extends StatefulWidget {
  final String userId;

  const TabbedInboxScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _TabbedInboxScreenState createState() => _TabbedInboxScreenState();
}

class _TabbedInboxScreenState extends State<TabbedInboxScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // عدد التابات
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'صندوق الرسائل',
                style: TextStyle(color: Color.fromRGBO(15, 99, 43, 1)),
              ),
            ],
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color.fromRGBO(15, 99, 43, 1)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: IconButton(
                icon: const Icon(
                  Icons.group_add,
                  color: Color.fromRGBO(15, 99, 43, 1), // تحديد اللون الأخضر
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateGroupScreen(userId: widget.userId),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: IconButton(
                icon: const Icon(Icons.search,
                    color: Color.fromRGBO(15, 99, 43, 1)),
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
          bottom: const TabBar(
            labelColor: Color.fromRGBO(15, 99, 43, 1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color.fromARGB(255, 65, 139, 67),
            tabs: [
              Tab(text: 'مجموعات'),
              Tab(text: 'الرسائل'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GroupInboxScreen(userId: widget.userId), // صفحة مجموعات
            InboxScreen(userId: widget.userId), // صفحة الرسائل الأصلية
          ],
        ),
      ),
    );
  }
}
