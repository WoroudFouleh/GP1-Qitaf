import 'package:flutter/material.dart';
import 'package:login_page/screens/signin_screen.dart';
import 'package:login_page/screens/signup_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';
import 'package:login_page/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              )),
          const Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'تسجيل دخول',
                      onTap: SigninScreen(),
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'إنشاء حساب',
                      onTap: SignupScreen(),
                      color: Colors.white,
                      textColor: Color.fromARGB(255, 12, 84, 15),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
