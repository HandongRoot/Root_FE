import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root_app/screens/search/search_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

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

  // KAKAO LOGIN -----------------------------------------------
  static Future<Map<String, dynamic>?> loginWithKakao(
      String kakaoAccessToken, String kakaoRefreshToken) async {
    final String endpoint = "/auth/KAKAO";
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final response = await http.post(
        Uri.parse(requestUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "access_token": kakaoAccessToken,
          "refresh_token": kakaoRefreshToken,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print("Failed to login via Kakao. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error during Kakao login: $e");
      return null;
    }
  }

  // TERMS AGREEMENT ------------------------------------------------

  static Future<bool> submitUserAgreement({
    required bool termsOfServiceAgrmnt,
    required bool privacyPolicyAgrmnt,
  }) async {
    final String requestUrl = "$baseUrl/api/v1/user/argmnt";

    try {
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'termsOfServiceAgrmnt': termsOfServiceAgrmnt,
        'privacyPolicyAgrmnt': privacyPolicyAgrmnt,
      });

      final response =
          await http.post(Uri.parse(requestUrl), headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("약관 동의 전송 성공");
        return true;
      } else {
        print("약관 동의 전송 실패: ${response.statusCode} / ${response.body}");
        return false;
      }
    } catch (e) {
      print("약관 동의 중 오류: $e");
      return false;
    }
  }

  // MYPAGE ------------------------------------------------

  // 사용자 정보 가져오기
  static Future<Map<String, dynamic>?> getUserData() async {
    final String requestUrl = "$baseUrl/api/v1/user";

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(requestUrl), headers: headers);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        print("Failed to load user data. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // 로그아웃
  static Future<bool> logoutUser() async {
    final String endpoint = "/api/v1/logout";
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(requestUrl),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error logging out: $e");
      return false;
    }
  }

  // 회원 탈퇴
  static Future<bool> deleteUser() async {
    final String endpoint = "/api/v1/user";
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse(requestUrl),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting user: $e");
      return false;
    }
  }

  // SEARCH ------------------------------------------------

  // 콘텐츠 검색
  static Future<List<Contents>> searchContents(String query) async {
    final String endpoint =
        "/api/v1/content/search?title=${Uri.encodeComponent(query)}";
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(requestUrl), headers: headers);
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
  static Future<List<Category>> searchCategories(String query) async {
    final String endpoint =
        "/api/v1/category/search?title=${Uri.encodeComponent(query)}";
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(requestUrl), headers: headers);
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

  // FOLDER ------------------------------------------------

  static Future<List<Map<String, dynamic>>> getFolders() async {
    final String requestUrl = '$baseUrl/api/v1/category/findAll';

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(requestUrl), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> foldersJson =
            json.decode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(foldersJson);
      } else {
        print('❌ Failed to load folders, Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("❌ Error loading folders: $e");
      return [];
    }
  }

  static Future<bool> updateFolderName(
      String categoryId, String newTitle) async {
    final storage = const FlutterSecureStorage();
    final accessToken = await storage.read(key: 'access_token');
    if (accessToken == null) return false;

    final url = Uri.parse('$baseUrl/api/v1/category/update/title/$categoryId');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'title': newTitle}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('📁 폴더 이름 업데이트 성공');
        return true;
      } else {
        print('🚨 폴더 이름 업데이트 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      return false;
    }
  }

  static Future<bool> deleteFolder(String folderId) async {
    final String requestUrl = '$baseUrl/api/v1/category/delete/$folderId';

    try {
      final headers = await _getAuthHeaders();
      final response =
          await http.delete(Uri.parse(requestUrl), headers: headers);

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

  static Future<Map<String, dynamic>?> createFolder(String title) async {
    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) return null;

    final String url = '$baseUrl/api/v1/category';
    final Map<String, dynamic> requestBody = {'title': title};

    final storage = FlutterSecureStorage();
    final String? accessToken = await storage.read(key: 'access_token');

    if (accessToken == null) {
      print('❌ Access token not found.');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decodedResponse =
            json.decode(utf8.decode(response.bodyBytes));
        if (decodedResponse is Map<String, dynamic>) {
          return decodedResponse;
        }
        return {'title': title};
      }
    } catch (e) {
      print('❌ Error creating folder: $e');
    }

    return null;
  }

  static Future<bool> createFolderAndSaveContent({
    required String folderTitle,
    required String contentTitle,
    required String thumbnail,
    required String linkedUrl,
  }) async {
    final headers = await _getAuthHeaders();

    try {
      // Create Folder
      final folderRes = await http.post(
        Uri.parse('$baseUrl/api/v1/category'),
        headers: headers,
        body: jsonEncode({'title': folderTitle}),
      );

      if (folderRes.statusCode != 200 && folderRes.statusCode != 201) {
        print("❌ Failed to create folder. Status: ${folderRes.statusCode}");
        return false;
      }

      final decoded = json.decode(utf8.decode(folderRes.bodyBytes));
      final int categoryId = decoded is int
          ? decoded
          : decoded['id'] ?? (throw Exception("Unexpected response: $decoded"));

      // Save Content
      final contentRes = await http.post(
        Uri.parse('$baseUrl/api/v1/content?category=$categoryId'),
        headers: headers,
        body: jsonEncode({
          'title': contentTitle,
          'thumbnail': thumbnail,
          'linkedUrl': linkedUrl,
        }),
      );

      if (contentRes.statusCode == 200 || contentRes.statusCode == 201) {
        return true;
      } else {
        print("❌ Failed to save content. Status: ${contentRes.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error during folder+content creation: $e");
      return false;
    }
  }

// FOLDER CONTENTS ------------------------------------------------

  static Future<List<dynamic>> getFolderPaginatedContents(
    String categoryId, {
    String? contentId,
  }) async {
    final String requestUrl = contentId != null
        ? '$baseUrl/api/v1/content/find/$categoryId?contentId=$contentId'
        : '$baseUrl/api/v1/content/find/$categoryId';

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(requestUrl), headers: headers);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load paginated folder contents');
      }
    } catch (e) {
      print("Error fetching paginated folder contents: $e");
      return [];
    }
  }

  static Future<bool> renameContent(String contentId, String newTitle) async {
    final String url = '$baseUrl/api/v1/content/update/title/$contentId';

    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'title': newTitle}),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Error renaming content: $e");
      return false;
    }
  }

// 폴더에서 제거
  static Future<bool> removeContent(
      String contentId, String beforeCategoryId) async {
    final String url = '$baseUrl/api/v1/content/change/$beforeCategoryId/0';

    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(contentId),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Error removing content from folder: $e");
      return false;
    }
  }

  // GALLERY ------------------------------------------------

  // 모든 contents 불러오기
  static Future<List<dynamic>> getPaginatedContents({String? contentId}) async {
    final String endpoint = contentId != null
        ? "/api/v1/content/findAll?contentId=$contentId"
        : "/api/v1/content/findAll";

    final String requestUrl = "$baseUrl$endpoint";

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(requestUrl), headers: headers);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception("Failed to load contents");
      }
    } catch (e) {
      print("Error fetching contents: $e");
      return [];
    }
  }

  // 삭제 삭제
  static Future<bool> deleteContent(String contentId) async {
    final String endpoint = "/api/v1/content/$contentId";
    final String requestUrl = "$baseUrl$endpoint";
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse(requestUrl),
        headers: headers,
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Error deleting content: $e");
      return false;
    }
  }

  static Future<bool> deleteSelectedContents(List<String> contentIds) async {
    bool allSuccess = true;

    for (final contentId in contentIds) {
      final success = await deleteContent(contentId);
      if (!success) {
        allSuccess = false;
        print("Failed to delete content ID: $contentId");
      }
    }

    if (!allSuccess) {
      print("Some items failed to delete. Data sync issues may occur.");
    }
    return allSuccess;
  }
}
