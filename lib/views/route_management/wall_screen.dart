import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/route_management/route_screen.dart';
import 'package:climbing_alien/views/route_management/wall_form.dart';
import 'package:climbing_alien/widgets/image_picker/image_picker_dialog.dart';
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
                      return ListTile(
                        title: Text(wall.title),
                        subtitle: Text(wall.description),
                        onTap: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RouteScreen(wall))),
                        onLongPress: () => WallForm.showWallFormDialog(context, wall: wall),
                      );
                    });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        // onPressed: () => WallForm.showWallFormDialog(context),
        onPressed: () => ImagePickerDialog.showImagePickerDialog(context),
      ),
    );
  }
}
