import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:flutter/cupertino.dart';
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
                title: wall == null ? Text("Neue Wand") : Text("Bearbeite Wand"),
                content: WallForm(wall),
              ),
            ));
  }
}

class _WallFormState extends State<WallForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  WallViewModel wallViewModel;
  bool edit;

  String title;
  String description;

  @override
  void initState() {
    super.initState();
    wallViewModel = Provider.of<WallViewModel>(context, listen: false);
    _focusNode.requestFocus();
    edit = widget.wall != null;
    title = widget.wall?.title;
    description = widget.wall?.description;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: title,
            focusNode: _focusNode,
            decoration: InputDecoration(hintText: "Titel"),
            validator: (value) {
              if (value.isEmpty) {
                return "Titel wird benötigt!";
              }
              return null;
            },
            onSaved: (value) => title = value,
          ),
          TextFormField(
            initialValue: description,
            decoration: InputDecoration(hintText: "Beschreibung"),
            onSaved: (value) => description = value,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    child: Text("Abbrechen"),
                    style: ElevatedButton.styleFrom(primary: Theme.of(context).colorScheme.error),
                    onPressed: () => Navigator.pop(context)),
                ElevatedButton(
                    child: Text("Speichern"),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        if (edit) {
                          widget.wall.title = title;
                          widget.wall.description = description;
                          wallViewModel.updateWall(widget.wall);
                        } else {
                          Wall wall = Wall(
                            title,
                            description: description,
                          );
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
    );
  }
}
