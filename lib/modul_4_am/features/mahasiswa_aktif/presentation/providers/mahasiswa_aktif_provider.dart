import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/mahasiswa_aktif_model.dart';
import '../../data/repositories/mahasiswa_aktif_repository.dart';

final mahasiswaAktifRepositoryProvider =
Provider<MahasiswaAktifRepository>((ref) {
  return MahasiswaAktifRepository();
});

final mahasiswaAktifProvider =
FutureProvider<List<MahasiswaAktifModel>>((ref) async {
  final repo = ref.read(mahasiswaAktifRepositoryProvider);
  return repo.getMahasiswaAktifList();
});