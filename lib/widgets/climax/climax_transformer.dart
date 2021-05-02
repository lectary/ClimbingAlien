import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/views/route_editor/route_editor_viewmodel.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Widget responsible for applying transformations like translation or scaling to Climax as well as handling Climax' limb selection.
/// Further contains animations to apply transformations gradually instead of instantly.
class ClimaxTransformer extends StatefulWidget {
  /// File path of the image that should be used as background
  final String? background;

  const ClimaxTransformer({
    Key? key,
    required this.background,
  }) : super(key: key);

  @override
  _ClimaxTransformerState createState() => _ClimaxTransformerState();
}

class _ClimaxTransformerState extends State<ClimaxTransformer> with TickerProviderStateMixin {
  // Translations
  late AnimationController _animationXController;
  late AnimationController _animationYController;
  late Animation<double> _offsetXAnimation;
  late Animation<double> _offsetYAnimation;
  Offset deltaTranslateAll = Offset.zero;
  Offset newDeltaTranslateAll = Offset.zero;

  // Scaling
  late AnimationController _animationScaleController;
  late Animation<double> _scaleAnimation;
  double scaleAll = 1;
  double newScaleAll = 1;

  bool init = true;

  @override
  void initState() {
    super.initState();
    _animationXController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animationYController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animationScaleController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _updateTranslateAnimation();
    _updateScaleAnimation();
    init = false;
  }

  @override
  void dispose() {
    _animationXController.dispose();
    _animationYController.dispose();
    _animationScaleController.dispose();
    super.dispose();
  }

  _updateScaleAnimation() {
    if (scaleAll == newScaleAll && !init) {
      return;
    }

    _animationScaleController.reset();

    _scaleAnimation = Tween<double>(begin: scaleAll, end: newScaleAll)
        .animate(CurvedAnimation(parent: _animationScaleController, curve: Curves.fastOutSlowIn))
          ..addListener(() {
            setState(() {});
          });

    _animationScaleController.forward();

    scaleAll = newScaleAll;
  }

  _updateTranslateAnimation() {
    if (deltaTranslateAll == newDeltaTranslateAll && !init) {
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
    final Offset deltaTranslateBackground = context.select((ClimaxViewModel model) => model.deltaTranslateBackground);
    // Used for disabling animations temporarily
    final bool isTranslating = context.select((ClimaxViewModel model) => model.isTranslating);
    final bool isScaling = context.select((ClimaxViewModel model) => model.isScaling);

    // >>> Run translationAnimation before scalingAnimation, otherwise some weird frame jumping occurs!
    // Translation
    newDeltaTranslateAll = context.select((ClimaxViewModel model) => model.deltaTranslateAll);
    _updateTranslateAnimation();
    final followerCameraOffset = Offset(_offsetXAnimation.value, _offsetYAnimation.value);

    // Scaling
    newScaleAll = context.select((ClimaxViewModel model) => model.scaleAll);
    _updateScaleAnimation();
    final followerCameraScale = _scaleAnimation.value;

    final limbs = context.select((ClimaxViewModel model) => model.climaxLimbs);
    // Check whether view or edit mode
    final initMode = Provider.of<RouteEditorViewModel>(context, listen: false).initMode;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        if (initMode) return;
        final offset = details.localPosition;
        final limb = limbs!.entries.lastWhereOrNull((entry) {
          if (entry.key != ClimaxLimbEnum.BODY) {
            final Offset climaxCenter = Provider.of<ClimaxViewModel>(context, listen: false).climaxCenter;
            final double scaleAll = Provider.of<ClimaxViewModel>(context, listen: false).scaleAll;
            final Offset deltaTranslateAll = Provider.of<ClimaxViewModel>(context, listen: false).deltaTranslateAll;

            // TODO review and fix
            // Trying to inverse the translation and scaling of the screen.
            // Starting by the gestures tap offset, add the global translation and divide throught the global scale.
            // Because scaling is applied from the screen center, translate everything to the origin before scaling,
            // and back after.
            // This approach is kinda suitable for the use cases, but is not totally correct! There is a slight error
            // in the position calculation.
            Offset relativeTapPosition = ((offset + deltaTranslateAll - climaxCenter) / scaleAll) + climaxCenter;

            return entry.value.contains(relativeTapPosition);
          }
          return false;
        });
        if (limb != null) Provider.of<ClimaxViewModel>(context, listen: false).selectLimb(limb.key);
      },
      child: Transform.scale(
        scale: isScaling || isTranslating ? newScaleAll : followerCameraScale,
        child: Transform.translate(
          offset: isTranslating || isScaling ? -newDeltaTranslateAll : -followerCameraOffset,
          child: Stack(fit: StackFit.expand, children: [
            Transform.translate(
                offset: -deltaTranslateBackground,
                child: Transform.scale(scale: scaleBackground, child: ImageDisplay(widget.background))),
            Container(color: Colors.transparent, child: Climax()),
          ]),
        ),
      ),
    );
  }
}
