import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/viewmodels/image_viewmodel.dart';
import 'package:climbing_alien/viewmodels/route_viewmodel.dart';
import 'package:climbing_alien/views/route_editor/route_editor.dart';
import 'package:climbing_alien/widgets/controls/joystick_extended.dart';
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

  Offset screenCenter;

  int step = 1;

  bool _noChangesYet = false;

  Grasp _currentGrasp;

  @override
  void initState() {
    super.initState();
    // climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
    //
    // // _graspList = widget.route.graspList;
    // // _graspList.sort((g1, g2) => g1.order - g2.order);
    // // _currentGrasp = _graspList.isNotEmpty ? _graspList?.last : null;
    // index = _graspList.length + 1;
    //
    // if (_graspList.isEmpty) {
    //   climaxModel.transformAll = false;
    //   _defaultClimaxPosition();
    // } else {
    //   climaxModel.transformAll = true;
    //   climaxModel.setupByGrasp(_currentGrasp);
    // }
  }

  /// Updating climax default position after finishing widget build
  _defaultClimaxPosition(ClimaxViewModel climaxModel) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      climaxModel.resetClimax();
      final size = MediaQuery.of(context).size;
      screenCenter = Offset(size.width / 2.0, size.height / 2.0 - kToolbarHeight);
      climaxModel.updateClimaxPosition(screenCenter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RouteViewModel(climbingRepository: Provider.of<ClimbingRepository>(context, listen: false)),
      child: ChangeNotifierProvider(
        create: (context) => ClimaxViewModel(),
        child: Builder(
          builder: (context) {
            bool transformAll = context.select((ClimaxViewModel model) => model.transformAll);
            final tapOn = context.select((ClimaxViewModel model) => model.tapOn);
            final climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
            return Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(icon: Icon(Icons.gamepad), onPressed: () {}),
                  _buildOptionHeader(context, tapOn),
                  IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Provider.of<RouteViewModel>(context, listen: false).deleteGrasp(_currentGrasp);
                        // setState(() {
                        //   _graspList.removeAt(_currentGrasp.order);
                        // });
                      }),
                ],
                // flexibleSpace: HeaderControl(
                //   "Route Editor",
                //   nextSelectionCallback: climaxModel.selectNextLimb,
                //   resetCallback: () => climaxModel.resetClimax(position: screenCenter),
                // ),
              ),
              body: StreamBuilder<List<Grasp>>(
                  stream: Provider.of<RouteViewModel>(context, listen: false).getGraspStreamByRouteId(widget.route.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final graspList = snapshot.data;
                      if (!transformAll) {
                        step = graspList.length + 1;
                      }
                      if (graspList.isEmpty && !transformAll) {
                        _defaultClimaxPosition(climaxModel);
                      } else if (graspList.isNotEmpty && (step - 2) < graspList.length) {
                        _currentGrasp = graspList[step - 2];
                        climaxModel.setupByGrasp(_currentGrasp);
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                RouteEditor(widget.wall, widget.route, key: UniqueKey()),
                                !transformAll ? _buildInitModeBar(context) : Container(),
                                // transformAll ? _buildOptionBar(context, transformAll, tapOn) : Container(),
                                transformAll ? _buildJoystick(climaxModel) : Container(),
                                transformAll
                                    ? Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: ButtonBar(
                                          alignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                              child: Text("-"),
                                              onPressed: (step - 1 > 0)
                                                  ? () => setState(() {
                                                        step++;
                                                      })
                                                  : null,
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor: Theme.of(context).colorScheme.primary,
                                              ),
                                              onPressed: () {},
                                              child: Text('Grasp $step of ${graspList.length}',
                                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                                            ),
                                            ElevatedButton(
                                                child: Text("+"),
                                                onPressed:
                                                    // (step > graspList.length)
                                                    //     ? null
                                                    //     :
                                                    () {
                                                  Grasp newGrasp = climaxModel.getCurrentPosition();
                                                  newGrasp.order = _currentGrasp?.order ?? step;
                                                  newGrasp.routeId = _currentGrasp?.routeId ?? widget.route.id;
                                                  if (newGrasp != _currentGrasp) {
                                                    print('Saving new grasp');
                                                    Provider.of<RouteViewModel>(context, listen: false)
                                                        .insertGrasp(newGrasp);
                                                  }
                                                  setState(() {
                                                    // if (_graspList.length - 1 <= index) {
                                                    //   index++;
                                                    // } else {
                                                    step++;
                                                    // }
                                                  });
                                                })
                                          ],
                                        ))
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInitModeBar(BuildContext context, ) {
    return Positioned(
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
                onPressed: () => Provider.of<ClimaxViewModel>(context, listen: false).transformAll = true,
                child: Text('Done')),
          )
        ],
      ),
    );
  }

  Row _buildOptionHeader(BuildContext context, bool tapOn) {
    return Row(children: [
      TextButton(
          child: Text('TAP'),
          style: TextButton.styleFrom(
              primary: tapOn ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Provider.of<ClimaxViewModel>(context, listen: false).tapOn = !tapOn),
      TextButton(
          child: Text('BACK'),
          style: TextButton.styleFrom(
              primary: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Provider.of<ClimaxViewModel>(context, listen: false).transformAll = false),
    ]);
  }

  Widget _buildJoystick(ClimaxViewModel climaxModel) {
    return Positioned(
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
        ));
  }
}
