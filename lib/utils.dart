import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

const serverKey = 'AAAAGMd0QwA:APA91bF_D4J29QPBFXh9wOkSPMPSA40uuoy_3HBdgqhQutp54YaEz-IHH5hHzD0swMPvRNhDNgb3mrItYC3BRvk83aGth0mY7oYL8QnQbVKKd-NLCk3IIREeCDFAm3RePYMw1sw_wM_p';

final emailFormat = RegExp(r'^[\w.-]{2,}[\w]@[\w]{2,}\.[\w]{2,7}$');

int get millis => DateTime.now().millisecondsSinceEpoch;

String date(int millis) {
  final date = DateTime.fromMillisecondsSinceEpoch(millis);
  final currentDate = DateTime.now();
  final formattedDate = DateFormat.yMMMd().format(date);
  final formattedCurrentDate = DateFormat.yMMMd().format(currentDate);
  if (formattedDate == formattedCurrentDate) {
    return DateFormat.jm().format(date);
  }
  return formattedDate;
}

extension Conversion on int {
  String get toDate => date(this);
}

extension Validation on String {
  bool get isEmail => emailFormat.hasMatch(this);

  bool get isNotEmail => !isEmail;
}

void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
  );
  Scaffold.of(context).showSnackBar(snackBar);
}

Future<void> showAlertDialog({
  @required BuildContext context,
  String title,
  dynamic content,
  List<Widget> actions,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: title != null
            ? Text(
                title,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        content: SingleChildScrollView(
          child: content is String
              ? Text(
                  content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                )
              : content is Widget
                  ? content
                  : null,
        ),
        actions: actions,
      );
    },
  );
}

Future<Response> sendNotification({
  @required String token,
  @required String title,
  @required String body,
}) {
  return post(
    'https://fcm.googleapis.com/fcm/send',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': {
          'title': title,
          'body': body,
        },
        'priority': 'high',
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'to': token,
      },
    ),
  );
}

void log(dynamic object) {
  print('Debug: $object');
}

void error({
  @required String at,
  @required Exception exception,
}) {
  log('Error at $at: $exception');
}
