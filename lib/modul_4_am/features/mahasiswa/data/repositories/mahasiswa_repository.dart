import 'package:praktikummobile/modul_4_am/core/network/dio_client.dart';
import '../models/mahasiswa_model.dart';

class MahasiswaRepository {
  final DioClient _dioClient;

  MahasiswaRepository(this._dioClient);

  Future<List<MahasiswaModel>> getMahasiswaList() async {
    try {
      final response = await _dioClient.dio.get('/comments');
      final data = response.data as List;

      return data.map((json) {
        return MahasiswaModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data mahasiswa: $e');
    }
  }
}