import 'dart:io';

import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/viewmodels/image_view_model.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RenderView extends StatefulWidget {
  @override
  _RenderViewState createState() => _RenderViewState();
}

class _RenderViewState extends State<RenderView> {
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
    backgroundWidget = image;
    return Stack(fit: StackFit.expand, children: [
      _buildBackgroundImage(),
      Positioned.fill(
        child: GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                if (backgroundSelected) {
                  climaxModel.scaleClimax += details.delta.dx / 100;
                }
              });
            },
            onTapDown: (details) {
              RenderBox box = context.findRenderObject();
              final offset = box.localToGlobal(details.localPosition);
              setState(() {
                if (!backgroundSelected) {
                  climaxModel.updateSelectedLimbPosition(offset);
                }
              });
            },
            child: Container(color: Colors.transparent, child: Climax())),
      ),
    ]);
  }

  Widget _buildBackgroundImage() {
    return backgroundImagePath == null
        ? backgroundWidget
        : FittedBox(fit: BoxFit.fill, child: Image.file(File(backgroundImagePath)));
  }
}
