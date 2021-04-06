import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/widgets/climax/climax_transformer.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';

/// One-finger translate (background&all(=background+climax)) and two-finger scale (background&all) using a single GestureDetector with latest flutter channel.
///
/// In the latest channel, GestureDetectors ScaleUpdateDetails got a new attribute `pointerCount`. This allows to differ between pan (one finger) and scale (two fingers).
/// Panning is done via onScale by using its [localFocalPoint] attribute. Since there is no deltaX movement available, the difference between the last and current [localFocalPoint] is calculated
/// to retrieve some kind of movement-delta which is used in [Transform.translate].
/// OnScale behaviour is also not quite convenient. When releasing fingers, the scale value jumps back to 1. To avoid weird scale jumps, values of 1 are ignored.
/// To persist the scaling between gestures, the last scaling value is saved and used as baseValue which gets then multiplied with the new current scale value.
/// Re-added move-climax-limb-by-tap possibility but with [GestureDetector.onLongPressStart] to avoid conflicts with one-finger pan.
class RouteEditor extends StatefulWidget {
  final Wall wall;
  final Route route;

  RouteEditor(this.wall, this.route, {Key? key}) : super(key: key);

  @override
  _RouteEditorState createState() => _RouteEditorState();
}

class _RouteEditorState extends State<RouteEditor> {
  late ClimaxViewModel climaxModel;

  bool isTranslate = false;
  bool isScale = false;

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final transformAll = context.select((ClimaxViewModel model) => model.transformAll);
    return _buildGestureDetector(transformAll, child: ClimaxTransformer(background: widget.wall.file));
  }

  GestureDetector _buildGestureDetector(bool editAll, {Widget? child}) {
    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        if (climaxModel.tapOn) {
          return;
        }
        setState(() {
          isTranslate = details.pointerCount == 1 ? true : false;
          isScale = details.pointerCount == 2 ? true : false;

          if (isTranslate) {
            if (editAll) {
              climaxModel.lastTranslateAll = details.localFocalPoint;
            } else {
              climaxModel.lastTranslateBackground = details.localFocalPoint;
            }
          }

          if (isScale) {
            if (editAll) {
              climaxModel.baseScaleAll = climaxModel.scaleAll;
            } else {
              climaxModel.baseScaleBackground = climaxModel.scaleBackground;
            }
          }
        });
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        if (climaxModel.tapOn) {
          return;
        }
        setState(() {
          isTranslate = details.pointerCount == 1 ? true : false;
          isScale = details.pointerCount == 2 ? true : false;

          if (isTranslate) {
            climaxModel.isTranslating = true;
            if (editAll) {
              climaxModel.deltaTranslateAll += climaxModel.lastTranslateAll - details.localFocalPoint;
              climaxModel.lastTranslateAll = details.localFocalPoint;
            } else {
              // Use `1 / climaxModel.scaleAll` to have always the same speed of the translation, independent on the current scale
              climaxModel.deltaTranslateBackground +=
                  (climaxModel.lastTranslateBackground - details.localFocalPoint) * 1 / climaxModel.scaleAll;
              climaxModel.lastTranslateBackground = details.localFocalPoint;
            }
          }

          if (isScale) {
            if (details.scale == 1) return;
            if (editAll) {
              climaxModel.scaleAll = climaxModel.baseScaleAll * details.scale;
            } else {
              climaxModel.scaleBackground = climaxModel.baseScaleBackground * details.scale;
            }
          }
        });
      },
      onScaleEnd: (details) {
        climaxModel.isTranslating = false;
      },
      onTapDown: (details) {
        if (climaxModel.tapOn) {
          climaxModel.updateSelectedLimbPosition(details.localPosition);
          climaxModel.tapOn = !climaxModel.tapOn;
        }
      },
      child: Container(color: Colors.transparent, child: child),
    );
  }
}
