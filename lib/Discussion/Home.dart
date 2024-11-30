import 'package:flutter/material.dart';
import 'post_composer.dart';
import 'post_card.dart';

class HomeDiscussion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Set text direction from right to left
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'استفسارات وحلول',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green[800],
          automaticallyImplyLeading: false, // To remove the default back button
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Go back to the previous page
            },
          ),
        ),
        // endDrawer: CustomDrawer(token: widget.token),
        body: Column(
          children: [
            PostComposer(), // Post composer widget
            Expanded(
              child: ListView(
                children: [
                  PostCard(
                    userName: 'أحمد محمود',
                    userImage: 'assets/images/profilew.png',
                    postText: 'هذا هو أول منشور لي!',
                    postImage: 'assets/images/p1.jpg',
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
