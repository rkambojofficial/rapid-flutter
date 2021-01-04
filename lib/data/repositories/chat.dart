import 'package:rapid/data/database.dart';
import 'package:rapid/data/models/chat.dart';

class ChatRepository {
  static Future<List<Chat>> getChats() async {
    final database = await RapidDatabase.instance;
    final maps = await database.rawQuery(
      'SELECT *, '
      '(SELECT body FROM message WHERE chatId = chat.id ORDER BY createdAt DESC LIMIT 1) AS lastMessage, '
      '(SELECT COUNT(id) FROM message WHERE chatId = chat.id AND seen = 0) AS totalUnseenMessages, '
      '(SELECT createdAt FROM message WHERE chatId = chat.id ORDER BY createdAt DESC LIMIT 1) AS updatedAt '
      'FROM chat ORDER BY updatedAt DESC;',
    );
    return List<Chat>.generate(maps.length, (index) {
      return Chat.fromMap(maps[index]);
    });
  }

  static Future<Chat> getChat(String id) async {
    final database = await RapidDatabase.instance;
    final maps = await database.query(
      'chat',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.length > 0) {
      return Chat.fromMap(maps.first);
    }
    return null;
  }

  static Future<bool> chatExists(String userId) async {
    final database = await RapidDatabase.instance;
    final maps = await database.query(
      'chat',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return maps.length > 0;
  }

  static Future<int> insertChat(Chat chat) async {
    final database = await RapidDatabase.instance;
    return database.insert('chat', chat.toMap());
  }

  static Future<int> updateChat(String id, Map<String, dynamic> values) async {
    final database = await RapidDatabase.instance;
    return database.update(
      'chat',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> clearChats() async {
    final database = await RapidDatabase.instance;
    return database.delete('chat');
  }
}
