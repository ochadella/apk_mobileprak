import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.anonKey,
    );
  }
}
