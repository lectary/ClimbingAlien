import 'package:flutter/material.dart';

class Dialogs {
  static Future<DateTime?> showDatePickerDialog(BuildContext context) async {
    return showDatePicker(
        context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
  }

  static Future<TimeOfDay?> showTimePickerDialog(BuildContext context) async {
    return showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              body.isNotEmpty ? Text(body) : Container()
            ],
          ),
          actions: <Widget>[
            TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.red,
                ),
                child: Text(
                  "Abbrechen",
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

  static Future<bool?> showInfoDialog(
      {required BuildContext context, required String title, required String content}) async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.red,
                ),
                child: Text(
                  "Abbrechen",
                ),
                onPressed: () => Navigator.of(context).pop(false)),
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.primaryVariant,
              ),
              child: Text(
                'OK',
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
