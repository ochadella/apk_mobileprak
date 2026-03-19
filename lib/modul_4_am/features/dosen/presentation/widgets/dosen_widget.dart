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
      ),
    );
  }
}