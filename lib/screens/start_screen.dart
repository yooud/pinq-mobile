import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbox;
import 'package:geolocator/geolocator.dart' as glr;
import 'package:pinq/widgets/main_drawer.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  mbox.MapboxMap? mapboxMap;

  _onMapCreated(mbox.MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    glr.Position position = await _determinePosition();

    print(position.longitude);
    print(position.latitude);

    mapboxMap.easeTo(
      mbox.CameraOptions(
          center: mbox.Point(
              coordinates: mbox.Position(
            position.longitude,
            position.latitude,
          )),
          zoom: 16,
          bearing: 0,
          pitch: 3),
      mbox.MapAnimationOptions(duration: 2000, startDelay: 0),
    );
  }

  Future<glr.Position> _determinePosition() async {
    bool serviceEnabled;
    glr.LocationPermission permission;

    serviceEnabled = await glr.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await glr.Geolocator.checkPermission();
    if (permission == glr.LocationPermission.denied) {
      permission = await glr.Geolocator.requestPermission();
      if (permission == glr.LocationPermission.denied) {
        print('Location permissions are denied.');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == glr.LocationPermission.deniedForever) {
      print('Location permissions are permanently denied, we cannot request permissions.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await glr.Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pinq'),
      ),
      body: mbox.MapWidget(
        key: const ValueKey('mapWidget'),
        onMapCreated: _onMapCreated,
      ),
      drawer: HamburgerMenu(
        onSelectScreen: (identifier) {},
      ),
    );
  }
}
