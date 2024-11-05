import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as map;
import 'package:geolocator/geolocator.dart' as geo;
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

    print(position.longitude);
    print(position.latitude);

    mapboxMap.location.updateSettings(
      map.LocationComponentSettings(
        enabled: true,
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
        onSelectScreen: (identifier) {},
      ),
    );
  }
}
