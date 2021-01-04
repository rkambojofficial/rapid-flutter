import 'package:flutter/material.dart';
import 'package:rapid/data/repositories/chat.dart';
import 'package:rapid/utils.dart';

class Chat {
  String id;
  String userId;
  String userName;
  String lastMessage;
  int totalUnseenMessages = 0;
  int createdAt = millis;
  int updatedAt;

  Chat({
    @required this.id,
    @required this.userId,
    @required this.userName,
  });

  Chat.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    userId = map['userId'];
    userName = map['userName'];
    lastMessage = map['lastMessage'];
    totalUnseenMessages = map['totalUnseenMessages'];
    createdAt = map['createdAt'];
    updatedAt = map['updatedAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt,
    };
  }

  Future<Chat> save() async {
    await ChatRepository.insertChat(this);
    return this;
  }

  Map<String, dynamic> toUpdate({
    @required String userId,
    @required String userName,
  }) {
    return {
      'type': 'Chat',
      'chatId': id,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt,
    };
  }
}
