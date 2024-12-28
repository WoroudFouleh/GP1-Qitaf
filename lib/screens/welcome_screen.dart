import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:login_page/Auth/signin_screen.dart';
import 'package:login_page/screens/signup_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';
import 'package:login_page/widgets/welcome_button.dart';
import 'package:login_page/services/notification_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the NotificationService when this screen is built
    NotificationService.instance.initialize();

    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'تسجيل دخول',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SigninScreen()),
                        );
                      },
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'إنشاء حساب',
                      onTap: () async {
                        // Send a notification before navigating to SignupScreen
                        await NotificationService.instance.sendNotification(
                          'Hello',
                          'This is a notify',
                        );

                        // Navigate to the SignupScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()),
                        );
                      },
                      color: Colors.white,
                      textColor: const Color.fromARGB(255, 12, 84, 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
