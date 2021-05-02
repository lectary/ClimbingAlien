import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/widgets_unused/header_control/header_extension_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HeaderControl extends StatefulWidget {
  final String title;
  final Function? nextSelectionCallback;
  final Function? resetCallback;
  final Function? stepFinishedCallback;

  HeaderControl(this.title, {this.nextSelectionCallback, this.resetCallback, this.stepFinishedCallback});

  @override
  _HeaderControlState createState() => _HeaderControlState();
}

class _HeaderControlState extends State<HeaderControl> {
  late ClimaxViewModel climaxModel;
  int taskCounter = 0;

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    int order = context.select((ClimaxViewModel model) => model.order);
    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight), // height of device system panel
      child: Container(
        height: kToolbarHeight, // default material height of toolbar
        child: Stack(
          children: [
            // AppBar title
            Padding(
              padding: const EdgeInsets.only(left: 72.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.title,
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: Theme.of(context).colorScheme.onPrimary))),
            ),
            // Control elements
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                color: Theme.of(context).colorScheme.primary,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HeaderExtensionAnimation(buttonColor: Theme.of(context).colorScheme.onPrimary, children: [
                      TextButton(
                        onPressed: widget.resetCallback as void Function()? ?? () {},
                        child: Text("Reset", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                      )
                    ]),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: Icon(Icons.remove),
                            color: Theme.of(context).colorScheme.onPrimary,
                            onPressed: () {
                              if (order == 0) return;
                              climaxModel.order--;
                            },
                            visualDensity: VisualDensity.compact),
                        Text("$order",
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                        IconButton(
                            icon: Icon(Icons.add),
                            color: Theme.of(context).colorScheme.onPrimary,
                            onPressed: () => climaxModel.order++,
                            visualDensity: VisualDensity.compact),
                      ],
                    ),
                    RotatedBox(
                      quarterTurns: 1,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            climaxModel.order++;
                          });
                          widget.stepFinishedCallback?.call();
                        },
                        child: Text(
                          "Done",
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
