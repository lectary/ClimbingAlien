import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  final Color? color;

  ColorPicker(this.color);

  /// Static function for calling [CategoryForm] wrapped in an [AlertDialog].
  static Future<Color?> asDialog(BuildContext context, {Color? color}) async {
    return await showDialog<Color>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Farbe auswählen"),
        content: ColorPicker(color),
      ),
    );
  }

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  final List<Color> _colors = List.of({
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.orange,
    Colors.grey,
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.teal,
  });

  Color? selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colors
              .map((color) => GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: color,
                            width: 4,
                          ),
                          color: color,
                          shape: BoxShape.circle),
                      width: 48,
                      height: 48,
                      child: selectedColor == color
                          ? Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  color: color,
                                  shape: BoxShape.circle),
                              width: 40,
                              height: 40,
                            )
                          : null,
                    ),
                    onTap: () => setState(() => selectedColor = color),
                  ))
              .toList(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.error,
                    onPrimary: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
              Spacer(),
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.pop(context, selectedColor);
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
