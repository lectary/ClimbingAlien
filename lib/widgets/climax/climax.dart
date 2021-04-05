import 'dart:async';

import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/widgets/climax/climax_painter.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final limbs = context.select((ClimaxViewModel model) => model.climaxLimbs);
    final double radius = context.select((ClimaxViewModel model) => model.radius);
    ClimaxLimbEnum? selection = context.select((ClimaxViewModel model) => model.selectedLimb);
    return GestureDetector(
      onTapDown: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        final offset = box.globalToLocal(details.globalPosition);
        final limb = limbs!.entries.lastWhereOrNull((entry) {
          if (entry.key != ClimaxLimbEnum.BODY) {
            return entry.value.contains(offset);
          }
          return false;
        });
        if (limb != null) Provider.of<ClimaxViewModel>(context, listen: false).selectLimb(limb.key);
      },
      child: CustomPaint(
        painter: ClimaxPainter(limbs: limbs, radius: radius, selectedLimb: selection),
      ),
    );
  }
}
