import 'package:flutter/material.dart';

import '../../data/models/mahasiswa_model.dart';

class MahasiswaCard extends StatelessWidget {
  final MahasiswaModel mahasiswa;

  const MahasiswaCard({
    super.key,
    required this.mahasiswa,
  });

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}