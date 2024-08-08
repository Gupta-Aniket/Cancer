import 'dart:math';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cancer/main.dart';
import 'package:cancer/views/home.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Splashscreen extends StatelessWidget {
  Splashscreen({super.key});
  var n = Random().nextInt(6) + 1;
  List<String> titles = [
    "Please wait, gearing up!...",
    "Hold tight, Fitting in pieces together",
    "Please Wait, feeling dizzy!",
    "Please wait, oiling up the engine!",
    "Coming right up, just one more Fish!",
    "Please wait, Coming Right up..\n(No judging)."
  ];
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        backgroundColor: Colors.black38,
        splash: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: Lottie.asset('assets/animation$n.json')),
            Text(
              titles[n - 1],
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
        splashIconSize: 300,
        nextScreen: Home());
  }
}
