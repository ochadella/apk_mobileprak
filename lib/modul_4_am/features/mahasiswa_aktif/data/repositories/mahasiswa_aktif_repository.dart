import 'package:dio/dio.dart';

import '../models/mahasiswa_aktif_model.dart';

class MahasiswaAktifRepository {
  final Dio _dio = Dio();

  Future<List<MahasiswaAktifModel>> getMahasiswaAktifList() async {
    try {
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/posts',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => MahasiswaAktifModel.fromJson(e)).toList();
      } else {
        throw Exception(
          'Gagal mengambil data mahasiswa aktif. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data mahasiswa aktif: $e');
    }
  }
}