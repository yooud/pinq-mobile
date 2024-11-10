import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as map;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:pinq/providers/user_provider.dart';
import 'package:pinq/screens/profile_screen.dart';
import 'package:pinq/screens/settings_screen.dart';
import 'package:pinq/widgets/finish_auth.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  map.MapboxMap? mapboxMap;

    @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        _showOnboardingDialog();
      }
    });
  }

    void _showOnboardingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          
          backgroundColor: Colors.transparent,
          child: FinishAuth(),
        );
      },
    );
  }

  _onMapCreated(map.MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    mapboxMap.compass.updateSettings(
      map.CompassSettings(enabled: false),
    );
    mapboxMap.scaleBar.updateSettings(
      map.ScaleBarSettings(enabled: false),
    );

    if (ref.read(userProvider) == null) {
      ref.read(userProvider.notifier).setUserByGoogle(
            FirebaseAuth.instance.currentUser!.email!,
            FirebaseAuth.instance.currentUser!.photoURL!,
          );
    }

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
          builder: (ctx) => const ProfileScreen(),
        ),
      );
    }
  }

  void _openProfileOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Color.fromARGB(255, 30, 30, 30),
      builder: (ctx) => const ProfileScreen(),
    );
  }

  void _openSettingseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Color.fromARGB(255, 30, 30, 30),
      builder: (ctx) => const SettingsScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            map.MapWidget(
              key: const ValueKey('mapWidget'),
              onMapCreated: _onMapCreated,
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: const Color.fromARGB(155, 255, 170, 198),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: _openProfileOverlay,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.account_circle,
                      size: 32,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: 16,
              child: Material(
                color: const Color.fromARGB(155, 255, 170, 198),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: _openSettingseOverlay,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.settings_sharp,
                      size: 32,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
