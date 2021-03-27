import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/viewmodels/route_viewmodel.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';

class RouteForm extends StatefulWidget {
  final Route? route;
  final int? wallId;

  RouteForm(this.route, this.wallId);

  @override
  _RouteFormState createState() => _RouteFormState();

  static Future<bool?> showRouteFormDialog(BuildContext context, {Route? route, int? wallId}) async {
    assert(route != null ? wallId != null : true);
    final model = Provider.of<ClimbingRepository>(context, listen: false);
    return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ChangeNotifierProvider(
              create: (context) => RouteViewModel(climbingRepository: model),
              child: AlertDialog(
                title: route == null ? Text("New route") : Text("Edit route"),
                content: RouteForm(route, wallId),
              ),
            ));
  }
}

class _RouteFormState extends State<RouteForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  late RouteViewModel routeViewModel;
  late bool edit;

  String? title;
  String? description;

  @override
  void initState() {
    super.initState();
    routeViewModel = Provider.of<RouteViewModel>(context, listen: false);
    _focusNode.requestFocus();
    edit = widget.route != null;
    title = widget.route?.title;
    description = widget.route?.description;
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
            decoration: InputDecoration(hintText: "Title"),
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
            decoration: InputDecoration(hintText: "Description"),
            onSaved: (value) => description = value,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
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
                          widget.route!.title = title!;
                          widget.route!.description = description;
                          routeViewModel.updateRoute(widget.route!);
                        } else {
                          Route route = Route(
                            title!,
                            widget.wallId!,
                            description: description,
                          );
                          routeViewModel.insertRoute(route);
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
