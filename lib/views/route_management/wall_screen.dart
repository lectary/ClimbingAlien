import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/route_management/route_screen.dart';
import 'package:climbing_alien/views/route_management/wall_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WallScreen extends StatelessWidget {
  static String routeName = '/walls';

  @override
  Widget build(BuildContext context) {
    final wallModel = Provider.of<WallViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Climbing Walls"),
      ),
      body: StreamBuilder<List<Wall>>(
        stream: wallModel.wallStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final wallList = snapshot.data;
            return wallList.isEmpty
                ? Center(child: Text("Keine Wände vorhanden"))
                : ListView.builder(
                    itemCount: wallList.length,
                    itemBuilder: (context, index) {
                      final wall = wallList[index];
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
                                          IconButton(
                                              padding: EdgeInsets.zero,
                                              visualDensity: VisualDensity.compact,
                                              icon: Icon(Icons.edit),
                                              onPressed: () => WallForm.showWallFormDialog(context, wall: wall))
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
                                child: wall.imagePath == null ? Text('No image') : Image.asset(wall.imagePath),
                              )
                            ]),
                            onTap: () =>
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RouteScreen(wall))),
                          ),
                        ),
                      );
                    });
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
}
