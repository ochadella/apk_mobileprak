import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dosen_provider.dart';
import '../widgets/dosen_widget.dart';

class DosenPage extends ConsumerWidget {
  const DosenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dosenAsync = ref.watch(dosenProvider);
    final savedAsync = ref.watch(savedDosenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Dosen"),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(dosenProvider);
              ref.invalidate(savedDosenProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Data Tersimpan di Local Storage",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          savedAsync.when(
            data: (savedData) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (savedData.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Belum ada data tersimpan"),
                        ),
                      )
                    else
                      ...savedData.map((item) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.bookmark),
                          title: Text(item['username'] ?? ''),
                          subtitle: Text("ID: ${item['user_id'] ?? ''}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await ref
                                  .read(localStorageServiceProvider)
                                  .removeSavedUser(item['user_id'] ?? '');

                              ref.invalidate(savedDosenProvider);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                    Text("${item['username']} dihapus"),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      }),
                    if (savedData.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            await ref
                                .read(localStorageServiceProvider)
                                .clearSavedUsers();

                            ref.invalidate(savedDosenProvider);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Semua data dihapus"),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.delete_sweep,
                              color: Colors.red),
                          label: const Text(
                            "Hapus Semua",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(err.toString()),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daftar Dosen",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: dosenAsync.when(
              data: (data) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final dosen = data[index];
                    return DosenCard(dosen: dosen);
                  },
                );
              },
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },
              error: (err, stack) {
                return Center(child: Text(err.toString()));
              },
            ),
          ),
        ],
      ),
    );
  }
}