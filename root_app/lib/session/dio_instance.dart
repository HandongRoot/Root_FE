import 'package:dio/dio.dart';
import 'package:root_app/session/token_storage.dart';
import 'package:root_app/session/jwt_decoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final dio = Dio(BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? ''));

void setupDioInterceptors() {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        var token = await TokenStorage.getAccessToken();
        final refreshToken = await TokenStorage.getRefreshToken();

        if (JwtDecoder.isExpired(token)) {
          final refreshRes = await Dio().get(
            '${dotenv.env['BASE_URL']}/auth/refresh',
            options: Options(headers: {'x-refresh-token': refreshToken}),
          );

          final newAccess = refreshRes.headers['authorization']?.first?.split(' ')?.last;
          final newRefresh = refreshRes.headers['x-refresh-token']?.first;

          if (newAccess != null) {
            await TokenStorage.setAccessToken(newAccess);
            token = newAccess;
          }
          if (newRefresh != null) {
            await TokenStorage.setRefreshToken(newRefresh);
          }
        }

        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },

      onError: (error, handler) {
        print('❌ Dio error: ${error.message}');
        return handler.next(error);
      },
    ),
  );
}