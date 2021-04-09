import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/views/route_editor/color_row_picker.dart';
import 'package:climbing_alien/views/route_editor/route_editor.dart';
import 'package:climbing_alien/views/route_editor/route_editor_viewmodel.dart';
import 'package:climbing_alien/widgets/color_picker.dart';
import 'package:climbing_alien/widgets/controls/joystick_extended.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';

enum MenuOption {
  DELETE,
  BACK_TO_INIT,
  TOGGLE_JOYSTICK,
  COLOR_ROW_PICKER,
  COLOR_PICKER_MAIN,
  COLOR_PICKER_GHOSTING,
}

/// Screen for creating and editing grasps for a route.
class RouteEditorScreen extends StatelessWidget {
  static const routeName = "/routeEditor";

  final Wall wall;
  final Route route;

  RouteEditorScreen(this.wall, this.route, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
      create: (context) => ClimaxViewModel(size: size),
      child: ChangeNotifierProvider(
        /// Init viewModel for routeEditor
        create: (context) => RouteEditorViewModel(
            route: route,
            size: size,
            climbingRepository: Provider.of<ClimbingRepository>(context, listen: false),
            climaxViewModel: Provider.of<ClimaxViewModel>(context, listen: false)),
        child: Builder(
          builder: (context) {
            /// Build based on viewModel state, i.e. initialization is done
            final state = context.select((RouteEditorViewModel model) => model.state);
            if (state == ModelState.LOADING) {
              // Scaffold with loading indicators
              return Scaffold(
                appBar: AppBar(
                  title: Text(route.title),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 32.0),
                      child: Center(
                          child: Container(
                              height: 24, width: 24, child: CircularProgressIndicator(backgroundColor: Colors.white))),
                    )
                  ],
                ),
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              final initMode = context.select((RouteEditorViewModel model) => model.initMode);
              final editMode = context.select((RouteEditorViewModel model) => model.editMode);
              final joystickOn = context.select((RouteEditorViewModel model) => model.joystickOn);
              return Scaffold(
                appBar: AppBar(
                  title: Text(initMode
                      ? "Route image setup"
                      : editMode
                          ? "Edit ${route.title}"
                          : route.title),
                  actions: initMode
                      ? null
                      : [
                          ...editMode
                              ? [
                                  _buildTapAction(context, initMode),
                                  _buildMoreOptionsAction(
                                      context, initMode, joystickOn, route.graspList?.isEmpty ?? true),
                                  _toggleEditModeAction(context, false),
                                ]
                              : [
                                  _toggleEditModeAction(context, true),
                                ],
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
                            RouteEditor(wall, route),
                            ...editMode
                                ? [
                                    _buildInitModeBar(context, initMode),
                                    _buildJoystick(context, initMode, joystickOn),
                                  ]
                                : [],
                            _buildBottomBar(context, initMode, editMode),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              );
            }
          },
        ),
      ),
    );
  }

  /// Body widgets
  Widget _buildBottomBar(BuildContext context, bool initMode, bool editMode) {
    return Builder(
      builder: (context) {
        final step = context.select((RouteEditorViewModel model) => model.step);
        final graspList = context.select((RouteEditorViewModel model) => model.graspList);
        final routeEditorModel = Provider.of<RouteEditorViewModel>(context, listen: false);
        final climaxMoved = context.select((ClimaxViewModel model) => model.climaxMoved);
        if (initMode) {
          return Container();
        } else {
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
                    child: Text(step > graspList.length ? 'Step $step (new)' : 'Step $step of ${graspList.length}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                  ElevatedButton(
                      child: Text("+"),
                      // Disable button when
                      // 1. no next grasp is available
                      // 2. a new grasp for editing is created, but climax was not moved yet (to avoid redundant copies)
                      onPressed: _checkIsEnabled(editMode, step, graspList, climaxMoved)
                          ? null
                          : () {
                              routeEditorModel.nextGrasp();
                            })
                ],
              ));
        }
      },
    );
  }

  bool _checkIsEnabled(bool editMode, int step, List<Grasp> graspList, bool climaxMoved) {
    if (editMode) {
      return step > graspList.length && !climaxMoved;
    } else {
      return step >= graspList.length;
    }
  }

  Widget _buildInitModeBar(BuildContext context, bool initMode) {
    if (initMode) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Adjust the size and position of the background',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Tooltip(
                          padding: const EdgeInsets.all(8.0),
                          message: "Adjust the background position by dragging and the size by pinching",
                          child: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onPrimary)),
                    ),
                  ],
                ),
              ),
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
    } else {
      return Container();
    }
  }

  Widget _buildJoystick(BuildContext context, bool initMode, bool joystickOn) {
    if (initMode || !joystickOn) {
      return Container();
    } else {
      final climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
      return Positioned(
          right: 0,
          top: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16.0),
            child: JoystickWithButtonAndSlider(
              sliderSide: SliderSide.LEFT,
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

  ///********************************************
  /// AppBar actions
  ///********************************************

  Widget _toggleEditModeAction(BuildContext context, bool editMode) {
    return IconButton(
      icon: Icon(editMode ? Icons.edit : Icons.remove_red_eye_outlined),
      onPressed: () => Provider.of<RouteEditorViewModel>(context, listen: false).editMode = editMode,
    );
  }

  Widget _buildTapAction(BuildContext context, bool initMode) {
    return Builder(builder: (context) {
      final tapOn = context.select((ClimaxViewModel model) => model.tapOn);
      if (initMode) {
        return Container();
      } else {
        return TextButton(
            child: Text('TAP'),
            style: TextButton.styleFrom(
                primary: tapOn ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onPrimary),
            onPressed: () => Provider.of<ClimaxViewModel>(context, listen: false).tapOn = !tapOn);
      }
    });
  }

  Widget _buildMoreOptionsAction(BuildContext context, bool initMode, bool joystickOn, bool initAllowed) {
    if (initMode) {
      return Container();
    } else {
      return Builder(
        builder: (context) {
          final step = context.select((RouteEditorViewModel model) => model.step);
          final graspList = context.select((RouteEditorViewModel model) => model.graspList);
          return PopupMenuButton(
              offset: Offset(0, 25),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: initAllowed,
                      value: MenuOption.BACK_TO_INIT,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.app_settings_alt, color: Theme.of(context).colorScheme.primary),
                          ),
                          Text('Back to initMode'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                        enabled: (step <= graspList.length),
                        value: MenuOption.DELETE,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.delete, color: Theme.of(context).colorScheme.primary),
                            ),
                            Text('Delete'),
                          ],
                        )),
                    PopupMenuItem(
                        textStyle: TextStyle(
                            color: joystickOn
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.onSurface),
                        value: MenuOption.TOGGLE_JOYSTICK,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.gamepad,
                                  color: joystickOn
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.primary),
                            ),
                            Text('Toggle Joystick'),
                          ],
                        )),
                    PopupMenuItem(
                        enabled: (step <= graspList.length),
                        value: MenuOption.COLOR_ROW_PICKER,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text("Color picker Version1", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            ChangeNotifierProvider.value(
                                value: Provider.of<ClimaxViewModel>(context, listen: false), child: ColorRowPicker()),
                          ],
                        )),
                    PopupMenuItem(
                        enabled: (step <= graspList.length),
                        value: MenuOption.COLOR_PICKER_MAIN,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text("Color picker Version2", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container(
                                      height: 18,
                                      width: 18,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Provider.of<ClimaxViewModel>(context, listen: false).climaxMainColor)),
                                ),
                                Text("Choose main color"),
                              ],
                            ),
                          ],
                        )),
                    PopupMenuItem(
                        enabled: (step <= graspList.length),
                        value: MenuOption.COLOR_PICKER_GHOSTING,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                  height: 18,
                                  width: 18,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Provider.of<ClimaxViewModel>(context, listen: false).climaxGhostingColor)),
                            ),
                            Text("Choose ghosting color"),
                          ],
                        ))
                  ],
              onSelected: (MenuOption option) async {
                switch (option) {
                  case MenuOption.DELETE:
                    Provider.of<RouteEditorViewModel>(context, listen: false).deleteCurrentGrasp();
                    break;
                  case MenuOption.BACK_TO_INIT:
                    Provider.of<RouteEditorViewModel>(context, listen: false).initMode = true;
                    break;
                  case MenuOption.TOGGLE_JOYSTICK:
                    Provider.of<RouteEditorViewModel>(context, listen: false).joystickOn = !joystickOn;
                    break;
                  case MenuOption.COLOR_ROW_PICKER:
                    break;
                  case MenuOption.COLOR_PICKER_MAIN:
                    final climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
                    Color? selectedColor = await ColorPicker.asDialog(context, color: climaxModel.climaxMainColor);
                    if (selectedColor != null) {
                      climaxModel.climaxMainColor = selectedColor;
                    }
                    break;
                  case MenuOption.COLOR_PICKER_GHOSTING:
                    final climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
                    Color? selectedColor = await ColorPicker.asDialog(context, color: climaxModel.climaxGhostingColor);
                    if (selectedColor != null) {
                      climaxModel.climaxGhostingColor = selectedColor;
                    }
                    break;
                }
              });
        },
      );
    }
  }
}
