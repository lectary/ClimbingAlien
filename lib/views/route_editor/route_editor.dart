import 'dart:io';

import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/viewmodels/image_viewmodel.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:flutter/material.dart';
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
  @override
  _RouteEditorState createState() => _RouteEditorState();
}

class _RouteEditorState extends State<RouteEditor> {
  ImageViewModel model;
  String backgroundImagePath;
  ClimaxViewModel climaxModel;

  Widget backgroundWidget;
  Image image = Image.asset("assets/images/routes/no-name-route.jpg");

  bool isTranslate = false;
  bool isScale = false;

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    backgroundImagePath = context.select((ImageViewModel model) => model.currentImagePath);
    final scaleBackground = context.select((ClimaxViewModel model) => model.scaleBackground);
    final scaleAll = context.select((ClimaxViewModel model) => model.scaleAll);
    final Offset deltaTranslate = context.select((ClimaxViewModel model) => model.deltaTranslate);
    final Offset deltaTranslateAll = context.select((ClimaxViewModel model) => model.deltaTranslateAll);
    final editAll = context.select((ClimaxViewModel model) => model.backgroundSelected);
    backgroundWidget =
        Transform.translate(offset: -deltaTranslate, child: Transform.scale(scale: scaleBackground, child: image));
    Widget child = Transform.translate(
      offset: -deltaTranslateAll,
      child: Transform.scale(
        scale: scaleAll,
        child: Stack(fit: StackFit.expand, children: [
          _buildBackgroundImage(),
          Container(color: Colors.transparent, child: Climax()),
        ]),
      ),
    );
    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        setState(() {
          isTranslate = details.pointerCount == 1 ? true : false;
          isScale = details.pointerCount == 2 ? true : false;

          if (isTranslate) {
            if (editAll) {
              climaxModel.lastTranslateAll = details.localFocalPoint;
            } else {
              climaxModel.lastTranslate = details.localFocalPoint;
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
        setState(() {
          isTranslate = details.pointerCount == 1 ? true : false;
          isScale = details.pointerCount == 2 ? true : false;

          if (isTranslate) {
            if (editAll) {
              climaxModel.deltaTranslateAll += climaxModel.lastTranslateAll - details.localFocalPoint;
              climaxModel.lastTranslateAll = details.localFocalPoint;
            } else {
              // Use `1 / climaxModel.scaleAll` to have always the same speed of the translation, independent on the current scale
              climaxModel.deltaTranslate +=
                  (climaxModel.lastTranslate - details.localFocalPoint) * 1 / climaxModel.scaleAll;
              climaxModel.lastTranslate = details.localFocalPoint;
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
      onLongPressStart: (details) {
        climaxModel.updateSelectedLimbPosition(details.localPosition);
      },
      child: Container(color: Colors.transparent, child: child),
    );
  }

  Widget _buildBackgroundImage() {
    return backgroundImagePath == null
        ? backgroundWidget
        : FittedBox(fit: BoxFit.fill, child: Image.file(File(backgroundImagePath)));
  }
}
