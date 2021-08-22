import '../database.dart';
import '../models/message.dart';

class MessageRepository {
  static Future<List<Message>> getMessages(String chatId) async {
    final database = await RapidDatabase.instance;
    final maps = await database.query(
      'message',
      where: 'chatId = ?',
      whereArgs: [chatId],
      orderBy: 'createdAt DESC',
    );
    return List<Message>.generate(maps.length, (index) {
      return Message.fromMap(maps[index]);
    });
  }

  static Future<int> insertMessage(Message message) async {
    final database = await RapidDatabase.instance;
    return database.insert(
      'message',
      message.toMap(),
      // conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<int> clearMessages({bool all = true, String chatId}) async {
    final database = await RapidDatabase.instance;
    if (all) {
      return database.delete('message');
    } else {
      return database.delete(
        'message',
        where: 'chatId = ?',
        whereArgs: [chatId],
      );
    }
  }

  static Future<int> seenAll(String chatId) async {
    final database = await RapidDatabase.instance;
    return database.update(
      'message',
      {
        'seen': 1,
      },
      where: 'chatId = ? AND seen = 0',
      whereArgs: [chatId],
    );
  }

  static Future<int> changeMessage(String id, String body) async {
    final database = await RapidDatabase.instance;
    return database.update(
      'message',
      {
        'body': body,
        'changed': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteMessage(String id) async {
    final database = await RapidDatabase.instance;
    return database.delete(
      'message',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
