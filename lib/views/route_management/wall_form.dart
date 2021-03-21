import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/utils/utils.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:climbing_alien/widgets/image_picker/simple_image_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WallForm extends StatefulWidget {
  final Wall wall;

  WallForm(this.wall);

  @override
  _WallFormState createState() => _WallFormState();

  static Future<bool> showWallFormDialog(BuildContext context, {Wall wall}) async {
    final model = Provider.of<WallViewModel>(context, listen: false);
    return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ChangeNotifierProvider.value(
              value: model,
              child: AlertDialog(
                title: wall == null ? Text("New wall") : Text("Edit wall"),
                content: WallForm(wall),
              ),
            ));
  }
}

class _WallFormState extends State<WallForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingControllerImagePath = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  WallViewModel wallViewModel;
  bool edit;

  String title;
  String description;
  String imagePath;

  @override
  void initState() {
    super.initState();
    wallViewModel = Provider.of<WallViewModel>(context, listen: false);
    // _focusNode.requestFocus();
    edit = widget.wall != null;
    title = widget.wall?.title;
    description = widget.wall?.description;
    imagePath = widget.wall?.file;
    _textEditingControllerImagePath.text = Utils.getFilenameFromPath(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: title,
              focusNode: _focusNode,
              decoration: InputDecoration(labelText: "Title"),
              validator: (value) {
                if (value.isEmpty) {
                  return "Title is mandatory!";
                }
                return null;
              },
              onSaved: (value) => title = value,
            ),
            TextFormField(
              initialValue: description,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(labelText: "Description"),
              onSaved: (value) => description = value,
            ),
            TextFormField(
              controller: _textEditingControllerImagePath,
              decoration: InputDecoration(labelText: "Image - Click me"),
              readOnly: true,
              onTap: () async {
                String newPath = await SimpleImagePicker.dialog(context);
                if (newPath != null) {
                  setState(() {
                    imagePath = newPath;
                    _textEditingControllerImagePath.text = Utils.getFilenameFromPath(newPath);
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ImageDisplay(imagePath),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      child: Text("Cancel"),
                      style: ElevatedButton.styleFrom(primary: Theme.of(context).colorScheme.error),
                      onPressed: () => Navigator.pop(context)),
                  ElevatedButton(
                      child: Text("Save"),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          if (edit) {
                            widget.wall.title = title;
                            widget.wall.description = description;
                            widget.wall.fileUpdated = imagePath;
                            wallViewModel.updateWall(widget.wall);
                          } else {
                            Wall wall = Wall(title, description: description, file: imagePath);
                            wallViewModel.insertWall(wall);
                          }
                          Navigator.pop(context);
                        }
                      })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
