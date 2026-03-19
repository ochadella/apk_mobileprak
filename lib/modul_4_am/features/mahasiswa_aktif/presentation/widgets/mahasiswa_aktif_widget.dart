import 'package:flutter/material.dart';

import '../../data/models/mahasiswa_aktif_model.dart';

class MahasiswaAktifCard extends StatelessWidget {
  final MahasiswaAktifModel mahasiswaAktif;

  const MahasiswaAktifCard({
    super.key,
    required this.mahasiswaAktif,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            mahasiswaAktif.title.isNotEmpty
                ? mahasiswaAktif.title[0].toUpperCase()
                : '?',
          ),
        ),
        title: Text(
          mahasiswaAktif.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mahasiswaAktif.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text('User ID: ${mahasiswaAktif.userId} | ID: ${mahasiswaAktif.id}'),
          ],
        ),
      ),
    );
  }
}