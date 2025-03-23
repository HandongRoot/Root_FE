import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  // LOGIN
  Future<void> login(String socialLoginType) async {
    final String loginUrl = "$baseUrl/auth/$socialLoginType";

    if (await canLaunch(loginUrl)) {
      await launch(loginUrl);
    } else {
      throw Exception("Could not launch login URL");
    }
  }

  // CALLBACK
  Future<void> handleAuthCallback(String socialLoginType, String code) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/auth/$socialLoginType/callback?code=$code"),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String accessToken = responseData['accessToken'];
        String refreshToken = responseData['refreshToken'];

        await _saveTokens(accessToken, refreshToken);
      } else {
        throw Exception("Login callback failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error handling auth callback: $e");
    }
  }

  // REFRESH ACCESS TOKEN
  Future<void> refreshAccessToken() async {
    try {
      String? refreshToken = await _getRefreshToken();
      if (refreshToken == null) throw Exception("No refresh token found.");

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refreshToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String newAccessToken = responseData['accessToken'];
        await _saveAccessToken(newAccessToken);
      } else {
        throw Exception("Failed to refresh access token.");
      }
    } catch (e) {
      throw Exception("Error refreshing token: $e");
    }
  }

  // Save tokens to local storage
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  // Save only access token
  Future<void> _saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
  }

  // Get refresh token from storage
  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }
}
