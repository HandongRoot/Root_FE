import 'dart:convert';

class JwtDecoder {
  static bool isExpired(String? token) {
    if (token == null) return true;

    final parts = token.split('.');
    if (parts.length != 3) return true;

    final payload = base64Url.normalize(parts[1]);
    final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));

    final exp = decoded['exp'];
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return exp - 2 < now; // 2초 여유
  }
}