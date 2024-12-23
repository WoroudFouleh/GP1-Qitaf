import 'package:flutter/material.dart';

class ImageSlider extends StatelessWidget {
  final Function(int) onChange;
  final int currentSlide;
  const ImageSlider({
    super.key,
    required this.currentSlide,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: PageView(
              scrollDirection: Axis.horizontal,
              allowImplicitScrolling: true,
              onPageChanged: onChange,
              physics: const ClampingScrollPhysics(),
              children: [
                Image.asset(
                  "assets/images/p1.jpg",
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  "assets/images/p3.jpg",
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  "assets/images/q1.jpg",
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  "assets/images/q2.jpg",
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  "assets/images/q3.jpg",
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  "assets/images/q4.jpg",
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  "assets/images/q5.jpg",
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  "assets/images/q8.jpg",
                  fit: BoxFit.cover,
                )
              ],
            ),
          ),
        ),
        Positioned.fill(
          bottom: 10,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => AnimatedContainer(
                  duration: const Duration(microseconds: 300),
                  width: currentSlide == index ? 15 : 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: currentSlide == index
                          ? Colors.black
                          : Colors.transparent,
                      border: Border.all(
                        color: Colors.black,
                      )),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
