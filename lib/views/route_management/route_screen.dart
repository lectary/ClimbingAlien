import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
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
        child: Builder(
          builder: (context) => StreamBuilder<List<Route>>(
            stream: Provider.of<RouteViewModel>(context, listen: false).routeStream,
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
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChangeNotifierProvider(
                                            create: (context) => ClimaxViewModel(),
                                            child: RouteEditorScreen(wall, route, key: UniqueKey()))))),
                            onLongPress: () => RouteForm.showRouteFormDialog(context, route: route, wallId: wall.id),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChangeNotifierProvider(
                                        create: (context) => ClimaxViewModel(),
                                        child: RouteViewerScreen(wall, route, key: UniqueKey())))),
                          );
                        });
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => RouteForm.showRouteFormDialog(context, wallId: wall.id),
      ),
    );
  }
}
