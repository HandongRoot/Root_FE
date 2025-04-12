import 'package:dio/dio.dart';
import 'dio_instance.dart';

Future<dynamic> sendRequest({
  required String endpoint,
  String method = 'GET',
  Map<String, dynamic>? data,
}) async {
  try {
    final res = await dio.request(
      endpoint,
      data: data,
      options: Options(method: method),
    );
    return res.data;
  } catch (e) {
    print('❌ API 요청 실패: $e');
    rethrow;
  }
}