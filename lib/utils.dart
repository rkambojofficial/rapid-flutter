import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

void log(dynamic object) {
  print('Debug: $object');
}

void error({
  @required String at,
  @required Exception exception,
}) {
  log('Error at $at: $exception');
}
