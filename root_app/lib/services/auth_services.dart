import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:root_app/services/api_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:root_app/services/navigation_service.dart';

class AuthService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 로그인 진입점
  Future<void> login(String socialLoginType) async {
    if (socialLoginType == "APPLE") {
      await _appleLogin();
    } else {
      await _launchSocialLogin(socialLoginType);
    }
  }

  Future<void> _launchSocialLogin(String socialLoginType) async {
    final String loginUrl = "$baseUrl/auth/$socialLoginType";

    if (await canLaunch(loginUrl)) {
      await launch(loginUrl);
    } else {
      throw Exception("Could not launch login URL");
    }
  }

  Future<void> _appleLogin() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
      );

      final Map<String, dynamic> requestBody = {
        "authorizationCode": credential.authorizationCode,
        "identityToken": credential.identityToken,
        "userIdentifier": credential.userIdentifier,
        "fullName": {
          "firstname": credential.givenName ?? "",
          "lastname": credential.familyName ?? "",
          "name": "${credential.givenName ?? ''} ${credential.familyName ?? ''}"
              .trim(),
        },
      };

      final response = await http.post(
        Uri.parse("$baseUrl/auth/apple"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['access_token'], data['refresh_token']);
        print("✅ Apple 로그인 성공");
      } else {
        print("❌ Apple 로그인 실패: ${response.statusCode} / ${response.body}");
      }
    } catch (e) {
      print("❌ Apple 로그인 에러: $e");
    }
  }

  Future<void> handleAuthCallback(String socialLoginType, String code) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/auth/$socialLoginType/callback?code=$code"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['access_token'], data['refresh_token']);
      } else {
        throw Exception("Login callback failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error handling auth callback: $e");
    }
  }

  Future<void> refreshAccessToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');

    if (refreshToken == null) {
      print("No refresh token found.");
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refreshToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _secureStorage.write(
          key: 'access_token', value: data['access_token']);
      print("🔄 Access token refreshed.");
    } else {
      print("❌ Failed to refresh token: ${response.statusCode}");
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

Future<void> handleKakaoLogin() async {
  try {
    OAuthToken token;

    if (await isKakaoTalkInstalled()) {
      print("📱 KakaoTalk 설치됨 - loginWithKakaoTalk() 시도");
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
        print("✅ loginWithKakaoTalk 성공: ${token.accessToken}");
      } catch (e) {
        print("⚠️ loginWithKakaoTalk 실패: $e");
        print("🌐 loginWithKakaoAccount() fallback 시도");

        token = await UserApi.instance.loginWithKakaoAccount();
        print("✅ loginWithKakaoAccount 성공: ${token.accessToken}");
      }
    } else {
      print("📱 KakaoTalk 미설치 - loginWithKakaoAccount() 사용");
      token = await UserApi.instance.loginWithKakaoAccount();
      print("✅ loginWithKakaoAccount 성공: ${token.accessToken}");
    }

    final backendResponse = await ApiService.loginWithKakao(
      token.accessToken,
      token.refreshToken ?? '',
    );

    if (backendResponse != null) {
      await _saveTokens(
        backendResponse['access_token'],
        backendResponse['refresh_token'],
      );
      print("✅ Backend 로그인 성공");

      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
      );
    } else {
      print("❌ Backend 로그인 실패");
    }
    } catch (e, stack) {
      print("❌ 전체 Kakao login 실패: $e");
      print("📦 스택 추적: $stack");
    }
}
}
