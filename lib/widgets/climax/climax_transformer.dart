import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClimaxTransformer extends StatefulWidget {
  final String? file;

  const ClimaxTransformer({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  _ClimaxTransformerState createState() => _ClimaxTransformerState();
}

class _ClimaxTransformerState extends State<ClimaxTransformer> with TickerProviderStateMixin {
  late AnimationController _animationXController;
  late AnimationController _animationYController;
  late Animation<double> _offsetXAnimation;
  late Animation<double> _offsetYAnimation;

  Offset deltaTranslateAll = Offset.zero;
  Offset newDeltaTranslateAll = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationXController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animationYController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _updateTranslateAnimation();
  }

  @override
  void dispose() {
    _animationXController.dispose();
    _animationYController.dispose();
    super.dispose();
  }

  _updateTranslateAnimation() {
    if (deltaTranslateAll == newDeltaTranslateAll) {
      return;
    }

    _animationXController.reset();
    _animationYController.reset();

    _offsetXAnimation = Tween<double>(begin: deltaTranslateAll.dx, end: newDeltaTranslateAll.dx)
        .animate(CurvedAnimation(parent: _animationXController, curve: Curves.fastOutSlowIn))
          ..addListener(() {
            setState(() {});
          });
    _offsetYAnimation = Tween<double>(begin: deltaTranslateAll.dy, end: newDeltaTranslateAll.dy)
        .animate(CurvedAnimation(parent: _animationXController, curve: Curves.fastOutSlowIn))
          ..addListener(() {
            setState(() {});
          });

    _animationXController.forward();
    _animationYController.forward();

    deltaTranslateAll = newDeltaTranslateAll;
  }

  @override
  Widget build(BuildContext context) {
    final scaleBackground = context.select((ClimaxViewModel model) => model.scaleBackground);
    final scaleAll = context.select((ClimaxViewModel model) => model.scaleAll);
    final Offset deltaTranslateBackground = context.select((ClimaxViewModel model) => model.deltaTranslateBackground);
    final bool isTranslating = context.select((ClimaxViewModel model) => model.isTranslating);
    newDeltaTranslateAll = context.select((ClimaxViewModel model) => model.deltaTranslateAll);
    _updateTranslateAnimation();
    return Transform.translate(
      offset: isTranslating ? -newDeltaTranslateAll : -Offset(_offsetXAnimation.value, _offsetYAnimation.value),
      child: Transform.scale(
        scale: scaleAll,
        child: Stack(fit: StackFit.expand, children: [
          Transform.translate(
              offset: -deltaTranslateBackground,
              child: Transform.scale(scale: scaleBackground, child: ImageDisplay(widget.file))),
          Container(color: Colors.transparent, child: Climax()),
        ]),
      ),
    );
  }
}
