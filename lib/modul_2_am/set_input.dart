import 'dart:io';

void main() {
  Set<String> dataSet = {};

  // Input jumlah data awal
  stdout.write('Masukkan jumlah data awal: ');
  int jumlah = int.parse(stdin.readLineSync()!);

  // Input data awal
  for (int i = 0; i < jumlah; i++) {
    stdout.write('Data ke-${i + 1}: ');
    String input = stdin.readLineSync()!;
    dataSet.add(input);
  }

  // Tampilkan semua data
  print('\n=== SEMUA DATA ===');
  int no = 1;
  for (var data in dataSet) {
    print('$no. $data');
    no++;
  }

  print('Total data: ${dataSet.length}');

  // Tambah data baru
  stdout.write('\nMasukkan data baru: ');
  String tambah = stdin.readLineSync()!;
  dataSet.add(tambah);
  print('Data "$tambah" berhasil ditambahkan!');

  // Hapus data
  stdout.write('\nMasukkan data yang ingin dihapus: ');
  String hapus = stdin.readLineSync()!;
  if (dataSet.remove(hapus)) {
    print('Data "$hapus" berhasil dihapus!');
  } else {
    print('Data "$hapus" tidak ditemukan!');
  }

  // Cek data
  stdout.write('\nMasukkan data yang ingin dicek: ');
  String cek = stdin.readLineSync()!;
  if (dataSet.contains(cek)) {
    print('Data "$cek" ada di Set!');
  } else {
    print('Data "$cek" tidak ada di Set!');
  }

  // Hasil akhir
  print('\n=== HASIL AKHIR ===');
  no = 1;
  for (var data in dataSet) {
    print('$no. $data');
    no++;
  }
  print('Total data: ${dataSet.length}');
}