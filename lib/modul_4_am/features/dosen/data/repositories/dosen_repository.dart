import '../models/dosen_model.dart';

class DosenRepository {

  Future<List<DosenModel>> getDosenList() async {

    await Future.delayed(const Duration(seconds: 1));

    return [

      DosenModel(
        nama: "Anank Prasetyo",
        nip: "123456789",
        email: "anank@example.com",
        jurusan: "Teknik Informatika",
      ),

      DosenModel(
        nama: "Rachman Sinatriya",
        nip: "987654321",
        email: "rachman@example.com",
        jurusan: "Teknik Informatika",
      ),

      DosenModel(
        nama: "Alfian Sukma",
        nip: "456789123",
        email: "alfian@example.com",
        jurusan: "Teknik Informatika",
      ),

    ];
  }
}