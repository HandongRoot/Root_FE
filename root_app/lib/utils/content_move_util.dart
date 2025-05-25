import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root_app/main.dart';

//gallery 용 category 바꾸는 endpoint
Future<bool> moveContentToFolder(
    List<String> contentIds, String targetCategoryId) async {
  final String? baseUrl = dotenv.env['BASE_URL'];
  const storage = FlutterSecureStorage();
  final String? accessToken = await storage.read(key: 'access_token');

  if (baseUrl == null || baseUrl.isEmpty || accessToken == null) {
    print("❌ BASE_URL or access token is not available");
    return false;
  }

  final String url = '$baseUrl/api/v1/content/add/$targetCategoryId';

  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(contentIds),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  } catch (e) {
    print('❌ Error moving content: $e');
    return false;
  }
}
