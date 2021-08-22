import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/auth.dart';
import '../../data/repositories/firestore.dart';
import '../../utils.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _messaging = FirebaseMessaging();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _emailError;
  String _passwordError;
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          labelText: 'Email',
                          errorText: _emailError,
                        ),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          labelText: 'Password',
                          errorText: _passwordError,
                          suffixIcon: InkWell(
                            child: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            borderRadius: BorderRadius.circular(24.0),
                            onTap: () => setState(() {
                              _obscurePassword = !_obscurePassword;
                            }),
                          ),
                        ),
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      ElevatedButton(
                        child: Text('SIGN IN'),
                        onPressed: () => _signIn(context),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void _signIn(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;
    setState(() {
      if (email.trim().isEmpty) {
        _emailError = 'Email is required';
      } else if (email.isNotEmail) {
        _emailError = 'Email is invalid';
      } else {
        _emailError = null;
      }
      if (password.trim().isEmpty) {
        _passwordError = 'Password is required';
      } else if (password.length < 6) {
        _passwordError = 'Password should be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
    if (email.isEmail && password.trim().length >= 6) {
      setState(() {
        _loading = true;
      });
      try {
        final user = (await AuthRepository.signIn(email, password)).user;
        final token = await _messaging.getToken();
        await FirestoreRepository.setUserStatus(user.uid, {
          'token': token,
        });
        Navigator.of(context).pop();
      } catch (exception) {
        setState(() {
          _loading = false;
        });
        String message = 'Something went wrong';
        if (exception is FirebaseAuthException) {
          message = 'Invalid credentials';
        }
        final snackBar = SnackBar(
          content: Text(message),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
