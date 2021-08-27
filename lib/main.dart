import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'ui/widgets/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: AuthWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}
