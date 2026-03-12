import 'dart:io';

void main() {
  // Data awal
  Map<String, String> data = {
    'Ocha': '081234567890',
    'Isna': '082345678901',
    'Andika': '083456789012',
  };

  print('Data awal: $data');

  // c. Tambah data
  data['Ody'] = '084567890123';
  print('Data setelah ditambahkan: $data');

  // d. Tampilkan data berdasarkan key
  print('Nomor Ocha: ${data['Ocha']}');

}