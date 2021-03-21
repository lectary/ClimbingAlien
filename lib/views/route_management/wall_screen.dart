import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/model/location.dart';
import 'package:climbing_alien/utils/dialogs.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/route_management/route_screen.dart';
import 'package:climbing_alien/views/route_management/wall_form.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WallScreen extends StatefulWidget {
  static String routeName = '/walls';

  @override
  _WallScreenState createState() => _WallScreenState();
}

class _WallScreenState extends State<WallScreen> {
  String selected;

  @override
  Widget build(BuildContext context) {
    final wallModel = Provider.of<WallViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Climbing Walls"),
      ),
      body: StreamBuilder<List<Location>>(
        stream: wallModel.locationStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final locations = snapshot.data;
            return locations.isEmpty
                ? Center(child: Text("No walls available"))
                : _buildLocationsAsExpansionPanelList(context, locations);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => WallForm.showWallFormDialog(context),
      ),
    );
  }

  _buildLocationsAsExpansionPanelList(BuildContext context, List<Location> locations) {
    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        children: locations.map<ExpansionPanelRadio>((Location location) {
          return ExpansionPanelRadio(
              value: location.name ?? "<no-name>",
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(location.name ?? "<no-name>"),
                );
              },
              body: Column(
                children: location.walls.map((Wall wall) => _buildWall(context, wall)).toList(),
              ));
        }).toList(),
      ),
    );
  }

  @deprecated
  _buildLocationsAsExpansionTiles(BuildContext context, List<Location> locations) {
    return ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return ExpansionTile(
              initiallyExpanded: selected == location.name,
              onExpansionChanged: (isExpanding) {
                if (isExpanding) {
                  setState(() {
                    selected = location.name;
                  });
                } else {
                  setState(() {
                    selected = null;
                  });
                }
              },
              title: Text(location.name ?? "<no-name>"),
              children: location.walls.map((Wall wall) => _buildWall(context, wall)).toList());
        });
  }

  Widget _buildWall(BuildContext context, Wall wall) {
    final wallModel = Provider.of<WallViewModel>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: GestureDetector(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            /// Header
            Container(
              color: Colors.grey[300],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(wall.title, style: Theme.of(context).textTheme.headline5),
                        Row(
                          children: [
                            IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                icon: Icon(Icons.edit),
                                onPressed: () => WallForm.showWallFormDialog(context, wall: wall)),
                            IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  bool canDeleteWithoutConflicts = await wallModel.deleteWall(wall);
                                  if (!canDeleteWithoutConflicts) {
                                    await Dialogs.showAlertDialog(
                                        context: context,
                                        title:
                                            'Diese Wand hat bereits Routen gespeichert! Wenn Sie die Wand löschen, werden auch alle Routen gelöscht!',
                                        submitText: 'Löschen',
                                        submitFunc: () => wallModel.deleteWall(wall, cascade: true));
                                  }
                                })
                          ],
                        )
                      ],
                    ),
                    Text(wall.description),
                  ],
                ),
              ),
            ),

            /// Wall image
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: ImageDisplay(
                wall.file,
                emptyText: 'No image',
              )),
            )
          ]),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RouteScreen(wall))),
        ),
      ),
    );
  }
}
