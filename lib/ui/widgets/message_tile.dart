import 'package:flutter/material.dart';

import '../../data/models/message.dart';
import '../../utils.dart';

class MessageTileWidget extends StatelessWidget {
  final Message message;
  final bool mine;
  final VoidCallback onTap;

  const MessageTileWidget({
    @required this.message,
    @required this.mine,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 6.0,
          horizontal: 12.0,
        ),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                left: mine ? 80.0 : 0.0,
                right: mine ? 0.0 : 80.0,
              ),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: mine ? Colors.deepOrange : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12.0),
                  topRight: const Radius.circular(12.0),
                  bottomRight: Radius.circular(mine ? 2.0 : 12.0),
                  bottomLeft: Radius.circular(mine ? 12.0 : 2.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400],
                    blurRadius: 2.0,
                  ),
                ],
              ),
              child: Text(
                message.body,
                style: TextStyle(
                  color: mine ? Colors.white : Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(message.createdAt.toDate),
            if (message.changed) Text(mine ? 'You changed this message' : 'This message was changed'),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
