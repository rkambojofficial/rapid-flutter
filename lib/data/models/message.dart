import 'package:flutter/material.dart';
import 'package:rapid/data/repositories/message.dart';

class Message {
  String id;
  String chatId;
  String userId;
  String body;
  bool seen;
  bool changed = false;
  int createdAt;

  Message({
    @required this.id,
    @required this.chatId,
    @required this.userId,
    @required this.body,
    this.seen = false,
    @required this.createdAt,
  });

  Message.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    chatId = map['chatId'];
    userId = map['userId'];
    body = map['body'];
    seen = map['seen'] == 1;
    changed = map['changed'] == 1;
    createdAt = map['createdAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'userId': userId,
      'body': body,
      'seen': seen ? 1 : 0,
      'changed': changed ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  Future<Message> save() async {
    await MessageRepository.insertMessage(this);
    return this;
  }

  Future<int> delete() {
    return MessageRepository.deleteMessage(id);
  }

  Map<String, dynamic> toUpdate() {
    return {
      'type': 'Message',
      'chatId': chatId,
      'userId': userId,
      'body': body,
      'createdAt': createdAt,
    };
  }
}
