import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ColorRowPicker extends StatefulWidget {
  @override
  _ColorRowPickerState createState() => _ColorRowPickerState();
}

class _ColorRowPickerState extends State<ColorRowPicker> {
  static const double _colorCircleSize = 36;
  static const double _outerCircleWidth = 4;
  static const double _innerCircleWidth = 3;

  late final ClimaxViewModel climaxModel;

  late Color selectedMainColor;
  late Color selectedGhostingColor;

  @override
  void initState() {
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
    selectedMainColor = climaxModel.climaxMainColor;
    selectedGhostingColor = climaxModel.climaxGhostingColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Main Color"),
        SizedBox(height: 5),
        _buildColorsMain(context),
        SizedBox(height: 15),
        Text("Ghosting Color"),
        SizedBox(height: 5),
        _buildColorsGhosting(context),
      ],
    );
  }

  _buildColorsMain(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ClimaxViewModel.colorsMain
          .map((color) => GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: color,
                        width: _outerCircleWidth,
                      ),
                      color: color,
                      shape: BoxShape.circle),
                  width: _colorCircleSize,
                  height: _colorCircleSize,
                  child: selectedMainColor == color
                      ? Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: _innerCircleWidth,
                              ),
                              color: color,
                              shape: BoxShape.circle),
                          width: _colorCircleSize - 8,
                          height: _colorCircleSize - 8,
                        )
                      : null,
                ),
                onTap: () {
                  setState(() => selectedMainColor = color);
                  Provider.of<ClimaxViewModel>(context, listen: false).climaxMainColor = color;
                },
              ))
          .toList(),
    );
  }

  _buildColorsGhosting(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ClimaxViewModel.colorsGhosting
          .map((color) => GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: color,
                        width: _outerCircleWidth,
                      ),
                      color: color,
                      shape: BoxShape.circle),
                  width: _colorCircleSize,
                  height: _colorCircleSize,
                  child: selectedGhostingColor == color
                      ? Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: _innerCircleWidth,
                              ),
                              color: color,
                              shape: BoxShape.circle),
                          width: _colorCircleSize - 8,
                          height: _colorCircleSize - 8,
                        )
                      : null,
                ),
                onTap: () {
                  setState(() => selectedGhostingColor = color);
                  Provider.of<ClimaxViewModel>(context, listen: false).climaxGhostingColor = color;
                },
              ))
          .toList(),
    );
  }
}
