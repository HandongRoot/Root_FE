import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  // 폴더 새로 생성하고 그 폴더로 옮기기
  static Future<bool> moveContentToFolder(
      List<String> contentIds, String targetCategoryId) async {
    final baseUrl = await _getBaseUrl();
    final token = await _getToken();
    if (baseUrl == null || token == null) return false;

    final url = '$baseUrl/api/v1/content/add/$targetCategoryId';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(contentIds),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ////print("✅ Content moved to new folder $targetCategoryId");
        return true;
      } else {
        ////print("❌ Failed to move content. Status: ${response.statusCode}");
        ////print("❌ Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      ////print("❌ Error moving content to folder: $e");
      return false;
    }
  }

  // 폴더 내에서 콘텐츠 변경
  static Future<bool> changeContentToFolder(
    List<String> contentIds,
    String beforeCategoryId,
    String afterCategoryId,
  ) async {
    final baseUrl = await _getBaseUrl();
    final token = await _getToken();
    if (baseUrl == null || token == null) return false;

    if (contentIds.isEmpty) {
      ////print("❌ No content IDs provided.");
      return false;
    }

    final List<dynamic> parsedIds = contentIds.map((id) {
      return int.tryParse(id) ?? id;
    }).toList();

    final results = await Future.wait(parsedIds.map((id) async {
      final url =
          '$baseUrl/api/v1/content/change/$beforeCategoryId/$afterCategoryId';

      try {
        final response = await http.patch(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(id),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        } else {
          ////print("❌ Failed to move $id. Body: ${response.body}");
          return false;
        }
      } catch (e) {
        ////print("❌ Error moving content ID $id: $e");
        return false;
      }
    }));

    return results.every((success) => success);
  }
}
