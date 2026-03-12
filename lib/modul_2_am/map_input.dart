import 'dart:io';

void main() {
  // =========================
  // INPUT SINGLE MAHASISWA
  print('=== INPUT DATA MAHASISWA ===');
  stdout.write('Masukkan NIM: ');
  String nim = stdin.readLineSync()!;
  stdout.write('Masukkan Nama: ');
  String nama = stdin.readLineSync()!;
  stdout.write('Masukkan Jurusan: ');
  String jurusan = stdin.readLineSync()!;
  stdout.write('Masukkan IPK: ');
  double ipk = double.parse(stdin.readLineSync()!);

  Map<String, dynamic> mhsSingle = {
    'nim': nim,
    'nama': nama,
    'jurusan': jurusan,
    'ipk': ipk,
  };

  print('\nData Mahasiswa: $mhsSingle');

  // =========================
  // INPUT MULTIPLE MAHASISWA
  print('\n=== INPUT MULTIPLE MAHASISWA ===');
  stdout.write('Masukkan jumlah mahasiswa: ');
  int jumlah = int.parse(stdin.readLineSync()!);

  Map<String, Map<String, dynamic>> dataMahasiswa = {};

  for (int i = 0; i < jumlah; i++) {
    print('\n--- Mahasiswa ke-${i + 1} ---');
    stdout.write('NIM: ');
    String nim2 = stdin.readLineSync()!;
    stdout.write('Nama: ');
    String nama2 = stdin.readLineSync()!;
    stdout.write('Jurusan: ');
    String jurusan2 = stdin.readLineSync()!;
    stdout.write('IPK: ');
    double ipk2 = double.parse(stdin.readLineSync()!);

    dataMahasiswa[nim2] = {
      'nama': nama2,
      'jurusan': jurusan2,
      'ipk': ipk2,
    };
  }

  // Tampilkan hasil
  print('\n=== DATA MAHASISWA ===');
  dataMahasiswa.forEach((nimKey, detail) {
    print('NIM     : $nimKey');
    print('Nama    : ${detail['nama']}');
    print('Jurusan : ${detail['jurusan']}');
    print('IPK     : ${detail['ipk']}');
    print('-------------------------\n');
  });

  print('Total mahasiswa: ${dataMahasiswa.length}');
}