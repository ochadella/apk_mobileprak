import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/mahasiswa_model.dart';
import '../providers/mahasiswa_provider.dart';

class MahasiswaCard extends ConsumerWidget {
  final MahasiswaModel mahasiswa;

  const MahasiswaCard({
    super.key,
    required this.mahasiswa,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            mahasiswa.name.isNotEmpty ? mahasiswa.name[0].toUpperCase() : '?',
          ),
        ),
        title: Text(mahasiswa.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mahasiswa.email),
            Text(
              mahasiswa.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text('Post ID: ${mahasiswa.postId} | ID: ${mahasiswa.id}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.save),
          onPressed: () async {
            await ref
                .read(mahasiswaLocalStorageServiceProvider)
                .addUserToSavedList(
              userId: mahasiswa.id.toString(),
              username: mahasiswa.name,
            );

            ref.invalidate(savedMahasiswaProvider);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${mahasiswa.name} disimpan'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}