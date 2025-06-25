import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:root_app/services/api_services.dart';

class ContentService {
  static final _storage = const FlutterSecureStorage();

  static Future<String?> _getBaseUrl() async {
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      ////print("❌ BASE_URL is not set.");
      return null;
    }
    return baseUrl;
  }

  static Future<String?> _getToken() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      ////print("❌ Access token not found.");
      return null;
    }
    return token;
  }

  // HEADER -----------------------------------------------

  static Future<Map<String, String>> _getAuthHeaders() async {
    const storage = FlutterSecureStorage();
    final String? token = await storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 폴더 새로 생성하고 그 폴더로 옮기기
  static Future<bool> moveContentToFolder(
      List<String> contentIds, String targetCategoryId) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getAuthHeaders();
    if (baseUrl == null) return false;

    final url = '$baseUrl/api/v1/content/add/$targetCategoryId';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(contentIds.map(int.parse).toList()),
      );

      print("📤 Moving content $contentIds to folder $targetCategoryId");
      print("📥 Status: ${response.statusCode}, Body: ${response.body}");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("❌ Error in moveContentToFolder: $e");
      return false;
    }
  }
}
