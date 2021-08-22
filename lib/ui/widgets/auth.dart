import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/auth.dart';
import '../pages/home.dart';
import '../pages/sign_in.dart';
import '../pages/sign_up.dart';
import 'splash.dart';

class AuthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: AuthRepository.authState,
      initialData: AuthRepository.currentUser,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return HomePage();
        }
        return SplashWidget(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  child: Text('SIGN IN'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.deepOrange,
                  ),
                  onPressed: () {
                    final route = MaterialPageRoute(
                      builder: (context) => SignInPage(),
                    );
                    Navigator.of(context).push(route);
                  },
                ),
              ),
              SizedBox(
                width: 16.0,
              ),
              Expanded(
                child: ElevatedButton(
                  child: Text('SIGN UP'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.deepOrange,
                  ),
                  onPressed: () {
                    final route = MaterialPageRoute(
                      builder: (context) => SignUpPage(),
                    );
                    Navigator.of(context).push(route);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
