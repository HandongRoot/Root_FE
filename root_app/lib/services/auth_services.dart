import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  // ✅ 로그인 진입점: 카카오 or Apple
  Future<void> login(String socialLoginType) async {
    if (socialLoginType == "APPLE") {
      await _appleLogin();
    } else {
      await _launchSocialLogin(socialLoginType);
    }
  }

  // ✅ 카카오 로그인: 외부 브라우저 열기
  Future<void> _launchSocialLogin(String socialLoginType) async {
    final String loginUrl = "$baseUrl/auth/$socialLoginType";

    if (await canLaunch(loginUrl)) {
      await launch(loginUrl);
    } else {
      throw Exception("Could not launch login URL");
    }
  }

  // ✅ Apple 로그인 로직 (Flutter 내 처리)
  Future<void> _appleLogin() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final Map<String, dynamic> requestBody = {
        "authorizationCode": credential.authorizationCode,
        "identityToken": credential.identityToken,
        "userIdentifier": credential.userIdentifier,
        "fullName": {
          "firstname": credential.givenName ?? "",
          "lastname": credential.familyName ?? "",
          "name": "${credential.givenName ?? ''} ${credential.familyName ?? ''}".trim(),
        },
      };

      final response = await http.post(
        Uri.parse("$baseUrl/auth/apple"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String accessToken = responseData['accessToken'];
        String refreshToken = responseData['refreshToken'];

        await _saveTokens(accessToken, refreshToken);
        print("✅ Apple 로그인 성공");
      } else {
        print("❌ Apple 로그인 실패: ${response.statusCode} / ${response.body}");
      }
    } catch (e) {
      print("❌ Apple 로그인 에러: $e");
    }
  }

  // ✅ 콜백 처리 (카카오 등 외부 브라우저 방식)
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

  // ✅ 액세스 토큰 갱신
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

  // ✅ 토큰 저장
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  // ✅ 액세스 토큰만 저장
  Future<void> _saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
  }

  // ✅ 리프레시 토큰 가져오기
  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }
}
