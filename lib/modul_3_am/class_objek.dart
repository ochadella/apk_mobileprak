// ===============================
// CLASS DASAR
// ===============================

class Mahasiswa {
  String nama;
  String nim;

  Mahasiswa(this.nama, this.nim);

  void tampilkanData() {
    print("Nama: $nama");
    print("NIM: $nim");
  }
}

// ===============================
// EXTENDS (Inheritance)
// ===============================

class MahasiswaAlumni extends Mahasiswa {
  int tahunLulus;

  MahasiswaAlumni(String nama, String nim, this.tahunLulus)
      : super(nama, nim);

  void tampilkanAlumni() {
    tampilkanData();
    print("Tahun Lulus: $tahunLulus");
  }
}

// ===============================
// MIXIN
// ===============================

mixin AktivitasDosen {
  void cekAbsensi() {
    print("Absensi dicek");
  }

  void cekNilai() {
    print("Nilai dicek");
  }

  void cekPublikasi() {
    print("Publikasi dicek");
  }
}

class Dosen with AktivitasDosen {}

// ===============================
// MAIN FUNCTION (Testing)
// ===============================

void main() {
  print("=== MAHASISWA ===");
  var mhs = Mahasiswa("Ocha", "434241070");
  mhs.tampilkanData();

  print("\n=== MAHASISWA ALUMNI ===");
  var alumni = MahasiswaAlumni("Della", "434241071", 2025);
  alumni.tampilkanAlumni();

  print("\n=== DOSEN ===");
  var dosen = Dosen();
  dosen.cekAbsensi();
  dosen.cekNilai();
  dosen.cekPublikasi();
}