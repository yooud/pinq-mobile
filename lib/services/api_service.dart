import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pinq/models/invalid_exception.dart';
import 'package:pinq/models/null_exception.dart';
import 'package:pinq/models/user.dart';
import 'package:pinq/models/validation_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  String? _firebaseToken;
  String? _sessionToken;

  final Map<String, String> _headers = {'Content-Type': 'application/json'};
  final Map<String, Object> _body = {'fcm_token': 'asdfasdf'};

  Future<void> initializeTokens() async {
    _firebaseToken = await fire.FirebaseAuth.instance.currentUser!.getIdToken();

    _headers['Authorization'] = 'Bearer $_firebaseToken';

    _sessionToken = await _getSessionToken();

    if (_sessionToken == null) {
      throw NullSessionTokenException('Session token is missing');
    }

    _headers['X-Session-Id'] = _sessionToken!;
  }

  Future<void> initializeSessionToken() async {
    final response = await http.post(
      Uri.parse("https://api.pinq.yooud.org/auth"),
      headers: _headers,
      body: jsonEncode(_body),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      _sessionToken = response.headers["x-session-id"];
      _saveSessionToken(_sessionToken!);
      _headers['X-Session-Id'] = _sessionToken!;
    } else {
      throw Exception("Failed to retrieve session token");
    }
  }

  Future<void> _saveSessionToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('x-session-id', token);
  }

  Future<String?> _getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-session-id');
  }

  Future<void> _clearSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('x-session-id');
  }

  Future<bool> getSessionStatus() async {
    final response = await http.get(
      Uri.parse('https://api.pinq.yooud.org/auth'),
      headers: _headers,
    );
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      bool result = jsonDecode(response.body)['is_profile_complete'];
      return result;
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      await _clearSessionToken();
      throw InvalidSessionTokenException('Session token is invalid');
    } else {
      throw Exception("Failed to fetch user data");
    }
  }

  Future<void> updateUserProfile(User user) async {
    String body = jsonEncode(user.toJson());
    final response = await http.patch(
      Uri.parse('https://api.pinq.yooud.org/profile'),
      headers: _headers,
      body: body,
    );
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      final responseData = jsonDecode(response.body);
      user.username = responseData['username'];
      user.displayName = responseData['display_name'];
      user.pictureUrl = responseData['profile_picture_url'];

      print('Succesfully upgraded user data');
    } 
    if(response.statusCode == 400){
      final responseData = jsonDecode(response.body);
      throw ValidationException(responseData['errors']);
    }
  }

  Future<void> updateUserPicture(User user) async {
    final response = await http.patch(
      Uri.parse('https://api.pinq.yooud.org/profile'),
      headers: _headers,
      body: jsonEncode({'picture_id': user.pictureId}),
    );
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      final responseData = jsonDecode(response.body);
      user.pictureUrl = responseData['profile_picture_url'];
    } else {
      throw Exception("Failed to upgrade user data");
    }
  }

  Future<User> getUserData() async {
    final response = await http.get(
      Uri.parse("https://api.pinq.yooud.org/profile/me"),
      headers: _headers,
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      final Map<String, dynamic> userJson = jsonDecode(response.body);
      return User.fromJson(userJson);
    } else {
      throw Exception("Failed to fetch user data");
    }
  }

  Future<String> uploadProfileImage(String imageUrl) async {
    final imgResponse = await http.get(Uri.parse(imageUrl));

    if (imgResponse.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile.writeAsBytes(imgResponse.bodyBytes);

      final uri = Uri.parse('https://api.pinq.yooud.org/photo/profile');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Authorization': 'Bearer $_firebaseToken',
          'X-Session-Id': _sessionToken!,
        })
        ..files.add(await http.MultipartFile.fromPath('file', tempFile.path));

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final responseData = jsonDecode(response.body);
        return responseData['id'];
      } else {
        throw Exception("Failed to upload profile image");
      }
    } else {
      throw Exception("Failed to download image");
    }
  }

  Future<Uint8List> downloadPicture(String pictureUrl) async {
    final response = await http.get(Uri.parse(pictureUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("Failed to download image");
    }
  }

  Future<void> logOut() async {
    http.delete(
      Uri.parse('https://api.pinq.yooud.org/auth'),
      headers: _headers,
    );
    _clearSessionToken();
    GoogleSignIn().signOut();
    await fire.FirebaseAuth.instance.signOut();
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
