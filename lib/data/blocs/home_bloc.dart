import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../repositories/auth.dart';
import '../repositories/chat.dart';
import '../repositories/firestore.dart';
import '../repositories/message.dart';

class HomeBloc {
  final _user = AuthRepository.currentUser;
  final _messaging = FirebaseMessaging();
  final _chatsController = StreamController<List<Chat>>();
  final _messagesController = StreamController<List<Message>>.broadcast();
  SharedPreferences _preferences;
  StreamSubscription<QuerySnapshot> _updatesSubscription;
  StreamSubscription<String> _tokenSubscription;
  String _chatId;

  Stream<List<Chat>> get chats => _chatsController.stream;

  Stream<List<Message>> get messages => _messagesController.stream;

  HomeBloc() {
    getChats();
    _messaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
      ),
    );
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) async {
      await FirestoreRepository.setUserStatus(_user.uid, {
        'token': token,
      });
    });
    SharedPreferences.getInstance().then((preferences) {
      _preferences = preferences;
      final startAfter = _preferences.getInt('updates') ?? millis;
      _updatesSubscription = FirestoreRepository.updates(_user.uid, startAfter).listen((snapshot) {
        snapshot.docChanges.forEach((change) async {
          if (change.type == DocumentChangeType.added) {
            final doc = change.doc;
            final data = doc.data();
            final String chatId = data['chatId'];
            final String userId = data['userId'];
            final String type = data['type'];
            final int createdAt = data['createdAt'];
            final chatOpened = _chatId == chatId;
            switch (type) {
              case 'Chat':
                await Chat(
                  id: chatId,
                  userId: userId,
                  userName: data['userName'],
                ).save();
                break;
              case 'Message':
                await Message(
                  id: doc.id,
                  chatId: chatId,
                  userId: userId,
                  body: data['body'],
                  seen: chatOpened,
                  createdAt: createdAt,
                ).save();
                break;
              case 'Change':
                final String messageId = data['messageId'];
                final String body = data['body'];
                await MessageRepository.changeMessage(messageId, body);
                break;
              case 'Delete':
                final String messageId = data['messageId'];
                await MessageRepository.deleteMessage(messageId);
                break;
            }
            if (chatOpened) {
              getMessages(_chatId);
            }
            getChats();
            _preferences.setInt('updates', createdAt);
          }
        });
      });
    });
  }

  void getChats() {
    ChatRepository.getChats().then((chats) {
      _chatsController.sink.add(chats);
    });
  }

  void getMessages(String chatId) {
    _chatId = chatId;
    MessageRepository.getMessages(_chatId).then((messages) {
      _messagesController.sink.add(messages);
    });
  }

  void setUserStatus(bool online) async {
    final data = <String, dynamic>{
      'online': online,
    };
    if (!online) {
      data['lastSeenAt'] = millis;
    }
    await FirestoreRepository.setUserStatus(_user.uid, data);
  }

  void signOut() async {
    await MessageRepository.clearMessages();
    await ChatRepository.clearChats();
    await _preferences?.clear();
    await _messaging.deleteInstanceID();
    await FirestoreRepository.setUserStatus(_user.uid, {
      'online': false,
      'lastSeenAt': millis,
      'token': null,
    });
    await AuthRepository.signOut();
  }

  void resetChatId() {
    _chatId = null;
    getChats();
  }

  void dispose() {
    _updatesSubscription?.cancel();
    _tokenSubscription?.cancel();
    _messagesController.close();
    _chatsController.close();
  }
}
