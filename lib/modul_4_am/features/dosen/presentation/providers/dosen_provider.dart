import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dosen_model.dart';
import '../../data/repositories/dosen_repository.dart';

final dosenRepositoryProvider =
Provider((ref) => DosenRepository());

final dosenProvider =
FutureProvider<List<DosenModel>>((ref) async {

  final repo = ref.read(dosenRepositoryProvider);

  return repo.getDosenList();
});