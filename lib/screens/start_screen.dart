import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as map;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:pinq/models/annotation_listener.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/providers/friends_provider.dart';
import 'package:pinq/providers/incoming_provider.dart';
import 'package:pinq/providers/outgoing_provider.dart';
import 'package:pinq/providers/ws_friends_provider.dart';
import 'package:pinq/screens/splash_screen.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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
  WebSocketChannel? _channel;
  Timer? _locationUpdateTimer;
  final Map<String, User> annotationFriendMap = {};
  final List<map.PointAnnotation> annotations = [];
  map.PointAnnotationManager? pointAnnotationManager;
  bool isLoading = true;

  @override
  void dispose() {
    _channel?.sink.close();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeWebSocket() async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.initializeTokens();
    final firebaseToken = apiService.firebaseToken;
    final sessionToken = apiService.sessionToken;

    _channel =
        WebSocketChannel.connect(Uri.parse('wss://api.pinq.yooud.org/map/ws'));

    _channel!.sink.add(jsonEncode({
      "type": "auth",
      "data": {
        "token": firebaseToken,
        "session": sessionToken,
      }
    }));

    _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['type'] == 'initial') {
        ref.read(wsFriendsProvider.notifier).setFriends(data['data']);
        _handleInitialData();
      } else if (data['type'] == 'move') {
        _handleMoveData(data['data']);
      }
    });

    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 40), (timer) {
      _sendUserPosition();
    });
  }

  Future<void> _sendUserPosition() async {
    geo.Position position = await _determinePosition();
    User user = ref.read(userProvider);

    if (user.lat == null ||
        user.lng == null ||
        user.lat != position.latitude ||
        user.lng != position.longitude) {
      ref.read(userProvider.notifier).updatePosition(
            position.latitude,
            position.longitude,
          );
      if(annotationFriendMap.isNotEmpty) {
        _setNewUserPuck();
      }
    }

    _channel!.sink.add(jsonEncode({
      "type": "update_location",
      "data": {
        "location": {
          "lng": position.longitude,
          "lat": position.latitude,
        }
      }
    }));
  }

  void _handleInitialData() async {
    await _setUserPuck();

    _setFriendsPucks();
  }

  void _handleMoveData(Map<String, dynamic> data) {
    User friend = User.wsFriendFromJson(data);
    friend = ref.read(wsFriendsProvider.notifier).updateFriendLocation(
          friend.username!,
          friend.lat!,
          friend.lng!,
        );
    if(annotationFriendMap.containsKey(friend.username)) {
      _setNewFriendPuck(friend);
    }
  }

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
    ).then((_) async {
      pointAnnotationManager =
          await mapboxMap!.annotations.createPointAnnotationManager();

      pointAnnotationManager!
          .addOnPointAnnotationClickListener(AnnotationListener(
        annotationFriendMap: annotationFriendMap,
        user: ref.read(userProvider),
        context: context,
      ));

      _initializeWebSocket();
      ref.read(friendsProvider.notifier).getFriends();
      ref
          .read(incomingFriendRequestsProvider.notifier)
          .getIncomingFriendRequests();
      ref
          .read(outgoingFriendRequestsProvider.notifier)
          .getOutgoingFriendRequests();
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
      if ((await _isUserStateComplete())) {
        pointAnnotationManager =
            await mapboxMap.annotations.createPointAnnotationManager();

        pointAnnotationManager!
            .addOnPointAnnotationClickListener(AnnotationListener(
          annotationFriendMap: annotationFriendMap,
          user: ref.read(userProvider),
          context: context,
        ));

        _initializeWebSocket();
        ref.read(friendsProvider.notifier).getFriends();
        ref
            .read(incomingFriendRequestsProvider.notifier)
            .getIncomingFriendRequests();
        ref
            .read(outgoingFriendRequestsProvider.notifier)
            .getOutgoingFriendRequests();
      } else {
        _showOnboardingDialog();
      }
    } catch (e) {
      return;
    }
  }

  Future<void> _setUserPuck() async {
    await _sendUserPosition();

    User user = ref.read(userProvider);

    double latitude = user.lat!;
    double longitude = user.lng!;

    Uint8List imageData = await ref.read(apiServiceProvider).downloadPicture(user
            .pictureUrl ??
        'https://i1.sndcdn.com/artworks-ya3Fpvi7y6zcqjGP-QiF6ng-t500x500.jpg');
    Uint8List circleAvatar = await _cropToCircleAndResize(imageData);

    map.PointAnnotationOptions pointAnnotationOptions =
        map.PointAnnotationOptions(
      geometry: map.Point(coordinates: map.Position(longitude, latitude)),
      image: circleAvatar,
    );

    final pointAnnotation =
        await pointAnnotationManager!.create(pointAnnotationOptions);
    annotations.add(pointAnnotation);
    annotationFriendMap[pointAnnotation.id] = user;

    setState(() {
      isLoading = false;
    });

    await _setCameraPosition(ref.read(userProvider).username!);
  }

  void _setNewUserPuck() async {
    User user = ref.read(userProvider);
    double latitude = user.lat!;
    double longitude = user.lng!;

    Uint8List imageData = await ref.read(apiServiceProvider).downloadPicture(user
            .pictureUrl ??
        'https://i1.sndcdn.com/artworks-ya3Fpvi7y6zcqjGP-QiF6ng-t500x500.jpg');
    Uint8List circleAvatar = await _cropToCircleAndResize(imageData);

    map.PointAnnotationOptions pointAnnotationOptions =
        map.PointAnnotationOptions(
      geometry: map.Point(coordinates: map.Position(longitude, latitude)),
      image: circleAvatar,
    );

    String annotationId = annotationFriendMap.entries
        .firstWhere((entry) => entry.value.username == user.username)
        .key;

    await pointAnnotationManager!.delete(
      annotations.firstWhere(
        (a) => a.id == annotationId,
      ),
    );

    annotations.removeWhere((a) => a.id == annotationId);
    annotationFriendMap.remove(annotationId);

    final pointAnnotation =
        await pointAnnotationManager!.create(pointAnnotationOptions);
    annotations.add(pointAnnotation);
    annotationFriendMap[pointAnnotation.id] = user;
  }

  Future<void> _setNewFriendPuck(User friend) async {
    double latitude = friend.lat!;
    double longitude = friend.lng!;

    Uint8List imageData = await ref.read(apiServiceProvider).downloadPicture(
        friend.pictureUrl ??
            'https://i1.sndcdn.com/artworks-ya3Fpvi7y6zcqjGP-QiF6ng-t500x500.jpg');
    Uint8List circleAvatar = await _cropToCircleAndResize(imageData);

    map.PointAnnotationOptions pointAnnotationOptions =
        map.PointAnnotationOptions(
      geometry: map.Point(coordinates: map.Position(longitude, latitude)),
      image: circleAvatar,
    );

    String annotationId = annotationFriendMap.entries
        .firstWhere((entry) => entry.value.username == friend.username)
        .key;

    await pointAnnotationManager!.delete(
      annotations.firstWhere(
        (a) => a.id == annotationId,
      ),
    );

    annotations.removeWhere((a) => a.id == annotationId);
    annotationFriendMap.remove(annotationId);

    final pointAnnotation =
        await pointAnnotationManager!.create(pointAnnotationOptions);
    annotations.add(pointAnnotation);
    annotationFriendMap[pointAnnotation.id] = friend;
  }

  void _setFriendsPucks() async {
    List<User> friends = ref.read(wsFriendsProvider);

    for (int i = 0; i < friends.length; i++) {
      double latitude = friends[i].lat!;
      double longitude = friends[i].lng!;

      Uint8List imageData = await ref.read(apiServiceProvider).downloadPicture(
          friends[i].pictureUrl ??
              'https://i1.sndcdn.com/artworks-ya3Fpvi7y6zcqjGP-QiF6ng-t500x500.jpg');
      Uint8List circleAvatar = await _cropToCircleAndResize(imageData);

      map.PointAnnotationOptions pointAnnotationOptions =
          map.PointAnnotationOptions(
        geometry: map.Point(coordinates: map.Position(longitude, latitude)),
        image: circleAvatar,
      );
      final pointAnnotation =
          await pointAnnotationManager!.create(pointAnnotationOptions);
      annotations.add(pointAnnotation);
      annotationFriendMap[pointAnnotation.id] = friends[i];
    }
  }

Future<void> _setCameraPosition(String username) async {
  double latitude = annotationFriendMap.entries
      .firstWhere((entry) => entry.value.username == username)
      .value
      .lat!;
  double longitude = annotationFriendMap.entries
      .firstWhere((entry) => entry.value.username == username)
      .value
      .lng!;

  var position = map.Point(coordinates: map.Position(longitude, latitude));

  await mapboxMap!.easeTo(
    map.CameraOptions(
      center: position,
      zoom: 1,
    ),
    map.MapAnimationOptions(duration: 2000, startDelay: 0),
  );

  await Future.delayed(const Duration(milliseconds: 2000));

  await mapboxMap!.easeTo(
    map.CameraOptions(
      center: position,
      zoom: 16,
    ),
    map.MapAnimationOptions(duration: 3000, startDelay: 0),
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

    geo.Position position = await geo.Geolocator.getCurrentPosition();

    return position;
  }

  void _openProfileOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      builder: (ctx) => const ProfileScreen(),
    ).then((_) {
      _setUserPuck();
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
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.85,
        child: FriendsScreen(
          setCameraPosition: _setCameraPosition,
        ),
      ),
    );
  }

  Future<void> _openFAQ() async {
    const url = 'https://pinq.yooud.org';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
            if (isLoading) const SplashScreen(),
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: const Color.fromARGB(155, 255, 170, 198),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: isLoading ? () {} : _openProfileOverlay,
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
                  onTap: isLoading ? () {} : _openSettingseOverlay,
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
                  onTap: isLoading ? () {} : _openFriendsOverlay,
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
              top: 208,
              right: 16,
              child: Material(
                color: const Color.fromARGB(155, 255, 170, 198),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: isLoading ? () {} : _openFAQ,
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
            Positioned(
              bottom: 35,
              right: MediaQuery.of(context).size.width / 2 - 32,
              child: Material(
                color: const Color.fromARGB(155, 255, 170, 198),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: isLoading
                      ? () {}
                      : () {
                          _setCameraPosition(ref.read(userProvider).username!);
                        },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.not_listed_location_sharp,
                      size: 48,
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
