import 'package:dio/dio.dart';
import 'package:praktikummobile/modul_4_am/core/services/local_storage_service.dart';

class DioClient {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  final Dio _dio;
  final LocalStorageService _localStorage;

  DioClient(this._localStorage)
      : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }
  Dio get dio => _dio;
}