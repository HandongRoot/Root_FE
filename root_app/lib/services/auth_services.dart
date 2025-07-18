import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:root_app/controllers/folder_controller.dart';
import 'package:root_app/modals/login/terms_modal.dart';
import 'package:root_app/services/api_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/services.dart';

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

    if (await canLaunchUrl(loginUrl as Uri)) {
      await launchUrl(loginUrl as Uri);
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
        //print("✅ Apple 로그인 성공");

        // ✅ 유저 정보 가져오기
        final userData = await ApiService.getUserData().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            //print("❌ 유저 데이터 요청 타임아웃");
            return null;
          },
        );

        if (userData == null) {
          //print("❌ 유저 데이터 없음 또는 에러");
          await clearTokens();
          Get.offAllNamed('/login');
          return;
        }

        // ✅ 약관 체크
        if (userData['termsOfServiceAgrmnt'] == false ||
            userData['privacyPolicyAgrmnt'] == false) {
          Get.offAllNamed('/login');
          await Future.delayed(const Duration(milliseconds: 300));
          Get.bottomSheet(
            const TermsModal(),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          );
        } else {
          Get.find<FolderController>().loadFolders();
          Get.offAllNamed('/home');
        }
      } else {
        //print("❌ Apple 로그인 실패: ${response.statusCode} / ${response.body}");
      }
    } catch (e) {
      //print("❌ Apple 로그인 에러: $e");
      await clearTokens();
      Get.offAllNamed('/login');
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
    if (refreshToken == null) return;
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refreshToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _secureStorage.write(
          key: 'access_token', value: data['access_token']);
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);

    const platform = MethodChannel('com.example.root_app/share');

    try {
      //print("👉 자동: saveAccessToken 호출 시작");
      await platform.invokeMethod('saveAccessToken', accessToken);
      //print("✅ 자동: accessToken App Group에 저장 완료");
    } catch (e) {
      //print("❌ 자동 저장 실패: $e");
    }
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  Future<void> handleKakaoLogin() async {
    try {
      OAuthToken token;

      if (await isKakaoTalkInstalled()) {
        //print("📱 KakaoTalk 설치됨 - loginWithKakaoTalk() 시도");
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        //print("🌐 loginWithKakaoAccount() 사용");
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      //print("✅ Kakao 로그인 성공: ${token.accessToken}");

      // 서버에 전달
      final backendResponse = await ApiService.loginWithKakao(
        token.accessToken,
        token.refreshToken ?? '',
      );

      if (backendResponse != null) {
        await _saveTokens(
          backendResponse['access_token'],
          backendResponse['refresh_token'],
        );

        // ✅ 유저 정보 가져오기 (타임아웃 + 실패 대응 추가)
        final userData = await ApiService.getUserData().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            //print("❌ 유저 데이터 요청 타임아웃");
            return null;
          },
        );

        if (userData == null) {
          //print("❌ 유저 데이터 없음 또는 에러");
          await clearTokens();
          Get.offAllNamed('/login');
          return;
        }

        // ✅ 약관 체크
        if (userData['termsOfServiceAgrmnt'] == false ||
            userData['privacyPolicyAgrmnt'] == false) {
          Get.offAllNamed('/login');
          await Future.delayed(const Duration(milliseconds: 300));
          Get.bottomSheet(
            const TermsModal(),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          );
        } else {
          Get.find<FolderController>().loadFolders();
          Get.offAllNamed('/home');
        }
      } else {
        //print("❌ Backend 로그인 실패");
      }
    } catch (e) {
      //print("❌ 전체 Kakao login 실패: $e");
      await clearTokens();
      Get.offAllNamed('/login');
    }
  }
}


// ios token 연결