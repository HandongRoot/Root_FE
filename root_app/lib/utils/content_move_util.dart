import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root_app/main.dart';

//gallery 용 category 바꾸는 endpoint
Future<bool> moveContentToFolder(
    List<String> contentIds, String targetCategoryId) async {
  final String? baseUrl = dotenv.env['BASE_URL'];
  if (baseUrl == null || baseUrl.isEmpty) {
    print('BASE_URL is not defined in .env');
    return false;
  }
  final String url = '$baseUrl/api/v1/content/add/$targetCategoryId';
  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(contentIds),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      print('change folder failed, status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error moving content: $e');
    return false;
  }
}
