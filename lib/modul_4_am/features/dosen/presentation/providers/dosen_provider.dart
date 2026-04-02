import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:praktikummobile/modul_4_am/core/network/dio_client.dart';
import 'package:praktikummobile/modul_4_am/core/services/local_storage_service.dart';

import '../../data/models/dosen_model.dart';
import '../../data/repositories/dosen_repository.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return DioClient(localStorage);
});

final dosenRepositoryProvider = Provider<DosenRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DosenRepository(dioClient);
});

final dosenProvider = FutureProvider<List<DosenModel>>((ref) async {
  final repo = ref.read(dosenRepositoryProvider);
  return repo.getDosenList();
});

final savedDosenProvider =
FutureProvider<List<Map<String, String>>>((ref) async {
  final storage = ref.read(localStorageServiceProvider);
  return storage.getSavedUsers();
});