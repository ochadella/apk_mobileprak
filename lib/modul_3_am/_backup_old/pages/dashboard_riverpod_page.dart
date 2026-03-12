import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_riverpod_provider.dart';

class DashboardRiverpodPage extends ConsumerWidget {
  const DashboardRiverpodPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mahasiswa = ref.watch(mahasiswaProvider);
    final dosen = ref.watch(dosenProvider);
    final matakuliah = ref.watch(matakuliahProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard (Riverpod)"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _item("Mahasiswa", mahasiswa, () {
              ref.read(mahasiswaProvider.notifier).state++;
            }),
            const SizedBox(height: 12),
            _item("Dosen", dosen, () {
              ref.read(dosenProvider.notifier).state++;
            }),
            const SizedBox(height: 12),
            _item("Mata Kuliah", matakuliah, () {
              ref.read(matakuliahProvider.notifier).state++;
            }),
          ],
        ),
      ),
    );
  }

  Widget _item(String title, int total, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              "Total: $total",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}