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
    // Logout dulu kalau ada session aktif
    if (_client.auth.currentSession != null) {
      await _client.auth.signOut();
    }

    final response = await _client.auth.signUp(
      email: request.email,
      password: request.password,
      data: {'nama_lengkap': request.nama, 'no_telp': request.nomorHp},
    );

    final user = response.user;
    if (user == null) return null;

    // Auto login setelah registrasi jika session belum aktif
    if (_client.auth.currentSession == null) {
      try {
        await _client.auth.signInWithPassword(
          email: request.email,
          password: request.password,
        );
      } on AuthException {
        // Jika auto login gagal, tetap lanjut
      }
    }

    // Insert ke tabel profiles
    await _insertProfileRow(
      userId: user.id,
      nama: request.nama,
      email: request.email,
      noTelp: request.nomorHp,
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

    return AppUser(
      nama:
          user.userMetadata?['nama_lengkap'] as String? ??
          user.userMetadata?['nama'] as String? ??
          'Pengguna ReWorth',
      nomorHp:
          user.userMetadata?['no_telp'] as String? ??
          user.userMetadata?['nomor_hp'] as String? ??
          '-',
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
    } catch (e) {
      print('❌ _readProfileRow error: $e');
      return null;
    }
  }

  Future<void> _insertProfileRow({
    required String userId,
    required String nama,
    required String email,
    required String noTelp,
  }) async {
    print('🔵 Inserting profile for user: $userId');

    try {
      // Coba insert dengan data minimal
      await _client.from('profiles').insert({
        'id': userId,
        'nama_lengkap': nama,
        'no_telp': noTelp,
        'email': email,
        'role': 'user',
        'status_pengajuan_seller': null,
      });
      print('✅ Profile inserted successfully');
    } catch (e) {
      print('❌ ERROR inserting profile: $e');

      // Jika gagal, coba lagi dengan cara berbeda (tanpa role)
      try {
        print('🔵 Retry without role...');
        await _client.from('profiles').insert({
          'id': userId,
          'nama_lengkap': nama,
          'no_telp': noTelp,
          'email': email,
          'status_pengajuan_seller': null,
        });

        // Update role setelah insert
        await _client
            .from('profiles')
            .update({'role': 'user'})
            .eq('id', userId);

        print('✅ Profile inserted and updated successfully');
      } catch (e2) {
        print('❌ Second attempt also failed: $e2');
        rethrow;
      }
    }
  }

  AppUser _mapToAppUser(User user, Map<String, dynamic>? profile) {
    final nama =
        (profile?['nama_lengkap'] as String?) ??
        (profile?['nama'] as String?) ??
        user.userMetadata?['nama_lengkap'] as String? ??
        user.userMetadata?['nama'] as String? ??
        'Pengguna ReWorth';

    final nomorHp =
        (profile?['no_telp'] as String?) ??
        (profile?['nomor_hp'] as String?) ??
        user.userMetadata?['no_telp'] as String? ??
        user.userMetadata?['nomor_hp'] as String? ??
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
