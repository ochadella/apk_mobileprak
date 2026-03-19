import 'package:dio/dio.dart';

import '../models/mahasiswa_model.dart';

class MahasiswaRepository {
  final Dio _dio = Dio();

  Future<List<MahasiswaModel>> getMahasiswaList() async {
    try {
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/comments',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => MahasiswaModel.fromJson(e)).toList();
      } else {
        throw Exception(
          'Gagal mengambil data mahasiswa. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data mahasiswa: $e');
    }
  }
}