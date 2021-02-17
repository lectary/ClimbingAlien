import 'dart:io';

import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/viewmodels/image_view_model.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteEditor extends StatefulWidget {
  @override
  _RouteEditorState createState() => _RouteEditorState();
}

class _RouteEditorState extends State<RouteEditor> {
  ImageViewModel model;
  String backgroundImagePath;
  ClimaxViewModel climaxModel;

  Widget backgroundWidget;
  Image image = Image.asset("assets/images/routes/route1.png");

  @override
  void initState() {
    super.initState();
    climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    backgroundImagePath = context.select((ImageViewModel model) => model.currentImagePath);
    final backgroundSelected = context.select((ClimaxViewModel model) => model.backgroundSelected);
    final scaleBackground = context.select((ClimaxViewModel model) => model.scaleBackground);
    final translateX = context.select((ClimaxViewModel model) => model.translateX);
    backgroundWidget = Transform.translate(
        offset: Offset(translateX, 0), child: Transform.scale(scale: scaleBackground, child: image));
    return Stack(fit: StackFit.expand, children: [
      _buildBackgroundImage(),
      GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              if (backgroundSelected) {
                climaxModel.scaleBackground += details.delta.dx / 100;
              } else {
                climaxModel.scaleClimax += details.delta.dx / 100;
              }
            });
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            setState(() {
              if (backgroundSelected) {
                climaxModel.translateX += details.delta.dx;
              }
            });
          },
          onTapDown: (details) {
            // RenderBox box = context.findRenderObject();
            // print("Local Offset: ${details.localPosition}");
            // final offset = box.localToGlobal(details.localPosition);
            // print("Global Offset: $offset");
            setState(() {
              if (!backgroundSelected) {
                climaxModel.updateSelectedLimbPosition(details.localPosition);
              }
            });
          },
          child: Container(color: Colors.transparent, child: Climax())),
    ]);
  }

  Widget _buildBackgroundImage() {
    return backgroundImagePath == null
        ? backgroundWidget
        : FittedBox(fit: BoxFit.fill, child: Image.file(File(backgroundImagePath)));
  }
}
