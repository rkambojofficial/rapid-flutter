import 'package:flutter/material.dart';

class SplashWidget extends StatelessWidget {
  final Widget child;

  const SplashWidget({this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  'images/icon.png',
                  width: 64.0,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
