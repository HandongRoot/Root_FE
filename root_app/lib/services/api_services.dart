import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root_app/screens/search_page.dart';

class ApiService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  // 사용자 정보 가져오기
  static Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    final String endpoint = "/api/v1/user/$userId";
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {"Accept": "*/*"},
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        print("Failed to load user data. Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // 로그아웃
  static Future<bool> logoutUser(String userId) async {
    final String endpoint = "/api/v1/logout/$userId";
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final response = await http.post(
        Uri.parse(requestUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error logging out: $e");
      return false;
    }
  }

  // 회원 탈퇴
  static Future<bool> deleteUser(String userId) async {
    final String endpoint = "/api/v1/user/$userId";
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final response = await http.delete(
        Uri.parse(requestUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting user: $e");
      return false;
    }
  }

  // 콘텐츠 검색
  static Future<List<Contents>> searchContents(
      String query, String userId) async {
    final String endpoint =
        "/api/v1/content/search/$userId?title=${Uri.encodeComponent(query)}";
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final response =
          await http.get(Uri.parse(requestUrl), headers: {"Accept": "*/*"});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Contents.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load content search data");
      }
    } catch (e) {
      print("Error searching contents: $e");
      return [];
    }
  }

  // 카테고리 검색
  static Future<List<Category>> searchCategories(
      String query, String userId) async {
    final String endpoint =
        "/api/v1/category/search/$userId?title=${Uri.encodeComponent(query)}";
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final response =
          await http.get(Uri.parse(requestUrl), headers: {"Accept": "*/*"});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load category search data");
      }
    } catch (e) {
      print("Error searching categories: $e");
      return [];
    }
  }

  // FOLDER screen

  static Future<List<Map<String, dynamic>>> fetchFolders(String userId) async {
    if (baseUrl == null || baseUrl!.isEmpty) {
      print('BASE_URL is not defined in .env');
      return [];
    }

    final String url = '$baseUrl/api/v1/category/findAll/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> foldersJson =
            json.decode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(foldersJson);
      } else {
        print('Failed to load folders, Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("Error loading folders: $e");
      return [];
    }
  }

  static Future<bool> deleteFolder(String userId, String folderId) async {
    if (baseUrl == null || baseUrl!.isEmpty) {
      print('BASE_URL is not defined in .env');
      return false;
    }

    final String url = '$baseUrl/api/v1/category/delete/$userId/$folderId';

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to delete folder, Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting folder: $e');
      return false;
    }
  }
}

// FOLDER CONTENTS 


