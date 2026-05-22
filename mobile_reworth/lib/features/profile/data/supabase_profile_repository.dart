import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/profile_user.dart';
import 'profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final supabase = Supabase.instance.client;

  @override
  Future<ProfileUser> getProfile() async {
    try {
      final currentUser = supabase.auth.currentUser;

      print('CURRENT USER: $currentUser');

      if (currentUser == null) {
        throw Exception('User belum login');
      }

      print('USER ID: ${currentUser.id}');

      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      print('PROFILE RESPONSE: $response');

      if (response == null) {
        throw Exception('Data profile tidak ditemukan');
      }

      return ProfileUser(
        nama: response['nama_lengkap'] ?? '',
        email: response['email'] ?? '',
        fotoProfil: response['foto_profil'] ?? '',
        totalPoin: response['total_poin'] ?? 0,
        laporanValid: response['total_laporan_valid'] ?? 0,
        jumlahPoin: response['total_poin'] ?? 0,
      );
    } catch (e) {
      print('PROFILE ERROR: $e');
      rethrow;
    }
  }
}
