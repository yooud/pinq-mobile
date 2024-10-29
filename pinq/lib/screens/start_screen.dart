import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:pinq/widgets/main_drawer.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {

  CameraOptions camera = CameraOptions(
    center: Point(
      coordinates: Position(-98.0, 39.5),
    ),
    zoom: 2,
    bearing: 0,
    pitch: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pinq'),
      ),
      body: MapWidget(cameraOptions: camera,),
      drawer: HamburgerMenu(
        onSelectScreen: (identifier) {},
      ),
    );
  }
}
