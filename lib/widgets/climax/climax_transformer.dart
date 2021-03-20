import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClimaxTransformer extends StatelessWidget {
  final String imagePath;

  const ClimaxTransformer({
    Key key,
    @required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final scaleBackground = context.select((ClimaxViewModel model) => model.scaleBackground);
      final scaleAll = context.select((ClimaxViewModel model) => model.scaleAll);
      final Offset deltaTranslateBackground = context.select((ClimaxViewModel model) => model.deltaTranslateBackground);
      final Offset deltaTranslateAll = context.select((ClimaxViewModel model) => model.deltaTranslateAll);
      return Transform.translate(
        offset: -deltaTranslateAll,
        child: Transform.scale(
          scale: scaleAll,
          child: Stack(fit: StackFit.expand, children: [
            Transform.translate(
                offset: -deltaTranslateBackground,
                child: Transform.scale(scale: scaleBackground, child: ImageDisplay(imagePath))),
            Container(color: Colors.transparent, child: Climax()),
          ]),
        ),
      );
    });
  }
}
