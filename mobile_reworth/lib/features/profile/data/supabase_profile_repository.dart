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

    final row = await _client
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (row == null) {
      // Fallback: jika row profile belum ada, buat default.
      await _client.from('profiles').insert({
        'id': authUser.id,
        'nama': authUser.userMetadata?['nama'] ?? 'Pengguna ReWorth',
        'email': authUser.email ?? '',
        'nomor_hp': authUser.userMetadata?['nomor_hp'] ?? '',
        'foto_profil': '',
        'total_poin': 0,
        'laporan_valid': 0,
        'setor_sampah_kg': 0,
      });

      return ProfileUser(
        nama: (authUser.userMetadata?['nama'] as String?) ?? 'Pengguna ReWorth',
        email: authUser.email ?? '-',
        fotoProfil: '',
        totalPoin: 0,
        laporanValid: 0,
        setorSampahKg: 0,
      );
    }

    return ProfileUser(
      nama: (row['nama'] as String?) ?? 'Pengguna ReWorth',
      email: (row['email'] as String?) ?? authUser.email ?? '-',
      fotoProfil: (row['foto_profil'] as String?) ?? '',
      totalPoin: (row['total_poin'] as num?)?.toInt() ?? 0,
      laporanValid: (row['laporan_valid'] as num?)?.toInt() ?? 0,
      setorSampahKg: (row['setor_sampah_kg'] as num?)?.toInt() ?? 0,
    );
  }
}
