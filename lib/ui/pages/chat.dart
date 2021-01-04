import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rapid/data/blocs/home_bloc.dart';
import 'package:rapid/data/models/chat.dart';
import 'package:rapid/data/models/message.dart';
import 'package:rapid/data/repositories/auth.dart';
import 'package:rapid/data/repositories/firestore.dart';
import 'package:rapid/data/repositories/message.dart';
import 'package:rapid/ui/widgets/message_tile.dart';
import 'package:rapid/utils.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;
  final HomeBloc homeBloc;

  const ChatPage({
    @required this.chat,
    @required this.homeBloc,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _user = AuthRepository.currentUser;
  final _messageController = TextEditingController();
  final _changeController = TextEditingController();
  final _boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(24.0),
    boxShadow: [
      BoxShadow(
        color: Colors.grey[400],
        blurRadius: 2.0,
      ),
    ],
  );
  String _token;

  Chat get _chat => widget.chat;

  HomeBloc get _homeBloc => widget.homeBloc;

  Text subtitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.0,
      ),
    );
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_chat.userName),
            StreamBuilder<Event>(
              stream: FirestoreRepository.userStatus(_chat.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final value = snapshot.data.snapshot.value;
                  final bool online = value['online'];
                  final int lastSeenAt = value['lastSeenAt'];
                  _token = value['token'];
                  if (online) {
                    return subtitle('Online');
                  } else {
                    return subtitle('Last seen ${date(lastSeenAt)}');
                  }
                }
                return Container();
              },
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            tooltip: 'Show Menu',
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Clear Chat'),
                value: 0,
              ),
            ],
            onSelected: _onSelected,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _homeBloc.messages,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error),
                  );
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.data.length > 0) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                      ),
                      reverse: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        final message = snapshot.data[index];
                        final mine = message.userId == _user.uid;
                        return MessageTileWidget(
                          message: message,
                          mine: mine,
                          onTap: () async {
                            await showAlertDialog(
                              context: context,
                              content: message.body,
                              actions: mine
                                  ? [
                                      TextButton(
                                        child: Text('DELETE'),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          _showDeleteDialog(message);
                                        },
                                      ),
                                      if (!message.changed)
                                        TextButton(
                                          child: Text('CHANGE'),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            _changeController.text = message.body;
                                            _showChangeDialog(message);
                                          },
                                        ),
                                    ]
                                  : [
                                      TextButton(
                                        child: Text('DELETE FOR ME'),
                                        onPressed: () => _deleteMessage(message),
                                      ),
                                    ],
                            );
                          },
                        );
                      },
                    );
                  }
                  return Center(
                    child: Text(
                      'No Messages',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    decoration: _boxDecoration,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.0),
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          hintText: 'Type a message',
                          contentPadding: const EdgeInsets.all(14.0),
                        ),
                        cursorColor: Colors.deepOrange,
                        controller: _messageController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 4.0,
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: _boxDecoration.copyWith(
                      color: Colors.deepOrange,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                  onTap: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _changeController.dispose();
    _homeBloc.resetChatId();
  }

  void _initialize() async {
    _homeBloc.getMessages(_chat.id);
    if (_chat.totalUnseenMessages > 0) {
      await MessageRepository.seenAll(_chat.id);
    }
  }

  void _onSelected(int value) async {
    switch (value) {
      case 0:
        await MessageRepository.clearMessages(
          all: false,
          chatId: _chat.id,
        );
        _homeBloc.getMessages(_chat.id);
        break;
    }
  }

  void _sendMessage() async {
    final body = _messageController.text;
    if (body.trim().isNotEmpty) {
      final doc = FirestoreRepository.update(_chat.userId);
      final message = await Message(
        id: doc.id,
        chatId: _chat.id,
        userId: _user.uid,
        body: body,
        seen: true,
        createdAt: millis,
      ).save();
      _messageController.clear();
      _homeBloc.getMessages(_chat.id);
      await doc.set(message.toUpdate());
      await sendNotification(
        token: _token,
        title: _user.displayName,
        body: 'Sent you a message',
      );
    }
  }

  void _deleteMessage(Message message) async {
    Navigator.of(context).pop();
    await message.delete();
    _homeBloc.getMessages(_chat.id);
  }

  void _showDeleteDialog(Message message) async {
    await showAlertDialog(
      context: context,
      title: 'Delete Message',
      content: message.body,
      actions: [
        TextButton(
          child: Text('FOR ME'),
          onPressed: () => _deleteMessage(message),
        ),
        TextButton(
          child: Text('FOR EVERYONE'),
          onPressed: () async {
            _deleteMessage(message);
            await FirestoreRepository.update(_chat.userId).set({
              'type': 'Delete',
              'chatId': _chat.id,
              'userId': _user.uid,
              'messageId': message.id,
              'createdAt': millis,
            });
          },
        ),
      ],
    );
  }

  void _showChangeDialog(Message message) async {
    await showAlertDialog(
      context: context,
      title: 'Change Message',
      content: TextField(
        decoration: InputDecoration(
          filled: true,
          hintText: 'Type a message',
        ),
        style: TextStyle(
          fontSize: 18.0,
        ),
        cursorColor: Colors.deepOrange,
        autofocus: true,
        controller: _changeController,
        textCapitalization: TextCapitalization.sentences,
        maxLines: null,
      ),
      actions: [
        TextButton(
          child: Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('OK'),
          color: Colors.deepOrange,
          textColor: Colors.white,
          onPressed: () async {
            final body = _changeController.text;
            if (body != message.body && body.trim().isNotEmpty) {
              Navigator.of(context).pop();
              await MessageRepository.changeMessage(message.id, body);
              _homeBloc.getMessages(_chat.id);
              await FirestoreRepository.update(_chat.userId).set({
                'type': 'Change',
                'chatId': _chat.id,
                'userId': _user.uid,
                'messageId': message.id,
                'body': body,
                'createdAt': millis,
              });
            }
          },
        ),
      ],
    );
  }
}
