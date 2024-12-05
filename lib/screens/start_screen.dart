import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as map;
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';

import 'package:pinq/providers/user_provider.dart';
import 'package:pinq/screens/friends_screen.dart';
import 'package:pinq/screens/profile_screen.dart';
import 'package:pinq/screens/settings_screen.dart';
import 'package:pinq/services/api_service.dart';
import 'package:pinq/widgets/finish_auth.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  map.MapboxMap? mapboxMap;

  Future<bool> _isUserStateComplete() async {
    try {
      if (await ref.read(userProvider.notifier).isRegistraionCompleted()) {
        await ref.read(userProvider.notifier).initializeUser();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
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
    ).then((_) {
      _setPuck();
      _setCameraPosition();
    });
  }

  _onMapCreated(map.MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    mapboxMap.compass.updateSettings(
      map.CompassSettings(enabled: false),
    );
    mapboxMap.scaleBar.updateSettings(
      map.ScaleBarSettings(enabled: false),
    );

    try {
      if (!(await _isUserStateComplete())) {
        _showOnboardingDialog();
      } else {
        _setPuck();
        _setCameraPosition();
      }
    } catch (e) {
      return;
    }
  }

  void _setPuck() async {
    Uint8List imageData = await ref.read(apiServiceProvider).downloadPicture(ref
            .watch(userProvider)
            .pictureUrl ??
        'https://i1.sndcdn.com/artworks-ya3Fpvi7y6zcqjGP-QiF6ng-t500x500.jpg');
    Uint8List circleAvatar = await _cropToCircleAndResize(imageData);

    mapboxMap!.location.updateSettings(
      map.LocationComponentSettings(
        enabled: true,
        locationPuck: map.LocationPuck(
          locationPuck2D: map.LocationPuck2D(
            topImage: circleAvatar,
          ),
        ),
        puckBearingEnabled: false,
      ),
    );
  }

  void _setCameraPosition() async {
    geo.Position position = await _determinePosition();

    mapboxMap!.easeTo(
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

  Future<Uint8List> _cropToCircleAndResize(Uint8List imageData) async {
    final ui.Codec codec = await ui.instantiateImageCodec(imageData);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final int imgWidth = image.width;
    final int imgHeight = image.height;

    int diameter;
    Offset offset;
    if (imgWidth == imgHeight) {
      diameter = imgWidth;
      offset = Offset.zero;
    } else if (imgWidth < imgHeight) {
      diameter = imgWidth;
      offset = Offset(0, (imgHeight - imgWidth) / 2);
    } else {
      diameter = imgHeight;
      offset = Offset((imgWidth - imgHeight) / 2, 0);
    }

    const int targetSize = 150;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint();

    final Path path = Path()
      ..addOval(
          Rect.fromLTWH(0, 0, targetSize.toDouble(), targetSize.toDouble()));

    final double scale = targetSize / diameter;

    canvas.clipPath(path);
    canvas.scale(scale);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(
          offset.dx, offset.dy, diameter.toDouble(), diameter.toDouble()),
      Rect.fromLTWH(0, 0, diameter.toDouble(), diameter.toDouble()),
      paint,
    );

    final ui.Picture picture = recorder.endRecording();
    final ui.Image circledImage = await picture.toImage(targetSize, targetSize);

    final ByteData? byteData =
        await circledImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
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

  void _openProfileOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      builder: (ctx) => const ProfileScreen(),
    ).then((_) {
      _setPuck();
    });
  }

  void _openSettingseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      builder: (ctx) => const SettingsScreen(),
    );
  }

  void _openFriendsOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      builder: (ctx) => const FriendsScreen(),
    );
  }

  Future<void> _openFAQ() async {
    const url = 'https://pinq.yooud.org';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
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
            Positioned(
              top: 144,
              right: 16,
              child: Material(
                color: const Color.fromARGB(155, 255, 170, 198),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: _openFriendsOverlay,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.person_pin,
                      size: 32,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 210,
              right: 16,
              child: Material(
                color: const Color.fromARGB(155, 255, 170, 198),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: _openFAQ,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.question_mark_rounded,
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
