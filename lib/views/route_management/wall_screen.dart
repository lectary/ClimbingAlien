import 'package:carousel_slider/carousel_slider.dart';
import 'package:climbing_alien/model/location.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/route_management/wall_card.dart';
import 'package:climbing_alien/views/route_management/wall_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WallScreen extends StatefulWidget {
  static String routeName = '/walls';

  @override
  _WallScreenState createState() => _WallScreenState();
}

class _WallScreenState extends State<WallScreen> {
  // Map for storing whether a location panel is expanded or not
  Map<String, bool> _expandedList = Map();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final wallModel = Provider.of<WallViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Climbing Walls"),
      ),
      body: FutureBuilder<List<Location>>(
        future: wallModel.loadAllWalls(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final locations = snapshot.data!;
            return locations.isEmpty
                ? Center(child: Text("No walls available"))
                : _buildLocationsAsExpansionPanelList(context, locations, size);
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

  _buildLocationsAsExpansionPanelList(BuildContext context, List<Location> locations, Size size) {
    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        expansionCallback: (int panelIndex, bool isExpanded) {
          // Only mark as expanded if null or if callback value and current stored value are false.
          // Read doc of [ExpansionPanelList.expansionCallback] for more details.
          _expandedList.update(locations[panelIndex].name, (expanded) {
            if (!isExpanded && !expanded) {
              return true;
            }
            return false;
          }, ifAbsent: () => true);
        },
        children: locations.map<ExpansionPanelRadio>((Location location) {
          return ExpansionPanelRadio(
            value: location.name,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(location.name),
              );
            },
            body: CarouselSlider.builder(
                options: CarouselOptions(
                  height: size.height * 0.5,
                  enableInfiniteScroll: false,
                ),
                itemCount: location.walls.length,
                itemBuilder: (context, index, realIndex) =>
                    WallCard(location.walls[index], _expandedList[location.walls[index].location] ?? false)),
          );
        }).toList(),
      ),
    );
  }
}
