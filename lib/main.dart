import 'dart:async';

import 'package:climbing_alien/data/api/climbr_api.dart';
import 'package:climbing_alien/data/climbing_repository.dart';
import 'package:climbing_alien/data/database.dart';
import 'package:climbing_alien/widgets_unused/camera/image_viewmodel.dart';
import 'package:climbing_alien/views/wall_management/wall_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // init database
  final database = await (DatabaseProvider.instance.db);
  runApp(ClimbingProviderApp(climbingDatabase: database));
}

class ClimbingProviderApp extends StatelessWidget {
  final ClimbingDatabase climbingDatabase;

  ClimbingProviderApp({required this.climbingDatabase});

  @override
  Widget build(BuildContext context) {
    final ClimbrApi climbrApi = ClimbrApi();
    final ClimbingRepository climbingRepository =
        ClimbingRepository(climbingDatabase: climbingDatabase, climbrApi: climbrApi);
    return MultiProvider(providers: [
      Provider.value(value: climbingRepository),
      ChangeNotifierProvider(create: (context) => ImageViewModel()),
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
      },
    );
  }
}
