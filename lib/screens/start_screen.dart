import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as map;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:pinq/screens/settings_screen.dart';
import 'package:pinq/widgets/main_drawer.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  map.MapboxMap? mapboxMap;

  _onMapCreated(map.MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    geo.Position position = await _determinePosition();

    Uint8List imageData =
        await loadImageAsUint8List('assets/google_icon.png', 150, 150);

    mapboxMap.location.updateSettings(
      map.LocationComponentSettings(
        enabled: true,
        locationPuck: map.LocationPuck(
          locationPuck2D: map.LocationPuck2D(
            topImage: imageData,
          ),
        ),
      ),
    );

    mapboxMap.easeTo(
      map.CameraOptions(
          center: map.Point(
              coordinates: map.Position(
            position.longitude,
            position.latitude,
          )),
          zoom: 16,
          bearing: 0,
          pitch: 15),
      map.MapAnimationOptions(duration: 1000, startDelay: 0),
    );
  }

  Future<geo.Position> _determinePosition() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        print('Location permissions are denied.');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await geo.Geolocator.getCurrentPosition();
  }

  Future<Uint8List> loadImageAsUint8List(
      String assetPath, int width, int height) async {
    ByteData data = await rootBundle.load(assetPath);
    Uint8List list = data.buffer.asUint8List();

    Uint8List resizedImage = await FlutterImageCompress.compressWithList(
      list,
      minWidth: width,
      minHeight: height,
      format: CompressFormat.png,
    );

    return resizedImage;
  }

    void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == 'settings') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const SettingsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pinq'),
      ),
      body: map.MapWidget(
        key: const ValueKey('mapWidget'),
        onMapCreated: _onMapCreated,
      ),
      drawer: HamburgerMenu(
        onSelectScreen: _setScreen,
      ),
    );
  }
}
