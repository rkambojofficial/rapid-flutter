import 'package:flutter/material.dart';
import 'package:rapid/data/models/chat.dart';
import 'package:rapid/utils.dart';

class ChatTileWidget extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatTileWidget({
    @required this.chat,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(chat.userName.substring(0, 1)),
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
                    chat.userName,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (chat.lastMessage != null) ...[
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      chat.lastMessage,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (chat.updatedAt != null) ...[
              SizedBox(
                width: 16.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(chat.updatedAt.toDate),
                  if (chat.totalUnseenMessages > 0) ...[
                    SizedBox(
                      height: 4.0,
                    ),
                    CircleAvatar(
                      child: Text(
                        '${chat.totalUnseenMessages}',
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      radius: 12.0,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
