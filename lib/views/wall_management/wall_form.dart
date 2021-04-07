import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/utils/utils.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/wall_management/wall_form_viewmodel.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:climbing_alien/widgets/image_picker/simple_image_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class WallForm extends StatefulWidget {
  final Wall? wall;

  WallForm(this.wall);

  @override
  _WallFormState createState() => _WallFormState();

  static Future<bool?> showWallFormDialog(BuildContext context, {Wall? wall}) async {
    final model = Provider.of<WallViewModel>(context, listen: false);
    final repo = Provider.of<ClimbingRepository>(context, listen: false);
    return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ChangeNotifierProvider(
              create: (context) => WallFormViewModel(climbingRepository: repo),
              child: ChangeNotifierProvider.value(
                value: model,
                child: AlertDialog(
                  title: wall == null ? Text("New wall") : Text("Edit wall"),
                  content: WallForm(wall),
                ),
              ),
            ));
  }
}

class _WallFormState extends State<WallForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingControllerImagePath = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _locationTextEditingController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _suggestions = List.empty();

  late WallViewModel wallViewModel;
  late bool edit;

  String? title;
  String? description;
  String? location;
  String? filePath;

  @override
  void initState() {
    super.initState();
    wallViewModel = Provider.of<WallViewModel>(context, listen: false);
    _focusNode.requestFocus();
    edit = widget.wall != null;
    title = widget.wall?.title;
    description = widget.wall?.description;
    _locationTextEditingController.text = widget.wall?.location ?? "";
    filePath = widget.wall?.filePath;
    _textEditingControllerImagePath.text = Utils.getEncodedName(filePath ?? "");

    _locationFocusNode.addListener(() {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        if (_locationFocusNode.hasFocus) {
          final practiseModel = Provider.of<WallFormViewModel>(context, listen: false);
          _overlayEntry = _buildSuggestionOverlay(practiseModel);
          Overlay.of(context)?.insert(_overlayEntry!);
        } else {
          _overlayEntry?.remove();
        }
      });
    });
  }

  OverlayEntry _buildSuggestionOverlay(WallFormViewModel wallFormViewModel) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    return OverlayEntry(builder: (context) {
      return ChangeNotifierProvider.value(
        value: wallFormViewModel,
        child: Builder(
          builder: (context) {
            _suggestions = context.select((WallFormViewModel model) => model.suggestions);
            return Positioned(
                width: size.width,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, 48 + 5.0),
                  child: Material(
                    elevation: 4.0,
                    child: _suggestions.isEmpty
                        ? Center(child: Text("No suggestions"))
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_suggestions[index]),
                                onTap: () {
                                  _locationTextEditingController.text = _suggestions[index];
                                  _locationFocusNode.unfocus();
                                },
                              );
                            },
                          ),
                  ),
                ));
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallFormViewModel = Provider.of<WallFormViewModel>(context, listen: false);
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
                if (value!.isEmpty) {
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
            CompositedTransformTarget(
              link: _layerLink,
              child: TextFormField(
                controller: _locationTextEditingController,
                focusNode: _locationFocusNode,
                onChanged: (value) => wallFormViewModel.getSuggestionsByString(value),
                decoration: InputDecoration(labelText: "Location"),
                onSaved: (value) {
                  if (value!.isNotEmpty) {
                    location = value;
                  }
                },
              ),
            ),
            TextFormField(
              controller: _textEditingControllerImagePath,
              decoration: InputDecoration(labelText: "Image - Click me"),
              readOnly: true,
              onTap: () async {
                String? newPath = await SimpleImagePicker.dialog(context);
                if (newPath != null) {
                  setState(() {
                    filePath = newPath;
                    _textEditingControllerImagePath.text = Utils.getEncodedName(filePath!);
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ImageDisplay(filePath),
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
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (edit) {
                            widget.wall!.title = title!;
                            widget.wall!.description = description;
                            widget.wall!.location = location;
                            widget.wall!.filePathUpdated = filePath;
                            wallViewModel.updateWall(widget.wall!);
                          } else {
                            Wall wall = Wall(title: title!, description: description, location: location, filePathUpdated: filePath);
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
