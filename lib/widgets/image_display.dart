import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

/// Displays the image based on its provided [imagePath].
///
/// If [emptyText] is provided and [imagePath] is [Null] or empty, then [emptyText]
/// will be displayed, otherwise a empty [Container].
///
/// The widget checks whether the passed image is from [Assets] or [Files] and displays
/// it appropriate.
///
/// In case the image loading fails, [errorText] will be displayed if passed, otherwise the
/// default text [_errorTextDefault].
class ImageDisplay extends StatelessWidget {
  final String? imagePath;
  final String emptyText;
  final String errorText;
  static const _emptyTextDefault = 'No image set, yet.';
  static const _errorTextDefault = 'Failed to load image 😢';

  ImageDisplay(this.imagePath, {this.emptyText = _emptyTextDefault, this.errorText = _errorTextDefault});

  Widget _errorBuilderFunction(BuildContext context, Object exception, StackTrace? stackTrace) {
    log(exception.toString());
    return Text(errorText);
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return Center(child: Text(emptyText));
    } else {
      return Image.file(File(imagePath!), errorBuilder: _errorBuilderFunction);
    }
  }
}
