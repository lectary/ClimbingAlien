import 'package:flutter/material.dart';

class Dialogs {
  static Future<DateTime> showDatePickerDialog(BuildContext context) async {
    return showDatePicker(
        context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
  }

  static Future<TimeOfDay> showTimePickerDialog(BuildContext context) async {
    return showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  static Future<bool> showAlertDialog(
      {@required BuildContext context,
      @required String title,
      @required String submitText,
      @required Function submitFunc}) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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
                submitFunc();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showInfoDialog(
      {@required BuildContext context, @required String title, @required String content}) async {
    return showDialog<bool>(
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
