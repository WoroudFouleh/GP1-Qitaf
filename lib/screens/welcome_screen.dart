import 'package:flutter/material.dart';
import 'package:login_page/Auth/signin_screen.dart';
import 'package:login_page/screens/signup_screen.dart';
import 'package:login_page/widgets/custom_scaffold.dart';
import 'package:login_page/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >
              600; // Detect if the screen is wide (web-like layout)
          return Column(
            children: [
              Flexible(
                flex: isWide ? 5 : 8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: isWide
                        ? 100.0
                        : 40.0, // Adjust horizontal padding for web
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height:
                            isWide ? 20.0 : 40.0, // Add space above the buttons
                      ),
                      Row(
                        mainAxisAlignment: isWide
                            ? MainAxisAlignment
                                .center // Center buttons for wide screens
                            : MainAxisAlignment
                                .spaceBetween, // Spread buttons for mobile
                        children: [
                          SizedBox(
                            width: isWide
                                ? 200
                                : MediaQuery.of(context).size.width *
                                    0.4, // Adjust button width
                            child: WelcomeButton(
                              buttonText: 'تسجيل دخول',
                              onTap: SigninScreen(),
                              color: Colors.transparent,
                              textColor: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: isWide
                                ? 200
                                : MediaQuery.of(context).size.width *
                                    0.4, // Adjust button width
                            child: WelcomeButton(
                              buttonText: 'إنشاء حساب',
                              onTap: SignupScreen(),
                              color: Colors.white,
                              textColor: const Color.fromARGB(255, 12, 84, 15),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height:
                            isWide ? 20.0 : 30.0, // Add space below the buttons
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
