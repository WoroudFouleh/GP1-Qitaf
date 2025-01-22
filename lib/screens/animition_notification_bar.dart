import 'package:flutter/material.dart';

class AnimatedNotificationBar extends StatefulWidget {
  final String message;
  final Color backgroundColor;

  const AnimatedNotificationBar({
    Key? key,
    required this.message,
    this.backgroundColor = const Color.fromRGBO(15, 99, 43, 1),
  }) : super(key: key);

  @override
  _AnimatedNotificationBarState createState() =>
      _AnimatedNotificationBarState();
}

class _AnimatedNotificationBarState extends State<AnimatedNotificationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: -100, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Show the notification bar and then hide it after a delay
    _showNotification();
  }

  void _showNotification() {
    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _controller.reverse();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: _animation.value,
          left: 0,
          right: 0,
          child: Material(
            elevation: 4,
            child: Container(
              color: widget.backgroundColor,
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
