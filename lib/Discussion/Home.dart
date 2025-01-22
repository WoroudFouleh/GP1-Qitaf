import 'package:flutter/material.dart';
import 'post_composer.dart';
import 'post_card.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/config.dart';
import 'dart:convert';

class HomeDiscussion extends StatefulWidget {
  final String token;

  const HomeDiscussion({required this.token, Key? key}) : super(key: key);

  @override
  _HomeDiscussionState createState() => _HomeDiscussionState();
}

class _HomeDiscussionState extends State<HomeDiscussion> {
  List<dynamic> posts = []; // Holds the list of posts
  bool isLoading = true; // For showing a loading indicator

  @override
  void initState() {
    super.initState();
    fetchPosts(); // Fetch posts when the page initializes
  }

  void fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse(getAllPosts),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          setState(() {
            posts =
                data['posts']; // Update the posts list with the response data
            isLoading = false; // Stop showing the loading indicator
          });
        } else {
          print("Error fetching posts: ${data['message']}");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Failed to load posts: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
          backgroundColor: Color.fromRGBO(15, 99, 43, 1),
          automaticallyImplyLeading: false, // To remove the default back button
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Go back to the previous page
            },
          ),
        ),
        body: Column(
          children: [
            PostComposer(
              token: widget.token,
            ), // Post composer widget
            Expanded(
              child: isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Show loader while fetching posts
                  : posts.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد منشورات حاليًا',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return PostCard(
                                token: widget.token,
                                userName:
                                    '${post['firstName']} ${post['lastName']}' ??
                                        'مستخدم مجهول',
                                userImage: post['writerImage'] ??
                                    'assets/images/profilew.png',
                                postText: post['text'] ?? '',
                                postImage: post['image'] ?? '',
                                postId: post['_id'],
                                reactions: post['reactions'] ??
                                    {'like': 0, 'love': 0, 'interested': 0},
                                comments: post['comments'] ?? [],
                                createdAt: post['createdAt'] ?? '',
                                postUsername: post['username']);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
