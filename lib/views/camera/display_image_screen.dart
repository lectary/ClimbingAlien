import 'dart:io';

import 'package:climbing_alien/viewmodels/image_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DisplayImageScreen extends StatelessWidget {
  final String imagePath;

  DisplayImageScreen(this.imagePath);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ImageViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text("Do you want to save your photo?")),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: FileImage(File(imagePath)),
                fit: BoxFit.fill)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 1) {
            model.saveImage(imagePath);
          }
          Navigator.pop(context);
        },
        items: [
          BottomNavigationBarItem(label: "Cancel", icon: Icon(Icons.cancel)),
          BottomNavigationBarItem(label: "Ok", icon: Icon(Icons.check)),
        ],
      ),
    );
  }
}
