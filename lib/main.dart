import 'package:camera/camera.dart';
import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/database.dart';
import 'package:climbing_alien/viewmodels/climax_viewmodel.dart';
import 'package:climbing_alien/viewmodels/image_viewmodel.dart';
import 'package:climbing_alien/viewmodels/route_viewmodel.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/camera/camera_screen.dart';
import 'package:climbing_alien/views/route_editor/route_editor_screen.dart';
import 'package:climbing_alien/views/route_management/route_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // init database
  final database = await DatabaseProvider.instance.db;
  cameras = await availableCameras();
  runApp(ClimbingProviderApp(climbingDatabase: database));
}

class ClimbingProviderApp extends StatelessWidget {
  final ClimbingDatabase climbingDatabase;

  ClimbingProviderApp({this.climbingDatabase}) : assert(climbingDatabase != null);

  @override
  Widget build(BuildContext context) {
    final ClimbingRepository climbingRepository = ClimbingRepository(climbingDatabase: climbingDatabase);
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => ImageViewModel()),
      ChangeNotifierProvider(create: (context) => ClimaxViewModel()),
      ChangeNotifierProvider(create: (context) => WallViewModel(climbingRepository: climbingRepository)),
      ChangeNotifierProvider(create: (context) => RouteViewModel(climbingRepository: climbingRepository)),
    ], child: ClimbingApp());
  }
}

class ClimbingApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: RouteManagementScreen.routeName,
      routes: {
        RouteManagementScreen.routeName: (context) => RouteManagementScreen(),
        RouteEditorScreen.routeName: (context) => RouteEditorScreen(),
        CameraScreen.routeName: (context) => CameraScreen(),
      },
    );
  }
}
