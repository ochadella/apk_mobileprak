import '../models/mahasiswa_aktif_model.dart';

class MahasiswaAktifRepository {
  Future<List<MahasiswaAktifModel>> getMahasiswaAktifList() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      MahasiswaAktifModel(
        userId: 1,
        id: 1,
        title: 'sunt aut facere repellat provident occaecati',
        body: 'quia et suscipit suscipit recusandae consequuntur expedita',
      ),
      MahasiswaAktifModel(
        userId: 1,
        id: 2,
        title: 'qui est esse',
        body: 'est rerum tempore vitae sequi sint nihil reprehenderit',
      ),
      MahasiswaAktifModel(
        userId: 1,
        id: 3,
        title: 'ea molestias quasi exercitationem repellat',
        body: 'et iusto sed quo iure voluptatem occaecati omnis eligendi',
      ),
    ];
  }
}