import 'dart:io';

void main() {
  List<String> names = ['Ocha', 'Della', 'Fitriani'];
  print('Names: $names');

  names.add('Isna');
  print('Names setelah ditambahkan: $names');

  // f. Tampilkan data pada index tertentu
  print('Elemen pertama: ${names[0]}');
  print('Elemen kedua: ${names[1]}');

  // g. Mengubah data pada index tertentu
  names[1] = 'Andika';
  print('Names setelah diubah: $names');

  // h. Hapus data tertentu
  names.remove('Fitriani');
  print('Names setelah dihapus: $names');

  // i. Hitung jumlah data
  print('Jumlah data: ${names.length}');

  // j. Tampilkan semua data dengan looping
  print('Menampilkan setiap elemen:');
  for (String name in names) {
    print(name);
  }
}