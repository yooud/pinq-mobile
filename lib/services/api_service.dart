import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'package:http/http.dart' as http;
import 'package:pinq/models/user.dart';

class ApiService {
  String? _firebaseToken;
  String? _sessionToken;

  Map<String, String> _headers = {};

  Future<void> initializeTokens() async {
    _firebaseToken =
        await fauth.FirebaseAuth.instance.currentUser!.getIdToken();

    _headers['Authorization'] = 'Bearer $_firebaseToken';

    await _initializeSessionToken();
  }

  Future<void> _initializeSessionToken() async {
    if (_firebaseToken == null) {
      throw Exception("Firebase token is not initialized");
    }

    final response = await http.post(
      Uri.parse("https://api.pinq.yooud.org/auth"),
      headers: {
        "Authorization": "Bearer $_firebaseToken",
      },
    );

    if (response.statusCode == 200) {
      _sessionToken = response.headers["x-session-id"];
      _headers['X-Session-Id'] = _sessionToken!;
    } else {
      throw Exception("Failed to retrieve session token");
    }
  }

  Future<User> getUserData() async {
    final response = await http.get(
      Uri.parse("https://api.pinq.yooud.org/me"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> userJson = jsonDecode(response.body);
      return User.fromJson(userJson);
    } else {
      throw Exception("Failed to fetch user data");
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
