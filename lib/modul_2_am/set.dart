import 'dart:io';

void main() {
  Set<String> bunga = {'Lily', 'Mawar', 'Matahari'};
  print('Bunga: $bunga');

  // Tambah data
  bunga.add('Melati');
  print('Setelah tambah: $bunga');

  // Tambah data duplicate
  bunga.add('Mawar');
  print('Setelah tambah duplicate (Mawar): $bunga');

  // Hapus data
  bunga.remove('Matahari');
  print('Setelah hapus (Matahari): $bunga');

  // Cek data tertentu
  print('Apakah ada Mawar? ${bunga.contains("Mawar")}');

  // Hitung jumlah data
  print('Total data: ${bunga.length}');

  // Tampilkan semua data (loop)
  print('\n=== SEMUA DATA ===');
  int no = 1;
  for (var b in bunga) {
    print('$no. $b');
    no++;
  }
}