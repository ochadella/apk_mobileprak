import 'package:flutter/material.dart';
import '../../data/models/dosen_model.dart';

class DosenCard extends StatelessWidget {

  final DosenModel dosen;

  const DosenCard({
    super.key,
    required this.dosen,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(

        leading: CircleAvatar(
          child: Text(dosen.nama[0]),
        ),

        title: Text(dosen.nama),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("NIP : ${dosen.nip}"),
            Text(dosen.email),
            Text(dosen.jurusan),
          ],
        ),

      ),
    );
  }
}