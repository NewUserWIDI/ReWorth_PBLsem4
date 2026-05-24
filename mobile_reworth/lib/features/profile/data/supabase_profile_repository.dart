import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/profile_user.dart';
import 'profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<ProfileUser> getProfile() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('User belum login');
    }

    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (row == null) {
        final fallback = _fallbackProfileUser(authUser);
        try {
          await _client.from('profiles').upsert({
            'id': authUser.id,
            'nama': fallback.nama,
            'email': fallback.email == '-' ? '' : fallback.email,
            'nomor_hp': authUser.userMetadata?['nomor_hp'] ?? '',
            'foto_profil': '',
            'total_poin': 0,
            'laporan_valid': 0,
            'setor_sampah_kg': 0,
          });
        } catch (_) {
          // Tetap lanjut dengan fallback jika profile belum bisa ditulis.
        }
        return fallback;
      }

      return ProfileUser(
        nama: (row['nama'] as String?) ?? _fallbackProfileUser(authUser).nama,
        email: (row['email'] as String?) ?? authUser.email ?? '-',
        fotoProfil: (row['foto_profil'] as String?) ?? '',
        totalPoin: (row['total_poin'] as num?)?.toInt() ?? 0,
        laporanValid: (row['laporan_valid'] as num?)?.toInt() ?? 0,
        setorSampahKg: (row['setor_sampah_kg'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return _fallbackProfileUser(authUser);
    }
  }

  ProfileUser _fallbackProfileUser(User authUser) {
    return ProfileUser(
      nama: (authUser.userMetadata?['nama'] as String?) ?? 'Pengguna ReWorth',
      email: authUser.email ?? '-',
      fotoProfil: '',
      totalPoin: 0,
      laporanValid: 0,
      setorSampahKg: 0,
    );
  }
}
