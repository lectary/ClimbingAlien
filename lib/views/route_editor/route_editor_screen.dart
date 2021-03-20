import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/views/route_editor/route_editor.dart';
import 'package:climbing_alien/views/route_editor/route_editor_viewmodel.dart';
import 'package:climbing_alien/widgets/controls/joystick_extended.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';

class RouteEditorScreen extends StatelessWidget {
  static const routeName = "/routeEditor";

  final Wall wall;
  final Route route;

  RouteEditorScreen(this.wall, this.route, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClimaxViewModel(),
      child: ChangeNotifierProvider(
        create: (context) => RouteEditorViewModel(
            climbingRepository: Provider.of<ClimbingRepository>(context, listen: false),
            climaxViewModel: Provider.of<ClimaxViewModel>(context, listen: false)),
        child: Consumer<RouteEditorViewModel>(
          builder: (context, routeEditorModel, child) {
            // final currentGrasp = context.select((RouteViewModel model) => model.currentGrasp);
            // climaxModel.setupByGrasp(currentGrasp);
            final climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
            return Scaffold(
              appBar: AppBar(
                actions: [
                  !routeEditorModel.initMode
                      ? IconButton(
                          icon: Icon(Icons.gamepad),
                          color: routeEditorModel.joystickOn ? Colors.red : Colors.white,
                          onPressed: () => routeEditorModel.joystickOn = !routeEditorModel.joystickOn)
                      : Container(),
                  Builder(builder: (context) {
                    final tapOn = context.select((ClimaxViewModel model) => model.tapOn);
                    return !routeEditorModel.initMode ? _buildOptionHeader(context, tapOn) : Container();
                  }),
                  // IconButton(
                  //     icon: Icon(Icons.delete),
                  //     onPressed: () {
                  //       // routeModel.deleteCurrentGrasp();
                  //     }),
                ],
                // flexibleSpace: HeaderControl(
                //   "Route Editor",
                //   nextSelectionCallback: climaxModel.selectNextLimb,
                //   resetCallback: () => climaxModel.resetClimax(position: screenCenter),
                // ),
              ),
              body: StreamBuilder<List<Grasp>>(
                  stream: routeEditorModel.getGraspStreamByRouteId(route.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final graspList = snapshot.data;
                      final initMode = context.select((RouteEditorViewModel model) => model.initMode);

                      /// If initMode and graspList is empty, reset climax to default position
                      if (initMode && graspList.isEmpty) {
                        final size = MediaQuery.of(context).size;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // return routeEditorModel.resetClimax(size);
                          climaxModel.resetClimax();
                          Offset screenCenter = Offset(size.width / 2.0, size.height / 2.0 - kToolbarHeight);
                          climaxModel.updateClimaxPosition(screenCenter);
                        });
                      }
                      if (graspList.isNotEmpty) {
                        climaxModel.setupByGrasp(graspList[routeEditorModel.step-1]);
                      }
                      final joystickOn = context.select((RouteEditorViewModel model) => model.joystickOn);
                      return Column(
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                RouteEditor(wall, route, key: UniqueKey()),
                                initMode ? _buildInitModeBar(context) : Container(),
                                (!initMode && joystickOn) ? _buildJoystick(routeEditorModel.climaxViewModel) : Container(),
                                !initMode
                                    ? Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: ButtonBar(
                                          alignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(child: Text("-"), onPressed: () {}
                                                // (routeModel.step - 1 > 0)
                                                //     ? () => setState(() {
                                                //   routeModel.previousGrasp(climaxModel);
                                                //         })
                                                //     : null,
                                                ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor: Theme.of(context).colorScheme.primary,
                                              ),
                                              onPressed: () {},
                                              child: Text('Grasp ${routeEditorModel.step} of ${graspList.length}',
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
                                                  newGrasp.order = routeEditorModel.step;
                                                  newGrasp.routeId = route.id;
                                                  routeEditorModel.insertGrasp(newGrasp);

                                                  // if (newGrasp != routeModel.currentGrasp) {
                                                  //   print('Saving new grasp');
                                                  // }
                                                  // setState(() {
                                                  //   // if (_graspList.length - 1 <= index) {
                                                  //   //   index++;
                                                  //   // } else {
                                                  //   routeModel.nextGrasp(climaxModel);
                                                  //   // }
                                                  // });
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

  Widget _buildInitModeBar(
    BuildContext context,
  ) {
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
                onPressed: () => Provider.of<RouteEditorViewModel>(context, listen: false).initMode = false,
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
          style: TextButton.styleFrom(primary: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Provider.of<RouteEditorViewModel>(context, listen: false).initMode = true),
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
