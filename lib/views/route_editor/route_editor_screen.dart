import 'package:climbing_alien/data/entity/grasp.dart';
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

  bool init = false;

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
    widget.route.graspList.sort((Grasp g1, Grasp g2) => g1.order - g2.order);
    if (widget.route.graspList.isEmpty) {
      init = true;
      _defaultClimaxPosition();
    } else {
      _setClimaxPositionByGraspList(widget.route.graspList);
    }
  }

  /// Updating climax position based on graspList
  _setClimaxPositionByGraspList(List<Grasp> graspList) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      climaxModel.resetClimax();
      climaxModel.setupByGrasp(graspList[graspList.length - 1]);
    });
  }

  /// Updating climax default position after finishing widget build
  _defaultClimaxPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      climaxModel.resetClimax();
      final size = MediaQuery.of(context).size;
      screenCenter = Offset(size.width / 2.0, size.height / 2.0 - kToolbarHeight);
      climaxModel.updateClimaxPosition(screenCenter);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool backgroundSelected = context.select((ClimaxViewModel model) => model.backgroundSelected);
    if (init) {
      backgroundSelected = true;
      init = false;
    }
    final tapOn = context.select((ClimaxViewModel model) => model.tapOn);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: HeaderControl(
          "Route Editor",
          nextSelectionCallback: climaxModel.selectNextLimb,
          resetCallback: () => climaxModel.resetClimax(position: screenCenter),
          stepFinishedCallback: () => climaxModel.saveCurrentPosition(widget.route.id),
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
                backgroundSelected
                    ? Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Column(
                          children: [
                            Text(
                              'Adjust the size and position of the background',
                              style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                  onPressed: () => climaxModel.backgroundSelected = !climaxModel.backgroundSelected,
                                  child: Text('Done')),
                            )
                          ],
                        ),
                      )
                    : Container(),
                !backgroundSelected
                    ? Positioned(
                        left: 0,
                        bottom: 0,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                  onPressed: () => climaxModel.backgroundSelected = !backgroundSelected,
                                  child: Text('Edit background')),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: tapOn
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context).colorScheme.primary),
                                  onPressed: () => climaxModel.tapOn = !tapOn,
                                  child: Text('Tap')),
                            )
                          ],
                        ),
                      )
                    : Container(),
                !backgroundSelected
                    ? Positioned(
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
                        ))
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
