import 'package:flutter/material.dart';

class CustomSliderWithLabel extends StatelessWidget {
  final String labelText;
  final double size;
  final double max;
  final double speed;
  final Function onChanged;

  CustomSliderWithLabel(this.size, this.max, this.speed, this.onChanged, {this.labelText = "Slider for speed"});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text("Slider for speed"),
        ),
        Container(
          width: size,
          height: 30,
          child: SliderTheme(
            data: SliderThemeData(
              trackShape: CustomTrackShape(),
            ),
            child: Slider(
              min: 0,
              max: max,
              divisions: 10,
              label: "$speed",
              value: speed,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom track shape for Slider, to customize its track width/margin.
class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx + 5;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 10;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}