import 'package:flutter/material.dart';

/// Helper class with custom static dialogs.
class Dialogs {
  static Future<DateTime?> showDatePickerDialog(BuildContext context) async {
    return showDatePicker(
        context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
  }

  static Future<TimeOfDay?> showTimePickerDialog(BuildContext context) async {
    return showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  /// Custom alert dialog with [title], optional [body], [submitText] and [submitFunc].
  /// Has a negative `Cancel` button.
  /// The positive button has as its label [submitText] and as its callback [submitFunc].
  /// Returns either [False] in case the negative button is pressed or when the positive button is pressed,
  /// either the result of [submitFunc], or in case [submitFunc] is missing or returns [Null], [True].
  static Future<dynamic> showAlertDialog(
      {required BuildContext context,
      required String title,
      String body = "",
      required String submitText,
      Function? submitFunc}) async {
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: body.isNotEmpty ? Text(body) : null,
          actions: <Widget>[
            TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.red,
                ),
                child: Text(
                  "Cancel",
                ),
                onPressed: () => Navigator.of(context).pop(false)),
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.primaryVariant,
              ),
              child: Text(
                submitText,
              ),
              onPressed: () {
                if (submitFunc != null) {
                  final result = submitFunc();
                  if (result != null) {
                    return Navigator.of(context).pop(result);
                  } else {
                    return Navigator.of(context).pop(true);
                  }
                }
                return Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  /// Custom info dialog with mandatory [title] and [content] and a positive `OK` button.
  static Future<void> showInfoDialog(
      {required BuildContext context, required String title, required String content}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.primaryVariant,
              ),
              child: Text(
                'OK',
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
