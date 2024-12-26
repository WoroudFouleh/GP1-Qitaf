import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';

class ImageSliders extends StatefulWidget {
  const ImageSliders({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ImageSliders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ImageSlider in Flutter"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 250,
            width: double.infinity,
            child: AnotherCarousel(
              images: const [
                AssetImage("assets/images/p1.jpg"),
                AssetImage("assets/images/p3.jpg"),
                AssetImage("assets/images/q1.jpg"),
                AssetImage("assets/images/q2.jpg"),
                AssetImage("assets/images/q3.jpg"),
                AssetImage("assets/images/q4.jpg"),
                AssetImage("assets/images/q5.jpg"),
                AssetImage("assets/images/q8.jpg"),

                // we have display image from netwrok as well
                NetworkImage(
                    "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_640.jpg")
              ],
              dotSize: 6,
              indicatorBgPadding: 5.0,
            ),
          )
        ],
      ),
    );
  }
}
