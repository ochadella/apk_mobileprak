import 'package:praktikummobile/modul_4_am/core/network/dio_client.dart';
import '../models/dosen_model.dart';

class DosenRepository {
  final DioClient _dioClient;

  DosenRepository(this._dioClient);

  Future<List<DosenModel>> getDosenList() async {
    try {
      final response = await _dioClient.dio.get('/users');

      final data = response.data as List;

      return data.map((json) {
        return DosenModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data dosen: $e');
    }
  }
}