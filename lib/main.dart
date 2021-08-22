import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'ui/widgets/auth.dart';
import 'ui/widgets/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rapid',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: FutureBuilder<FirebaseApp>(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AuthWidget();
          }
          return SplashWidget();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
