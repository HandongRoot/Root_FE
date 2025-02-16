import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root_app/main.dart';

//chagne modal 용 category 바꾸는 endpoint
Future<bool> changeContentToFolder(
  List<String> contentIds,
  String beforeCategoryId,
  String afterCategoryId,
) async {
  final String? baseUrl = dotenv.env['BASE_URL'];
  if (baseUrl == null || baseUrl.isEmpty) {
    //print("BASE_URL not defined");
    return false;
  }
  final String url =
      '$baseUrl/api/v1/content/change/$userId/$beforeCategoryId/$afterCategoryId';

  final dynamic contentIdToSend = int.tryParse(contentIds[0]) ?? contentIds[0];

  //print("URL: $url");
  //print("Request Body: ${jsonEncode(contentIdToSend)}");

  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(contentIdToSend),
    );
    //print("Response status: ${response.statusCode}");
    //print("Response body: ${response.body}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      //print("Failed to move content. Status code: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    //print("Error moving content: $e");
    return false;
  }
}
