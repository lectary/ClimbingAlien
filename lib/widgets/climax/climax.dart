import 'dart:async';

import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/widgets/climax/climax_ghost_painter.dart';
import 'package:climbing_alien/widgets/climax/climax_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

/// Widget responsible for listening and triggering the update process of Climax as well as its Ghost.
///
/// This widgets uses [Timer] to periodically trigger [ClimaxViewModel.updateLimbFree], which updates Climax' movement.
/// It further listens to the various climax variables, like its limbs, selection or colors to update climax state.
/// The drawing process is delegated to [ClimaxPainter] and [ClimaxGhostPainter].
/// By using a stack, climax' ghost is drawn first and then climax to achieve that climax is on top of its ghost.
class Climax extends StatefulWidget {
  Climax({Key? key}) : super(key: key);

  @override
  _ClimaxState createState() => _ClimaxState();
}

class _ClimaxState extends State<Climax> {
  late ClimaxViewModel climaxModel;

  late Timer timer;
  final int refreshTime = 60;

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
    // Using timer for continuously drawing climax to enable continuous movement via joystick
    timer = Timer.periodic(Duration(milliseconds: refreshTime), (Timer t) => climaxModel.updateLimbFree());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get limbs, selection and other values
    final Map<ClimaxLimbEnum, Rect>? limbs = context.select((ClimaxViewModel model) => model.climaxLimbs);
    final Map<ClimaxLimbEnum, Rect>? previousLimbs =
        context.select((ClimaxViewModel model) => model.previousClimaxLimbs);
    final double radius = context.select((ClimaxViewModel model) => model.radius);
    ClimaxLimbEnum? selection = context.select((ClimaxViewModel model) => model.selectedLimb);
    // Colors
    final climaxGhostingColor = context.select((ClimaxViewModel model) => model.climaxGhostingColor);
    final climaxMainColor = context.select((ClimaxViewModel model) => model.climaxMainColor);
    final climaxSelectionColor = context.select((ClimaxViewModel model) => model.climaxSelectionColor);
    // Ghost limbs
    List<Tuple2<Rect, Rect>> limbWithGhost = [];
    limbs?.entries.forEach((entry1) {
      previousLimbs?.entries.forEach((entry2) {
        if (entry1.key != ClimaxLimbEnum.BODY && entry1.key == entry2.key && entry1.value != entry2.value) {
          limbWithGhost.add(Tuple2(entry1.value, entry2.value));
        }
      });
    });
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: ClimaxGhostPainter(limbsWithGhosts: limbWithGhost, radius: radius, ghostColor: climaxGhostingColor),
        ),
        CustomPaint(
          painter: ClimaxPainter(
              limbs: limbs,
              radius: radius,
              climaxColor: climaxMainColor,
              selectedLimb: selection,
              selectionColor: climaxSelectionColor),
        ),
      ],
    );
  }
}
