import 'dart:async';

import 'package:camera/camera.dart';
import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/database.dart';
import 'package:climbing_alien/viewmodels/image_viewmodel.dart';
import 'package:climbing_alien/viewmodels/wall_viewmodel.dart';
import 'package:climbing_alien/views/camera/camera_screen.dart';
import 'package:climbing_alien/views/route_management/wall_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // init database
  final database = await (DatabaseProvider.instance.db);
  cameras = await availableCameras();
  runApp(ClimbingProviderApp(climbingDatabase: database));
}

class ClimbingProviderApp extends StatelessWidget {
  final ClimbingDatabase climbingDatabase;

  ClimbingProviderApp({required this.climbingDatabase});

  @override
  Widget build(BuildContext context) {
    final ClimbingRepository climbingRepository = ClimbingRepository(climbingDatabase: climbingDatabase);
    return MultiProvider(providers: [
      Provider.value(value: climbingRepository),
      ChangeNotifierProvider(create: (context) => ImageViewModel()),
      ChangeNotifierProvider(create: (context) => WallViewModel(climbingRepository: climbingRepository)),
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
      initialRoute: WallScreen.routeName,
      routes: {
        WallScreen.routeName: (context) => WallScreen(),
        CameraScreen.routeName: (context) => CameraScreen(),
      },
    );
  }
}
