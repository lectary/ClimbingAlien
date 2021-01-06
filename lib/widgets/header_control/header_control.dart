import 'package:climbing_alien/widgets/header_control/header_extension_animation.dart';
import 'package:flutter/material.dart';

class HeaderControl extends StatefulWidget {
  final Function nextSelectionCallback;
  final Function resetCallback;

  HeaderControl({this.nextSelectionCallback, this.resetCallback});

  @override
  _HeaderControlState createState() => _HeaderControlState();
}

class _HeaderControlState extends State<HeaderControl> {
  int taskCounter = 0;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight), // height of device system panel
      child: Container(
        height: kToolbarHeight, // default material height of toolbar
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeaderExtensionAnimation(children: [
              FlatButton(
                padding: EdgeInsets.zero,
                onPressed: widget.resetCallback ?? () {},
                child: Text("Reset"),
              )
            ]),
            InkWell(
              onTap: widget.nextSelectionCallback ?? () {},
              child: Container(
                width: kToolbarHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(child: FittedBox(fit: BoxFit.fill, child: Icon(Icons.repeat))),
                    Text("$taskCounter", style: Theme.of(context).textTheme.headline6)
                  ],
                ),
              ),
            ),
            RotatedBox(
              quarterTurns: 1,
              child: FlatButton(
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
      ),
    );
  }
}
