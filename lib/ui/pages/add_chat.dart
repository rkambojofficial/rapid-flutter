import 'package:flutter/material.dart';

import '../../data/blocs/home_bloc.dart';
import '../../data/models/chat.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth.dart';
import '../../data/repositories/chat.dart';
import '../../data/repositories/firestore.dart';
import '../../utils.dart';
import 'chat.dart';

class AddChatPage extends StatefulWidget {
  final HomeBloc homeBloc;

  const AddChatPage({
    @required this.homeBloc,
  });

  @override
  _AddChatPageState createState() => _AddChatPageState();
}

class _AddChatPageState extends State<AddChatPage> {
  final _currentUser = AuthRepository.currentUser;
  final _emailController = TextEditingController();
  String _emailError;
  bool _loading = false;
  User _user;
  Chat _chat;

  HomeBloc get _homeBloc => widget.homeBloc;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('New Chat'),
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
                        cursorColor: Colors.deepOrange,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      ElevatedButton(
                        child: Text('FIND USER'),
                        onPressed: () => _findUser(context),
                      ),
                      if (_user != null) ...[
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          'User Found',
                          textAlign: TextAlign.center,
                          style: textTheme.subtitle1,
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Container(
                          child: Row(
                            children: [
                              CircleAvatar(
                                child: Text(_user.name.substring(0, 1)),
                                radius: 24.0,
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      _user.name,
                                      style: textTheme.subtitle1,
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Text(_user.emailVerified ? 'Verified' : 'Not Verified'),
                                  ],
                                ),
                              ),
                              TextButton(
                                child: Text(_user.added ? 'ADDED' : 'ADD'),
                                onPressed: _user.added ? null : () => _addChat(context),
                              ),
                            ],
                          ),
                        ),
                      ],
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
  }

  void _findUser(BuildContext context) async {
    final email = _emailController.text;
    setState(() {
      if (email.isEmpty) {
        _emailError = 'Email is required';
      } else if (email.isNotEmail) {
        _emailError = 'Email is invalid';
      } else if (email == _currentUser.email) {
        _emailError = 'Enter someone else\'s email';
      } else {
        _emailError = null;
      }
    });
    if (email.isEmail && email != _currentUser.email) {
      setState(() {
        _user = null;
        _loading = true;
      });
      try {
        final userSnapshot = await FirestoreRepository.findUser(email);
        if (userSnapshot.size > 0) {
          final userDoc = userSnapshot.docs.first;
          final userData = userDoc.data();
          final exists = await ChatRepository.chatExists(userDoc.id);
          userData['id'] = userDoc.id;
          userData['added'] = exists;
          final user = User.fromMap(userData);
          final chatSnapshot = await FirestoreRepository.findChat(userDoc.id, _currentUser.uid);
          if (chatSnapshot.size > 0) {
            final chatDoc = chatSnapshot.docs.first;
            final chatData = chatDoc.data();
            return setState(() {
              _user = user;
              _chat = Chat(
                id: chatData['chatId'],
                userId: user.id,
                userName: user.name,
              );
            });
          }
          setState(() {
            _user = user;
          });
        } else {
          showSnackBar(context, 'Could not find the user');
        }
      } catch (exception) {
        showSnackBar(context, 'Something went wrong');
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _addChat(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    try {
      if (_chat != null) {
        _chat = await _chat.save();
      } else {
        final doc = FirestoreRepository.update(_user.id);
        _chat = await Chat(
          id: doc.id,
          userId: _user.id,
          userName: _user.name,
        ).save();
        await doc.set(_chat.toUpdate(
          userId: _currentUser.uid,
          userName: _currentUser.displayName,
        ));
      }
      final route = MaterialPageRoute(
        builder: (_) => ChatPage(
          chat: _chat,
          homeBloc: _homeBloc,
        ),
      );
      Navigator.of(context).pushReplacement(route);
    } catch (exception) {
      setState(() {
        _loading = false;
      });
      showSnackBar(context, 'Something went wrong');
    }
  }
}
