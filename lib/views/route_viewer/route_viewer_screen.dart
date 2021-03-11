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
  ValueNotifier<String> appBarTitleNotifier = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    final climaxModel = Provider.of<ClimaxViewModel>(context, listen: false);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Viewer'),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 32.0, top: statusBarHeight),
              child: ValueListenableBuilder<String>(
                valueListenable: appBarTitleNotifier,
                builder: (context, value, child) {
                  return Text(
                    value,
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  );
                },
              ))
        ],
      ),
      body: widget.route.graspList.isEmpty
          ? Center(child: Text('No grasps available'))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Builder(
                          builder: (context) {
                            final int order = context.select((ClimaxViewModel model) => model.order);
                            climaxModel.setupByGrasp(widget.route.graspList[order]);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              appBarTitleNotifier.value = 'Grasp ${order + 1} of ${widget.route.graspList.length}';
                            });
                            return Builder(
                              builder: (context) {
                                final scaleBackground =
                                    context.select((ClimaxViewModel model) => model.scaleBackground);
                                final scaleAll = context.select((ClimaxViewModel model) => model.scaleAll);
                                final Offset deltaTranslateBackground =
                                    context.select((ClimaxViewModel model) => model.deltaTranslateBackground);
                                final Offset deltaTranslateAll =
                                    context.select((ClimaxViewModel model) => model.deltaTranslateAll);
                                Widget backgroundWidget = Transform.translate(
                                    offset: -deltaTranslateBackground,
                                    child: Transform.scale(
                                        scale: scaleBackground, child: ImageDisplay(widget.wall.imagePath)));
                                return Transform.translate(
                                  offset: -deltaTranslateAll,
                                  child: Transform.scale(
                                    scale: scaleAll,
                                    child: Stack(fit: StackFit.expand, children: [
                                      backgroundWidget,
                                      Container(color: Colors.transparent, child: Climax()),
                                    ]),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ButtonBar(
                            alignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(onPressed: () => climaxModel.decrementOrder(), child: Text("Previous")),
                              ElevatedButton(onPressed: () => climaxModel.incrementOrder(), child: Text("Next"))
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
