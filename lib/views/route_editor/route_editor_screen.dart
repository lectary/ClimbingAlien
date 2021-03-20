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
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
      create: (context) => ClimaxViewModel(),
      child: ChangeNotifierProvider(
        /// Init viewModel for routeEditor
        create: (context) => RouteEditorViewModel(
            routeId: route.id,
            size: size,
            climbingRepository: Provider.of<ClimbingRepository>(context, listen: false),
            climaxViewModel: Provider.of<ClimaxViewModel>(context, listen: false)),
        child: Builder(
          builder: (context) {
            /// Get models for childs - TODO Can be collapsed!
            final climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
            final routeEditorModel = Provider.of<RouteEditorViewModel>(context, listen: false);
            return Builder(builder: (context) {
              /// Build based on viewModel state, i.e. initialization is done
              final state = context.select((RouteEditorViewModel model) => model.state);
              if (state == ModelState.LOADING) {
                // Scaffold with loading indicators
                return Scaffold(
                  appBar: AppBar(
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 32.0),
                        child: Center(
                            child: Container(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(backgroundColor: Colors.white))),
                      )
                    ],
                  ),
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                final initMode = context.select((RouteEditorViewModel model) => model.initMode);
                final joystickOn = context.select((RouteEditorViewModel model) => model.joystickOn);
                return Scaffold(
                  appBar: AppBar(
                    actions: [
                      !initMode
                          ? IconButton(
                              icon: Icon(Icons.gamepad),
                              color: joystickOn ? Colors.red : Colors.white,
                              onPressed: () => routeEditorModel.joystickOn = !joystickOn)
                          : Container(),
                      Builder(builder: (context) {
                        final tapOn = context.select((ClimaxViewModel model) => model.tapOn);
                        return !initMode ? _buildOptionHeader(context, tapOn) : Container();
                      }),
                      Builder(
                        builder: (context) {
                          final step = context.select((RouteEditorViewModel model) => model.step);
                          final graspList = context.select((RouteEditorViewModel model) => model.graspList);
                          return !initMode
                            ? IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: (step <= graspList.length) ? () => routeEditorModel.deleteCurrentGrasp() : null)
                            : Container();
                        },
                      ),
                    ],
                  ),
                  body: Builder(builder: (context) {
                    final joystickOn = context.select((RouteEditorViewModel model) => model.joystickOn);
                    return Column(
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              RouteEditor(wall, route, key: UniqueKey()),
                              initMode ? _buildInitModeBar(context) : Container(),
                              (!initMode && joystickOn)
                                  ? _buildJoystick(routeEditorModel.climaxViewModel)
                                  : Container(),
                              Builder(builder: (context) {
                                final step = context.select((RouteEditorViewModel model) => model.step);
                                final graspList = context.select((RouteEditorViewModel model) => model.graspList);
                                return !initMode ? _buildBottomBar(context, step, graspList) : Container();
                              })
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                );
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int step, List<Grasp> graspList) {
    final routeEditorModel = Provider.of<RouteEditorViewModel>(context, listen: false);
    final climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
    return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              child: Text("-"),
              onPressed: (step > 1)
                  ? () {
                      routeEditorModel.previousGrasp();
                    }
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
                onPressed: (step > graspList.length && !climaxModel.climaxMoved)
                    ? null
                    : () {
                        routeEditorModel.nextGrasp();
                      })
          ],
        ));
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
