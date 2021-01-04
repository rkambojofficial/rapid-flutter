import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rapid/data/repositories/auth.dart';
import 'package:rapid/data/repositories/firestore.dart';
import 'package:rapid/utils.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _messaging = FirebaseMessaging();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _nameError;
  String _emailError;
  String _passwordError;
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey('SignUpPage'),
      appBar: AppBar(
        title: Text('Sign Up'),
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
                          labelText: 'Name',
                          errorText: _nameError,
                        ),
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
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
                      RaisedButton(
                        child: Text('SIGN UP'),
                        color: Colors.deepOrange,
                        textColor: Colors.white,
                        onPressed: () => _signUp(context),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void _signUp(BuildContext context) async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    setState(() {
      if (name.trim().isEmpty) {
        _nameError = 'Name is required';
      } else {
        _nameError = null;
      }
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
        final user = (await AuthRepository.signUp(email, password)).user;
        await user.updateProfile(
          displayName: name,
        );
        await FirestoreRepository.setUserData(user.uid, {
          'name': name,
          'email': email,
          'emailVerified': false,
          'createdAt': millis,
        });
        final token = await _messaging.getToken();
        await FirestoreRepository.setUserStatus(user.uid, {
          'token': token,
        });
        Navigator.of(context).pop();
      } catch (exception) {
        if (exception is FirebaseAuthException && exception.code == 'email-already-in-use') {
          return setState(() {
            _emailError = 'Email is already in use';
            _loading = false;
          });
        }
        setState(() {
          _loading = false;
        });
        showSnackBar(context, 'Something went wrong');
      }
    }
  }
}
