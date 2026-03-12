import 'package:flutter/material.dart';

class MahasiswaAktifPage extends StatelessWidget {
  const MahasiswaAktifPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = const [
      {
        'nama': 'Andi Saputra',
        'nim': '2202001',
        'status': 'Aktif Semester 4',
      },
      {
        'nama': 'Nabila Putri',
        'nim': '2202002',
        'status': 'Aktif Semester 4',
      },
      {
        'nama': 'Fajar Ramadhan',
        'nim': '2202003',
        'status': 'Aktif Semester 6',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Mahasiswa Aktif")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person_outline),
              ),
              title: Text(item['nama']!),
              subtitle: Text("NIM: ${item['nim']} • ${item['status']}"),
            ),
          );
        },
      ),
    );
  }
}