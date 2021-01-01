import 'package:flutter/material.dart';

class HeaderControl extends StatefulWidget {
  final Function nextSelectionCallback;

  HeaderControl(this.nextSelectionCallback);

  @override
  _HeaderControlState createState() => _HeaderControlState();
}

class _HeaderControlState extends State<HeaderControl> {
  int taskCounter = 0;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Header Test"),
          FlatButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              widget.nextSelectionCallback();
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.repeat, size: 96),
                Text("$taskCounter", style: Theme.of(context).textTheme.headline5)
              ],
            ),
          ),
          RotatedBox(
            quarterTurns: 1,
            child: RaisedButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  taskCounter++;
                });
              },
              child: Text("Done"),
            ),
          )
        ],
      ),
    );
  }
}
