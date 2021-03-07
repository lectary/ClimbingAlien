import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/viewmodels/image_viewmodel.dart';
import 'package:climbing_alien/views/route_editor/route_editor.dart';
import 'package:climbing_alien/widgets/controls/joystick_extended.dart';
import 'package:climbing_alien/widgets/header_control/header_control.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';

class RouteEditorScreen extends StatefulWidget {
  static const routeName = "/routeEditor";

  final Wall wall;
  final Route route;

  RouteEditorScreen(this.wall, this.route, {Key key}) : super(key: key);

  @override
  _RouteEditorScreenState createState() => _RouteEditorScreenState();
}

class _RouteEditorScreenState extends State<RouteEditorScreen> {
  ImageViewModel model;

  ClimaxViewModel climaxModel;
  Offset screenCenter;

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
    // Updating climax default position after finishing widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      screenCenter = Offset(size.width / 2.0, size.height / 2.0 - kToolbarHeight);
      climaxModel.updateClimaxPosition(screenCenter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: HeaderControl(
          "Route Editor",
          nextSelectionCallback: climaxModel.selectNextLimb,
          resetCallback: () => climaxModel.resetClimax(position: screenCenter),
        ),
      ),
      // drawer: AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                RouteEditor(widget.wall, widget.route),
                Positioned(
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32.0),
                      child: JoystickWithButtonAndSlider(
                        onDirectionChanged: (degrees, distance) {
                          climaxModel.moveLimbFree(degrees, distance);
                        },
                        onSliderChanged: (speed) => climaxModel.updateSpeed(speed),
                        onClickedUp: () => climaxModel.moveLimbDirectional(Direction.UP),
                        onClickedDown: () => climaxModel.moveLimbDirectional(Direction.DOWN),
                        onClickedLeft: () => climaxModel.moveLimbDirectional(Direction.LEFT),
                        onClickedRight: () => climaxModel.moveLimbDirectional(Direction.RIGHT),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
