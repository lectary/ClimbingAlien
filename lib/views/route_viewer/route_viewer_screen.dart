import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/viewmodels/route_viewmodel.dart';
import 'package:climbing_alien/widgets/climax/climax_transformer.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';

class RouteViewerScreen extends StatefulWidget {
  static const String routeName = "/routeViewer";

  final Wall wall;
  final Route route;

  RouteViewerScreen(this.wall, this.route, {Key? key}) : super(key: key);

  @override
  _RouteViewerScreenState createState() => _RouteViewerScreenState();
}

class _RouteViewerScreenState extends State<RouteViewerScreen> {
  RouteViewModel? routeModel;
  ClimaxViewModel? climaxModel;

  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RouteViewModel(climbingRepository: Provider.of<ClimbingRepository>(context, listen: false)),
      child: ChangeNotifierProvider(
        create: (context) => ClimaxViewModel(),
        child: Consumer2<RouteViewModel, ClimaxViewModel>(
          builder: (context, routeModel, climaxModel, child) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Route Viewer'),
              ),
              body: StreamBuilder<List<Grasp>>(
                  stream: routeModel.getGraspStreamByRouteId(widget.route.id!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final _graspList = snapshot.data!;
                      if (_graspList.isEmpty) {
                        return Center(child: Text('No grasps available'));
                      } else {
                        _graspList.sort((g1, g2) => g1.order! - g2.order!);
                        climaxModel.setupByGrasp(_graspList[index]);
                        return Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClimaxTransformer(imagePath: widget.wall.imagePath),
                                  ),
                                  Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: ButtonBar(
                                        alignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                              onPressed: (index > 0)
                                                  ? () {
                                                      // Double check to avoid invalid executions due button hammering and execution-lag
                                                      if (index <= 0) return;
                                                      setState(() {
                                                        index--;
                                                      });
                                                    }
                                                  : null,
                                              child: Text("-")),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.primary,
                                            ),
                                            onPressed: () {},
                                            child: Text('Grasp ${index + 1} of ${_graspList.length}',
                                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                                          ),
                                          ElevatedButton(
                                              onPressed: (index < _graspList.length - 1)
                                                  ? () {
                                                      // Double check to avoid invalid executions due button hammering and execution-lag
                                                      if (index >= _graspList.length - 1) return;
                                                      setState(() {
                                                        index++;
                                                      });
                                                    }
                                                  : null,
                                              child: Text("+"))
                                        ],
                                      ))
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            );
          },
        ),
      ),
    );
  }
}
