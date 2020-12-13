import 'dart:io';

import 'package:climbing_alien/viewmodels/image_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DisplayImageScreen extends StatelessWidget {
  final String imagePath;

  DisplayImageScreen(this.imagePath);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ImageViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(

      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(imagePath)),
            fit: BoxFit.fill
          )
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 1) {
            model.saveImage(imagePath);
          }
          Navigator.pop(context);
        },
        items: [
          BottomNavigationBarItem(
            label: "Cancel",
            icon: Icon(Icons.cancel)
          ),
          BottomNavigationBarItem(
              label: "Ok",
              icon: Icon(Icons.check)
          ),
        ],
      ),
    );
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.end,
    //   children: [
    //     Image.file(File(imagePath)),
    //     Row(
    //       children: [
    //         IconButton(
    //           icon: Icon(Icons.clear),
    //           onPressed: () {
    //             Navigator.pop(context);
    //           },
    //         ),
    //         IconButton(
    //           icon: Icon(Icons.check),
    //           onPressed: () {
    //             Navigator.pop(context);
    //           },
    //         ),
    //       ],
    //     )
    //   ]
    // );
  }
}
