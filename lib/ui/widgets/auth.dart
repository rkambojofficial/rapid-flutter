import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rapid/data/repositories/auth.dart';
import 'package:rapid/ui/pages/home.dart';
import 'package:rapid/ui/pages/sign_in.dart';
import 'package:rapid/ui/pages/sign_up.dart';
import 'package:rapid/ui/widgets/splash.dart';

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
                child: RaisedButton(
                  child: Text('SIGN IN'),
                  color: Colors.white,
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
                child: RaisedButton(
                  child: Text('SIGN UP'),
                  color: Colors.white,
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
