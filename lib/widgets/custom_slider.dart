import 'package:flutter/material.dart';

/// A custom slider widget with a top label.
///
/// Uses a normal [Slider] widget but with a custom [RoundedRectSliderTrackShape] to adjust the margin and width of the slider for the app's needs.
class CustomSliderWithLabel extends StatelessWidget {
  final String labelText;
  final double size;
  final double max;
  final double speed;
  final Function onChanged;

  CustomSliderWithLabel(this.size, this.max, this.speed, this.onChanged, {this.labelText = "Slider for speed"});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      ),
      child: Column(
        children: [
          Container(
              child: Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
            child: Text(
              "Movement speed",
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
            ),
          )),
          Container(
            width: size,
            height: 30,
            child: SliderTheme(
              data: SliderThemeData(
                trackShape: CustomTrackShape(),
              ),
              child: Slider(
                activeColor: Theme.of(context).colorScheme.primaryVariant,
                min: 0,
                max: max,
                divisions: 10,
                label: "$speed",
                value: speed,
                onChanged: onChanged as void Function(double)?,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom track shape for Slider, to customize its track width/margin.
class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx + 5;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 10;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
