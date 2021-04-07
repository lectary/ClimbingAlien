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
  late AnimationController _animationXController;
  late AnimationController _animationYController;
  late Animation<double> _offsetXAnimation;
  late Animation<double> _offsetYAnimation;

  Offset deltaTranslateAll = Offset.zero;
  Offset newDeltaTranslateAll = Offset.zero;

  bool init = true;

  @override
  void initState() {
    super.initState();
    _animationXController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animationYController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _updateTranslateAnimation();
    init = false;
  }

  @override
  void dispose() {
    _animationXController.dispose();
    _animationYController.dispose();
    super.dispose();
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
    final scaleAll = context.select((ClimaxViewModel model) => model.scaleAll);
    final Offset deltaTranslateBackground = context.select((ClimaxViewModel model) => model.deltaTranslateBackground);
    final bool isTranslating = context.select((ClimaxViewModel model) => model.isTranslating);
    newDeltaTranslateAll = context.select((ClimaxViewModel model) => model.deltaTranslateAll);
    _updateTranslateAnimation();
    final limbs = context.select((ClimaxViewModel model) => model.climaxLimbs);
    final followerCameraOffset = Offset(_offsetXAnimation.value, _offsetYAnimation.value);
    // Check whether view or edit mode
    final isEditMode = Provider.of<RouteEditorViewModel>(context, listen: false).editMode;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        if (!isEditMode) return;
        final offset = details.localPosition;
        final limb = limbs!.entries.lastWhereOrNull((entry) {
          if (entry.key != ClimaxLimbEnum.BODY) {
            // Due to the adjustments of followerCamera, its offset has to be added to the tap position, since the
            // positions (offsets) of the grasps are saved before applying the followerCamera related transformations.
            return entry.value.contains(offset + followerCameraOffset);
          }
          return false;
        });
        if (limb != null) Provider.of<ClimaxViewModel>(context, listen: false).selectLimb(limb.key);
      },
      child: Transform.scale(
        scale: scaleAll,
        child: Transform.translate(
          offset: isTranslating ? -newDeltaTranslateAll : -followerCameraOffset,
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
