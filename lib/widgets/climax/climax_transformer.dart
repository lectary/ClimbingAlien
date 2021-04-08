import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/views/route_editor/route_editor_viewmodel.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        .animate(CurvedAnimation(parent: _animationXController, curve: Curves.fastOutSlowIn))
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
    final isEditMode = Provider.of<RouteEditorViewModel>(context, listen: false).editMode;
    final Offset climaxCenter = Provider.of<ClimaxViewModel>(context, listen: false).climaxCenter;
    final Offset screenCenter = Provider.of<ClimaxViewModel>(context, listen: false).screenCenter;
    return Container(
      color: Colors.green,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          if (!isEditMode) return;
          final offset = details.localPosition;
          final limb = limbs!.entries.lastWhereOrNull((entry) {
            if (entry.key != ClimaxLimbEnum.BODY) {
              final Offset climaxCenter = Provider.of<ClimaxViewModel>(context, listen: false).climaxCenter;
              final Offset screenCenter = Provider.of<ClimaxViewModel>(context, listen: false).screenCenter;
              final Size size = MediaQuery.of(context).size;
              final double scaleAll = Provider.of<ClimaxViewModel>(context, listen: false).scaleAll;
              final Offset deltaTranslateAll = Provider.of<ClimaxViewModel>(context, listen: false).deltaTranslateAll;
              // Due to the adjustments of followerCamera, its offset has to be added to the tap position, since the
              // positions (offsets) of the grasps are saved before applying the followerCamera related transformations.
              final scaleDiff = (screenCenter - (screenCenter * scaleAll));
              Offset relativeTapPosition = offset + followerCameraOffset * scaleAll;
              late double dx;
              late double dy;
              // Calculating the ratio of the limbs' distance to the center compared to half of the screen size, which yields
              // the ratio how much scaling affects this limb, i.e. nearer elements to the scaling center are scaled lesser, than
              // values more far away.
              double ratioX = (entry.value.center.dx - screenCenter.dx).abs() / screenCenter.dx;
              double ratioY = (entry.value.center.dy - screenCenter.dy).abs() / screenCenter.dy;
              if (relativeTapPosition.dx > screenCenter.dx) {
                dx = relativeTapPosition.dx + (scaleDiff.dx * ratioX);
              }
              if (relativeTapPosition.dx < screenCenter.dx) {
                dx = relativeTapPosition.dx - (scaleDiff.dx * ratioX);
              }
              if (relativeTapPosition.dy > screenCenter.dy) {
                dy = relativeTapPosition.dy + (scaleDiff.dy * ratioY);
              }
              if (relativeTapPosition.dy < screenCenter.dy) {
                dy = relativeTapPosition.dy - (scaleDiff.dy * ratioY);
              }
              return entry.value.contains(Offset(dx, dy));
            }
            return false;
          });
          if (limb != null) Provider.of<ClimaxViewModel>(context, listen: false).selectLimb(limb.key);
        },
        child: Transform.scale(
          scale: isScaling || isTranslating ? newScaleAll : followerCameraScale,
          child: Transform.translate(
            offset: isTranslating || isScaling ? -newDeltaTranslateAll : -followerCameraOffset,
            child: Container(
              color: Colors.lightBlue,
              child: Stack(fit: StackFit.expand, children: [
                // Transform.translate(
                //     offset: -deltaTranslateBackground,
                //     child: Transform.scale(scale: scaleBackground, child: ImageDisplay(widget.background))),
                Container(color: Colors.transparent, child: Climax()),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
