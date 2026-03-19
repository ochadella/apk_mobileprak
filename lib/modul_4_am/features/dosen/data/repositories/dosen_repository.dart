import 'package:dio/dio.dart';

import '../models/dosen_model.dart';

class DosenRepository {
  final Dio _dio = Dio();

  Future<List<DosenModel>> getDosenList() async {
    try {
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/users',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => DosenModel.fromJson(e)).toList();
      } else {
        throw Exception(
          'Gagal mengambil data dosen. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data dosen: $e');
    }
  }
}