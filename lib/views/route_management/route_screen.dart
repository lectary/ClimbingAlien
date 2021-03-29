import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/route_viewmodel.dart';
import 'package:climbing_alien/views/route_editor/route_editor_screen.dart';
import 'package:climbing_alien/views/route_management/route_form.dart';
import 'package:climbing_alien/views/route_viewer/route_viewer_screen.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';

class RouteScreen extends StatelessWidget {
  final Wall wall;

  RouteScreen(this.wall);

  @override
  Widget build(BuildContext context) {
    final climbingRepository = Provider.of<ClimbingRepository>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("${wall.title} - Routes"),
      ),
      body: ChangeNotifierProvider(
        create: (context) => RouteViewModel(climbingRepository: climbingRepository),
        child: Consumer<RouteViewModel>(
          builder: (context, routeModel, child) {
            return StreamBuilder<List<Route>>(
              stream: routeModel.getRouteStreamByWallId(wall.id!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final routeList = snapshot.data!;
                  return routeList.isEmpty
                      ? Center(child: Text("No routes available"))
                      : ListView.builder(
                          itemCount: routeList.length,
                          itemBuilder: (context, index) {
                            final route = routeList[index];
                            return ListTile(
                              title: Text(route.title),
                              subtitle: StreamBuilder<List<Grasp>>(
                                  stream: routeModel.getGraspStreamByRouteId(route.id!),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final graspList = snapshot.data!;
                                      return Text("${route.description} - ${graspList.length} Grasps");
                                    } else {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                  }),
                              trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RouteEditorScreen(wall, route, key: UniqueKey())))),
                              onLongPress: () => RouteForm.showRouteFormDialog(context, wall, route: route),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RouteViewerScreen(wall, route, key: UniqueKey()))),
                            );
                          });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => RouteForm.showRouteFormDialog(context, wall),
      ),
    );
  }
}
