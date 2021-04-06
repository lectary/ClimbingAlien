import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/widgets/unused/image_picker/asset_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SimpleImagePicker extends StatelessWidget {
  final Wall? wall;
  final ImagePicker picker = ImagePicker();

  SimpleImagePicker(this.wall);

  static Future<String?> dialog(BuildContext context, {Wall? wall}) async {
    return await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: wall == null ? Text("New image") : Text("Edit image"),
              content: SimpleImagePicker(wall),
            ));
  }

  Future getImage(BuildContext context, ImageSource imageSource) async {
    final pickedFile = await picker.getImage(source: imageSource);
    if (pickedFile != null) {
      Navigator.pop(context, pickedFile.path);
    } else {
      print('No image selected.');
    }
  }

  Future getImageFromAssets(
    BuildContext context,
  ) async {
    final pickedFilePath =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AssetImagePicker())) as String?;
    if (pickedFilePath != null) {
      Navigator.pop(context, pickedFilePath);
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Choose the source of the image:",
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ),
          ListTile(
            leading: Icon(Icons.remove),
            title: Text('Assets'),
            onTap: () => getImageFromAssets(context),
          ),
          ListTile(
            leading: Icon(Icons.remove),
            title: Text('Camera'),
            onTap: () => getImage(context, ImageSource.camera),
          ),
          ListTile(
            leading: Icon(Icons.remove),
            title: Text('Gallery'),
            onTap: () => getImage(context, ImageSource.gallery),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton(
                child: Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.pop(context)),
          )
        ],
      ),
    ));
  }
}
