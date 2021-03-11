import 'package:climbing_alien/data/entity/grasp.dart';
import 'package:climbing_alien/data/entity/route.dart';
import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/widgets/climax/climax.dart';
import 'package:climbing_alien/widgets/image_display.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';

class RouteViewerScreen extends StatefulWidget {
  static const String routeName = "/routeViewer";

  final Wall wall;
  final Route route;

  RouteViewerScreen(this.wall, this.route, {Key key}) : super(key: key);

  @override
  _RouteViewerScreenState createState() => _RouteViewerScreenState();
}

class _RouteViewerScreenState extends State<RouteViewerScreen> {
  List<Grasp> _graspList = List.empty();
  Grasp _currentGrasp;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _graspList = widget.route.graspList;
    _graspList.sort((g1, g2) => g1.order - g2.order);
    _currentGrasp = _graspList.isNotEmpty ? _graspList?.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Viewer'),
      ),
      body: _graspList.isEmpty
          ? Center(child: Text('No grasps available'))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Builder(builder: (context) {
                          climaxModel.setupByGrasp(_currentGrasp);
                          WidgetsBinding.instance.addPostFrameCallback((_) {});
                          final scaleBackground = context.select((ClimaxViewModel model) => model.scaleBackground);
                          final scaleAll = context.select((ClimaxViewModel model) => model.scaleAll);
                          final Offset deltaTranslateBackground =
                              context.select((ClimaxViewModel model) => model.deltaTranslateBackground);
                          final Offset deltaTranslateAll =
                              context.select((ClimaxViewModel model) => model.deltaTranslateAll);
                          return Transform.translate(
                            offset: -deltaTranslateAll,
                            child: Transform.scale(
                              scale: scaleAll,
                              child: Stack(fit: StackFit.expand, children: [
                                Transform.translate(
                                    offset: -deltaTranslateBackground,
                                    child: Transform.scale(
                                        scale: scaleBackground, child: ImageDisplay(widget.wall.imagePath))),
                                Container(color: Colors.transparent, child: Climax()),
                              ]),
                            ),
                          );
                        }),
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ButtonBar(
                            alignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (index > 0) {
                                        _currentGrasp = _graspList[index--];
                                      }
                                    });
                                  },
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
                                  onPressed: () {
                                    setState(() {
                                      if (index < _graspList.length - 1) {
                                        _currentGrasp = _graspList[index++];
                                      }
                                    });
                                  },
                                  child: Text("+"))
                            ],
                          ))
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
