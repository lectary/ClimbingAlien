import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/route_viewmodel.dart';
import 'package:climbing_alien/views/route_editor/route_editor_screen.dart';
import 'package:climbing_alien/views/route_management/route_form.dart';
import 'package:climbing_alien/views/route_viewer/route_viewer.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';

class RouteScreen extends StatelessWidget {
  final Wall wall;

  RouteScreen(this.wall);

  @override
  Widget build(BuildContext context) {
    final routeModel = Provider.of<RouteViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("${wall.title} - Routes"),
      ),
      body: StreamBuilder<List<Route>>(
        stream: routeModel.routeStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final routeList = snapshot.data;
            return routeList.isEmpty
                ? Center(child: Text("No routes available"))
                : ListView.builder(
                    itemCount: routeList.length,
                    itemBuilder: (context, index) {
                      final route = routeList[index];
                      return ListTile(
                        title: Text(route.title),
                        subtitle: Text("${route.description} - ${route.graspList.length} Grasps"),
                        trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RouteEditorScreen(wall, route, key: UniqueKey())))),
                        onLongPress: () => RouteForm.showRouteFormDialog(context, route: route, wallId: wall.id),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RouteViewer(wall, route, key: UniqueKey()))),
                      );
                    });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => RouteForm.showRouteFormDialog(context, wallId: wall.id),
      ),
    );
  }
}
