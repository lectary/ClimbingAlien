import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/widgets/climax/climax_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Climax extends StatelessWidget {
  final Offset position;

  Climax({this.position, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final limbs = context.select((ClimaxViewModel model) => model.climaxLimbs);
    final double radius = context.select((ClimaxViewModel model) => model.radius);
    ClimaxLimbEnum selection = context.select((ClimaxViewModel model) => model.selectedLimb);
    return GestureDetector(
      onTapDown: (details) {
        RenderBox box = context.findRenderObject();
        final offset = box.globalToLocal(details.globalPosition);
        // Provider.of<ClimaxViewModel>(context, listen: false).selectedLimb = limbs.entries.where((entry) => entry.value.contains(offset)).last.key;
      },
      child: CustomPaint(
        painter: ClimaxPainter(limbs: limbs, radius: radius, selectedLimb: selection),
      ),
    );
  }
}
