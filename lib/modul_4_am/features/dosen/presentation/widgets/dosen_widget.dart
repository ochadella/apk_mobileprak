import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dosen_model.dart';
import '../providers/dosen_provider.dart';

class DosenCard extends ConsumerWidget {
  final DosenModel dosen;

  const DosenCard({
    super.key,
    required this.dosen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            dosen.name.isNotEmpty ? dosen.name[0] : '?',
          ),
        ),
        title: Text(dosen.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Username : ${dosen.username}"),
            Text(dosen.email),
            Text(
              "${dosen.address.street}, ${dosen.address.suite}, ${dosen.address.city}",
            ),
            Text("Zipcode : ${dosen.address.zipcode}"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.save),
          onPressed: () async {
            await ref.read(localStorageServiceProvider).addUserToSavedList(
              userId: dosen.id.toString(),
              username: dosen.name,
            );

            ref.invalidate(savedDosenProvider);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${dosen.name} disimpan"),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}