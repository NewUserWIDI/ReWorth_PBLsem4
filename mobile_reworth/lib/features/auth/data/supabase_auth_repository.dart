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
    // Logout dulu kalau ada session aktif untuk mencegah data lama tertampil
    if (_client.auth.currentSession != null) {
      await _client.auth.signOut();
    }

    final response = await _client.auth.signUp(
      email: request.email,
      password: request.password,
      data: {'nama': request.nama, 'nomor_hp': request.nomorHp},
    );

    final user = response.user;
    if (user == null) return null;

    // Supabase may return a user without an active session when email
    // confirmation is enabled. For this app flow, registration still enters
    // the app immediately using the signup user data.
    final fallbackUser = _mapToAppUser(user, {
      'nama_lengkap': request.nama,
      'nama': request.nama,
      'no_telp': request.nomorHp,
      'nomor_hp': request.nomorHp,
      'email': request.email,
      'total_poin': 0,
      'laporan_valid': 0,
      'total_laporan_valid': 0,
      'streak_poin': 0,
      'role': 'Masyarakat',
      'status_pengajuan_seller': 'Belum Daftar',
    });

    if (_client.auth.currentSession == null) {
      try {
        await _client.auth.signInWithPassword(
          email: request.email,
          password: request.password,
        );
      } on AuthException {
        return fallbackUser;
      }
    }

    await _tryUpsertProfileRow(
      userId: user.id,
      nama: request.nama,
      email: request.email,
      nomorHp: request.nomorHp,
    );

    final profile = await _readProfileRow(user.id);
    return profile == null ? fallbackUser : _mapToAppUser(user, profile);
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
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return row;
    } catch (_) {
      return null;
    }
  }

  Future<void> _tryUpsertProfileRow({
    required String userId,
    required String nama,
    required String email,
    required String nomorHp,
  }) async {
    try {
      await _client.from('profiles').upsert({
        'id': userId,
        'nama_lengkap': nama,
        'nama': nama,
        'email': email,
        'no_telp': nomorHp,
        'nomor_hp': nomorHp,
        'foto_profil': '',
        'total_poin': 0,
        'laporan_valid': 0,
        'setor_sampah_kg': 0,
        'total_laporan_valid': 0,
        'streak_poin': 0,
        'role': 'Masyarakat',
        'status_pengajuan_seller': 'Belum Daftar',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Auth is the source of truth here; profile can be completed later.
    }
  }

  AppUser _mapToAppUser(User user, Map<String, dynamic>? profile) {
    final metadata = user.userMetadata ?? <String, dynamic>{};

    final nama =
        (profile?['nama_lengkap'] as String?) ??
        (profile?['nama'] as String?) ??
        (metadata['nama'] as String?) ??
        'Pengguna ReWorth';

    final nomorHp =
        (profile?['no_telp'] as String?) ??
        (profile?['nomor_hp'] as String?) ??
        (metadata['nomor_hp'] as String?) ??
        '-';

    final email = (profile?['email'] as String?) ?? user.email ?? '-';

    return AppUser(
      nama: nama,
      nomorHp: nomorHp,
      email: email,
      password: '',
      poin: (profile?['total_poin'] as num?)?.toInt() ?? 0,
      streak: (profile?['streak_poin'] as num?)?.toInt() ?? 0,
      jumlahLaporanValid:
          (profile?['total_laporan_valid'] as num?)?.toInt() ?? 0,
      alamatTersimpan: const [],
      metodePembayaran: const [],
      wishlist: const [],
      cart: const [],
    );
  }
}
