import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_user.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) return null;

    final profile = await _readProfileRow(user.id);
    return _mapToAppUser(user, profile);
  }

  @override
  Future<AppUser?> register(RegisterRequest request) async {
    final response = await _client.auth.signUp(
      email: request.email,
      password: request.password,
      data: {
        'nama': request.nama,
        'nomor_hp': request.nomorHp,
      },
    );

    final user = response.user;
    if (user == null) return null;

    await _upsertProfileRow(
      userId: user.id,
      nama: request.nama,
      email: request.email,
      nomorHp: request.nomorHp,
    );

    final profile = await _readProfileRow(user.id);
    return _mapToAppUser(user, profile);
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  AppUser? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final metadata = user.userMetadata ?? <String, dynamic>{};
    return AppUser(
      nama: (metadata['nama'] as String?) ?? 'Pengguna ReWorth',
      nomorHp: (metadata['nomor_hp'] as String?) ?? '-',
      email: user.email ?? '-',
      password: '',
      poin: 0,
      streak: 0,
      jumlahLaporanValid: 0,
      alamatTersimpan: const [],
      metodePembayaran: const [],
      wishlist: const [],
      cart: const [],
    );
  }

  Future<Map<String, dynamic>?> _readProfileRow(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return row;
  }

  Future<void> _upsertProfileRow({
    required String userId,
    required String nama,
    required String email,
    required String nomorHp,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'nama': nama,
      'email': email,
      'nomor_hp': nomorHp,
      'foto_profil': '',
      'total_poin': 0,
      'laporan_valid': 0,
      'setor_sampah_kg': 0,
    });
  }

  AppUser _mapToAppUser(User user, Map<String, dynamic>? profile) {
    final metadata = user.userMetadata ?? <String, dynamic>{};

    final nama = (profile?['nama'] as String?) ??
        (metadata['nama'] as String?) ??
        'Pengguna ReWorth';
    final nomorHp = (profile?['nomor_hp'] as String?) ??
        (metadata['nomor_hp'] as String?) ??
        '-';
    final email = (profile?['email'] as String?) ?? user.email ?? '-';

    return AppUser(
      nama: nama,
      nomorHp: nomorHp,
      email: email,
      password: '',
      poin: (profile?['total_poin'] as num?)?.toInt() ?? 0,
      streak: 0,
      jumlahLaporanValid: (profile?['laporan_valid'] as num?)?.toInt() ?? 0,
      alamatTersimpan: const [],
      metodePembayaran: const [],
      wishlist: const [],
      cart: const [],
    );
  }
}
