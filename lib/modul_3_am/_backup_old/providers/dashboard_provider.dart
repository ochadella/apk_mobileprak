import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int mahasiswa = 124;
  int dosen = 38;
  int matakuliah = 45;

  void tambahMahasiswa() {
    mahasiswa++;
    notifyListeners();
  }

  void tambahDosen() {
    dosen++;
    notifyListeners();
  }

  void tambahMatakuliah() {
    matakuliah++;
    notifyListeners();
  }
}