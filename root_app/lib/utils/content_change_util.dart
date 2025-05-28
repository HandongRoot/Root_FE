import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//chagne modal 용 category 바꾸는 endpoint
Future<bool> changeContentToFolder(
  List<String> contentIds,
  String beforeCategoryId,
  String afterCategoryId,
) async {
  final String? baseUrl = dotenv.env['BASE_URL'];
  const storage = FlutterSecureStorage();
  final String? accessToken = await storage.read(key: 'access_token');

  if (baseUrl == null || baseUrl.isEmpty || accessToken == null) {
    print("❌ BASE_URL or access token is not available");
    return false;
  }

  if (contentIds.isEmpty) {
    print("❌ No content IDs provided!");
    return false;
  }

  final String url =
      '$baseUrl/api/v1/content/change/$beforeCategoryId/$afterCategoryId';
  final dynamic contentIdToSend = int.tryParse(contentIds[0]) ?? contentIds[0];

  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(contentIdToSend),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  } catch (e) {
    print("❌ Error moving content: $e");
    return false;
  }
}
