import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/widgets/image_picker/asset_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum SelectedImageSource { ASSET, CAMERA, GALLERY }

extension SelectedImageSourceExtension on SelectedImageSource {
  String toValueString() {
    String string = this.toString().substring(this.runtimeType.toString().length + 1);
    return string.substring(0, 1) + string.substring(1).toLowerCase();
  }
}

class ImagePickerDialog extends StatefulWidget {
  final Wall wall;

  ImagePickerDialog(this.wall);

  @override
  _ImagePickerDialogState createState() => _ImagePickerDialogState();

  static Future<String> showImagePickerDialog(BuildContext context, {Wall wall}) async {
    return await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: wall == null ? Text("New image") : Text("Edit image"),
              content: ImagePickerDialog(wall),
            ));
  }
}

class _ImagePickerDialogState extends State<ImagePickerDialog> {
  final ImagePicker picker = ImagePicker();

  SelectedImageSource _selectedSource = SelectedImageSource.ASSET;

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(source: imageSource);
    if (pickedFile != null) {
      Navigator.pop(context, pickedFile.path);
    } else {
      print('No image selected.');
    }
  }

  Future getImageFromAssets() async {
    final pickedFilePath =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AssetImagePicker())) as String;
    if (pickedFilePath != null) {
      Navigator.pop(context, pickedFilePath);
    } else {
      print('No image selected.');
    }
  }

  _handleRadioChange(SelectedImageSource value) {
    setState(() {
      _selectedSource = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Choose the source of the image:",
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ),
          RadioListTile(
              title: Text(SelectedImageSource.ASSET.toValueString()),
              value: SelectedImageSource.ASSET,
              groupValue: _selectedSource,
              onChanged: _handleRadioChange),
          RadioListTile(
              title: Text(SelectedImageSource.CAMERA.toValueString()),
              value: SelectedImageSource.CAMERA,
              groupValue: _selectedSource,
              onChanged: _handleRadioChange),
          RadioListTile(
              title: Text(SelectedImageSource.GALLERY.toValueString()),
              value: SelectedImageSource.GALLERY,
              groupValue: _selectedSource,
              onChanged: _handleRadioChange),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => Navigator.pop(context)),
              ElevatedButton(
                  child: Text('Pick image'),
                  onPressed: () {
                    switch (_selectedSource) {
                      case SelectedImageSource.ASSET:
                        getImageFromAssets();
                        break;
                      case SelectedImageSource.CAMERA:
                        getImage(ImageSource.camera);
                        break;
                      case SelectedImageSource.GALLERY:
                        getImage(ImageSource.gallery);
                        break;
                    }
                  })
            ],
          )
        ],
      ),
    ));
  }
}
