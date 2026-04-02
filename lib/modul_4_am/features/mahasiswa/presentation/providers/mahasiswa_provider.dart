import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:praktikummobile/modul_4_am/core/network/dio_client.dart';
import 'package:praktikummobile/modul_4_am/core/services/local_storage_service.dart';

import '../../data/models/mahasiswa_model.dart';
import '../../data/repositories/mahasiswa_repository.dart';

final mahasiswaLocalStorageServiceProvider =
Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final mahasiswaDioClientProvider = Provider<DioClient>((ref) {
  final localStorage = ref.watch(mahasiswaLocalStorageServiceProvider);
  return DioClient(localStorage);
});

final mahasiswaRepositoryProvider = Provider<MahasiswaRepository>((ref) {
  final dioClient = ref.watch(mahasiswaDioClientProvider);
  return MahasiswaRepository(dioClient);
});

final mahasiswaProvider = FutureProvider<List<MahasiswaModel>>((ref) async {
  final repo = ref.read(mahasiswaRepositoryProvider);
  return repo.getMahasiswaList();
});

final savedMahasiswaProvider =
FutureProvider<List<Map<String, String>>>((ref) async {
  final storage = ref.read(mahasiswaLocalStorageServiceProvider);
  return storage.getSavedUsers();
});