import 'package:flutter/material.dart';

class MahasiswaPage extends StatelessWidget {
  const MahasiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = const [
      {
        'nama': 'Budi Santoso',
        'nim': '2201001',
        'email': 'budi@student.ac.id',
        'prodi': 'Teknik Informatika',
      },
      {
        'nama': 'Siti Aisyah',
        'nim': '2201002',
        'email': 'siti@student.ac.id',
        'prodi': 'Teknik Informatika',
      },
      {
        'nama': 'Rizky Pratama',
        'nim': '2201003',
        'email': 'rizky@student.ac.id',
        'prodi': 'Sistem Informasi',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Data Mahasiswa")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final mhs = data[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(child: Text(mhs['nama']![0])),
              title: Text(mhs['nama']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NIM : ${mhs['nim']}"),
                  Text(mhs['email']!),
                  Text(mhs['prodi']!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}