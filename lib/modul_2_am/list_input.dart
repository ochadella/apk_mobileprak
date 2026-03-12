import 'dart:io';

void main() {
  // Membuat list kosong
  List<String> dataList = [];
  print('Data list kosong: $dataList');

  // Input jumlah data
  int count = 0;
  while (count <= 0) {
    stdout.write('Masukkan jumlah list: ');
    String? input = stdin.readLineSync();
    try {
      count = int.parse(input!);
      if (count <= 0) {
        print('Masukkan angka lebih dari 0!');
      }
    } catch (e) {
      print('Input tidak valid!');
    }
  }

  // Input data
  for (int i = 0; i < count; i++) {
    stdout.write('Data ke-${i + 1}: ');
    String? x = stdin.readLineSync();
    dataList.add(x!);
  }

  // Tampilkan semua data awal
  print('\n=== SEMUA DATA AWAL ===');
  for (int i = 0; i < dataList.length; i++) {
    print('Index $i: ${dataList[i]}');
  }

  // ===============================
  // TAMPIL BERDASARKAN INDEX
  stdout.write('\nMasukkan index yang ingin ditampilkan: ');
  int idxShow = int.parse(stdin.readLineSync()!);

  if (idxShow >= 0 && idxShow < dataList.length) {
    print('Data index $idxShow: ${dataList[idxShow]}');
  } else {
    print('Index tidak valid!');
  }

  // EEEEEE===============================
  // UBAH BERDASARKAN INDEX
  stdout.write('\nMasukkan index yang ingin diubah: ');
  int idxEdit = int.parse(stdin.readLineSync()!);

  if (idxEdit >= 0 && idxEdit < dataList.length) {
    stdout.write('Masukkan nilai baru: ');
    String newValue = stdin.readLineSync()!;
    dataList[idxEdit] = newValue;
    print('Berhasil diubah!');
  } else {
    print('Index tidak valid!');
  }

  // ===============================
  // HAPUS BERDASARKAN INDEX
  stdout.write('\nMasukkan index yang ingin dihapus: ');
  int idxDel = int.parse(stdin.readLineSync()!);

  if (idxDel >= 0 && idxDel < dataList.length) {
    dataList.removeAt(idxDel);
    print('Berhasil dihapus!');
  } else {
    print('Index tidak valid!');
  }

  // ===============================
  // HASIL AKHIR
  print('\n=== HASIL AKHIR ===');
  for (int i = 0; i < dataList.length; i++) {
    print('Index $i: ${dataList[i]}');
  }
}