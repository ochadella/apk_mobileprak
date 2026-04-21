import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String authBoxName = 'authBox';
  static const String appBoxName = 'appBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(authBoxName);
    await Hive.openBox(appBoxName);
  }

  static Box get authBox => Hive.box(authBoxName);
  static Box get appBox => Hive.box(appBoxName);
}