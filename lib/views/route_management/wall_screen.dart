import 'package:carousel_slider/carousel_slider.dart';
import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/model/location.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/route_management/wall_card.dart';
import 'package:climbing_alien/views/route_management/wall_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WallScreen extends StatelessWidget {
  static String routeName = '/walls';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider<WallViewModel>(
      create: (context) => WallViewModel(climbingRepository: Provider.of<ClimbingRepository>(context, listen: false)),
      // First selector for the general modelState, used for example for re-querying remote list and showing a loading indicator
      child: Selector<WallViewModel, ModelState>(
        selector: (context, model) => model.modelState,
        shouldRebuild: (oldValue, newValue) => oldValue != newValue,
        builder: (context, modelState, child) => Scaffold(
            appBar: AppBar(
              title: Text("Climbing Walls"),
              actions: [IconButton(icon: Icon(Icons.add), onPressed: () => WallForm.showWallFormDialog(context))],
            ),
            body: Builder(
              builder: (context) {
                switch (modelState) {
                  case ModelState.LOADING:
                    return Center(child: CircularProgressIndicator());
                  case ModelState.IDLE:
                    // Second selector for the locationList directly, to react to wall list updates (add, remove) or other actions like sorting
                    // Those changes are displayed as soon as they finished, no need for a loading indicator
                    return Selector<WallViewModel, List<Location>>(
                      selector: (context, model) => model.locationList,
                      shouldRebuild: (oldValue, newValue) => oldValue != newValue,
                      builder: (context, locations, child) {
                        return locations.isEmpty
                            ? Center(child: Text("No walls available"))
                            : LocationPanelList(locations, size);
                      },
                    );
                }
              },
            )),
      ),
    );
  }
}

class LocationPanelList extends StatefulWidget {
  final List<Location> locations;
  final Size size;

  LocationPanelList(this.locations, this.size);

  @override
  _LocationPanelListState createState() => _LocationPanelListState();
}

class _LocationPanelListState extends State<LocationPanelList> {
  // Map for storing whether a location panel is expanded or not
  Map<String, bool> _expandedList = Map();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        expansionCallback: (int panelIndex, bool isExpanded) {
          // Only mark as expanded if null or if callback value and current stored value are false.
          // Read doc of [ExpansionPanelList.expansionCallback] for more details.
          _expandedList.update(widget.locations[panelIndex].name, (expanded) {
            if (!isExpanded && !expanded) {
              return true;
            }
            return false;
          }, ifAbsent: () => true);
        },
        children: widget.locations.map<ExpansionPanelRadio>((Location location) {
          return ExpansionPanelRadio(
            value: location.name,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text("${location.name} - ${location.walls.length} Walls"),
              );
            },
            body: CarouselSlider.builder(
                options: CarouselOptions(
                  height: widget.size.height * 0.5,
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
