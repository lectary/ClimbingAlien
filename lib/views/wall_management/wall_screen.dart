import 'package:carousel_slider/carousel_slider.dart';
import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/model/location.dart';
import 'package:climbing_alien/model/model_state.dart';
import 'package:climbing_alien/shared/wall_viewmodel.dart';
import 'package:climbing_alien/views/wall_management/wall_card.dart';
import 'package:climbing_alien/views/wall_management/wall_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Screen for [Wall] management.
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
              actions: [IconButton(icon: Icon(Icons.add), onPressed: () => WallForm.asDialog(context))],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                // By using a async block without returning the future from the function, the LoadingIndicator from the
                // RefreshIndicator returns immediately. This is intended since another LoadingIndicator is already provided.
                Provider.of<WallViewModel>(context, listen: false).loadAllWalls();
              },
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewportConstraints) => SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Builder(
                      builder: (context) {
                        switch (modelState.status) {
                          case Status.loading:
                            return _buildLoadingState(modelState.message);
                          case Status.completed:
                            return _buildCompletedState(size, viewportConstraints);
                          case Status.error:
                            return _buildErrorState(modelState.message);
                        }
                      },
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Column _buildLoadingState(String? loadingMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        loadingMessage == null
            ? Container()
            : Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(loadingMessage),
                ),
              ),
        Center(child: CircularProgressIndicator())
      ],
    );
  }

  /// Second selector for the locationList directly, to react to wall list updates (add, remove) or other actions like sorting
  /// Those changes are displayed as soon as they finished, no need for a loading indicator
  Selector<WallViewModel, List<Location>> _buildCompletedState(Size size, BoxConstraints viewportConstraints) {
    return Selector<WallViewModel, List<Location>>(
      selector: (context, model) => model.locationList,
      shouldRebuild: (oldValue, newValue) => oldValue != newValue,
      builder: (context, locations, child) {
        final List<Widget> bodyWidgets = [];
        if (Provider.of<WallViewModel>(context, listen: false).offlineMode) {
          bodyWidgets.add(Container(
            color: Theme.of(context).colorScheme.error,
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("No Internet connection!", style: TextStyle(color: Theme.of(context).colorScheme.onError)),
                Text(
                  "OFFLINE MODE",
                  style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onError),
                ),
              ],
            ),
          ));
        }
        bodyWidgets.add(locations.isEmpty
            ? Expanded(child: Center(child: Text("No walls available")))
            : LocationPanelList(locations, size));
        return Container(
          // Using a container with `viewportConstraints.maxHeight` to be able to use [Expanded] widget in the column in case of OfflineMode and empty wall list.
          // Otherwise the height is not constrained and [Expanded] cannot be used.
          height: Provider.of<WallViewModel>(context, listen: false).offlineMode ? viewportConstraints.maxHeight : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: bodyWidgets,
          ),
        );
      },
    );
  }

  Center _buildErrorState(String? errorMessage) {
    return errorMessage == null
        ? Center(child: Text("Unknown error occurred.", textAlign: TextAlign.center))
        : Center(child: Text(errorMessage, textAlign: TextAlign.center));
  }
}

/// Custom widget using [ExpansionPanelList] for building a list of [ExpansionPanelRadio] of a list of [Wall] grouped by [Wall.location].
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
    // TODO review and maybe rebuild [ExpansionPanelList] to [ListView] combined with [ExpansionTile]s, since [ExpansionPanelList] seems not to use any builder and
    // TODO therefore may not have a good performance with long lists.
    return ExpansionPanelList.radio(
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
    );
  }
}
