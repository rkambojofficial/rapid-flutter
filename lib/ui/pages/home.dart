import 'package:flutter/material.dart';

import '../../data/blocs/home_bloc.dart';
import '../../data/models/chat.dart';
import '../widgets/chat_tile.dart';
import 'add_chat.dart';
import 'chat.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _homeBloc = HomeBloc();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _homeBloc.setUserStatus(true);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _homeBloc.setUserStatus(true);
    } else {
      _homeBloc.setUserStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rapid'),
        actions: [
          PopupMenuButton<int>(
            tooltip: 'Show Menu',
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Sign Out'),
                value: 0,
              ),
            ],
            onSelected: _onSelected,
          ),
        ],
      ),
      body: StreamBuilder<List<Chat>>(
        stream: _homeBloc.chats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data.length > 0) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                ),
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  final chat = snapshot.data[index];
                  return ChatTileWidget(
                    chat: chat,
                    onTap: () {
                      final route = MaterialPageRoute(
                        builder: (_) => ChatPage(
                          chat: chat,
                          homeBloc: _homeBloc,
                        ),
                      );
                      Navigator.of(context).push(route);
                    },
                  );
                },
              );
            }
            return Center(
              child: Text(
                'No Chats',
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add Chat',
        onPressed: () {
          final route = MaterialPageRoute(
            builder: (_) => AddChatPage(
              homeBloc: _homeBloc,
            ),
          );
          Navigator.of(context).push(route);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _homeBloc.dispose();
  }

  void _onSelected(int value) async {
    switch (value) {
      case 0:
        _homeBloc.signOut();
        break;
    }
  }
}
