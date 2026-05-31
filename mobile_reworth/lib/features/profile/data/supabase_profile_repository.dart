import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/bank_account.dart';
import '../domain/profile_user.dart';
import '../domain/reward_item.dart';
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
        final newProfile = ProfileUser(
          id: authUser.id,
          nama:
              authUser.userMetadata?['nama_lengkap'] as String? ??
              authUser.userMetadata?['nama'] as String? ??
              'Pengguna ReWorth',
          email: authUser.email ?? '-',
          noTelp: authUser.userMetadata?['no_telp'] as String? ?? '',
          fotoProfil: '',
          totalPoin: 0,
          totalLaporanValid: 0,
          setorSampahKg: 0,
          role: 'user',
          statusPengajuanSeller: 'pending',
        );

        try {
          await _client.from('profiles').insert({
            'id': authUser.id,
            'nama_lengkap': newProfile.nama,
            'email': newProfile.email,
            'no_telp': newProfile.noTelp,
            'total_poin': 0,
            'total_laporan_valid': 0,
            'role': 'user',
            'status_pengajuan_seller': 'pending',
          });
        } catch (e) {
          print('Error creating profile: $e');
        }
        return newProfile;
      }

      return ProfileUser(
        id: row['id'] as String,
        nama:
            (row['nama_lengkap'] as String?) ??
            (row['nama'] as String?) ??
            'Pengguna ReWorth',
        email: row['email'] as String? ?? authUser.email ?? '-',
        noTelp:
            (row['no_telp'] as String?) ?? (row['nomor_hp'] as String?) ?? '',
        fotoProfil: row['foto_profil'] as String? ?? '',
        totalPoin: (row['total_poin'] as num?)?.toInt() ?? 0,
        totalLaporanValid:
            (row['total_laporan_valid'] as num?)?.toInt() ??
            (row['laporan_valid'] as num?)?.toInt() ??
            0,
        setorSampahKg: (row['setor_sampah_kg'] as num?)?.toInt() ?? 0,
        role: row['role'] as String? ?? 'user',
        statusPengajuanSeller:
            row['status_pengajuan_seller'] as String? ?? 'pending',
      );
    } catch (e) {
      print('Error getProfile: $e');
      rethrow;
    }
  }

  @override
  Future<ProfileUser?> getProfileById(String userId) async {
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (row == null) return null;

      return ProfileUser(
        id: row['id'] as String,
        nama:
            (row['nama_lengkap'] as String?) ??
            (row['nama'] as String?) ??
            'Pengguna ReWorth',
        email: row['email'] as String? ?? '-',
        noTelp:
            (row['no_telp'] as String?) ?? (row['nomor_hp'] as String?) ?? '',
        fotoProfil: row['foto_profil'] as String? ?? '',
        totalPoin: (row['total_poin'] as num?)?.toInt() ?? 0,
        totalLaporanValid:
            (row['total_laporan_valid'] as num?)?.toInt() ??
            (row['laporan_valid'] as num?)?.toInt() ??
            0,
        setorSampahKg: (row['setor_sampah_kg'] as num?)?.toInt() ?? 0,
        role: row['role'] as String? ?? 'user',
        statusPengajuanSeller:
            row['status_pengajuan_seller'] as String? ?? 'pending',
      );
    } catch (e) {
      print('Error getProfileById: $e');
      return null;
    }
  }

  @override
  Future<List<RewardItem>> getAvailableRewards() async {
    try {
      final response = await _client
          .from('reward')
          .select('*')
          .eq('status_reward', 'Aktif')
          .order('poin_dibutuhkan');

      return response
          .map<RewardItem>((json) => RewardItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getAvailableRewards: $e');
      return [];
    }
  }

  @override
  Future<bool> redeemReward(int rewardId) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return false;

    try {
      final rewardResponse = await _client
          .from('reward')
          .select('*')
          .eq('id_reward', rewardId)
          .single();

      final reward = RewardItem.fromJson(rewardResponse);
      final pointsRequired = reward.poinDibutuhkan;

      final profileResponse = await _client
          .from('profiles')
          .select('total_poin, no_telp, nama_lengkap')
          .eq('id', authUser.id)
          .single();

      final currentPoints =
          (profileResponse['total_poin'] as num?)?.toInt() ?? 0;

      if (currentPoints < pointsRequired) {
        return false;
      }

      final userPhone = (profileResponse['no_telp'] as String?) ?? '';

      if (userPhone.isEmpty) {
        print('User phone number is required for redemption');
        return false;
      }

      final now = DateTime.now();
      final kodeReferensi = _generateReferenceCode();

      await _client.from('penukaran_poin').insert({
        'id_masyarakat': authUser.id,
        'id_reward': rewardId,
        'no_hp_tujuan': userPhone,
        'poin_terpakai': pointsRequired,
        'status_proses': 'Pending',
        'kode_referensi': kodeReferensi,
        'tanggal_penukaran': now.toIso8601String(),
      });

      final newPoints = currentPoints - pointsRequired;
      await _client
          .from('profiles')
          .update({
            'total_poin': newPoints,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', authUser.id);

      await _client.from('riwayat_poin').insert({
        'id_masyarakat': authUser.id,
        'jenis_transaksi': 'Keluar',
        'sumber_poin': 'Tukar Reward: ${reward.namaReward}',
        'jumlah_poin': pointsRequired,
        'saldo_setelah': newPoints,
        'keterangan': 'Penukaran ${reward.namaReward} - ${reward.description}',
        'tanggal': now.toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error redeemReward: $e');
      return false;
    }
  }

  String _generateReferenceCode() {
    return 'RWD-${DateTime.now().millisecondsSinceEpoch}';
  }

  // ========== BANK ACCOUNT METHODS ==========

  @override
  Future<List<BankAccount>> getBankAccounts() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return [];

    try {
      final response = await _client
          .from('kartu_pembayaran')
          .select()
          .eq('id_masyarakat', authUser.id)
          .eq('status_aktif', true)
          .order('kartu_utama', ascending: false)
          .order('created_at', ascending: false);

      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map((row) => BankAccount.fromJson(row)).toList();
    } catch (e) {
      print('Error getBankAccounts: $e');
      return [];
    }
  }

  @override
  Future<void> addBankAccount({
    required String bankName,
    String? cardType,
    required String ownerName,
    required String accountNumber,
    String? expiryDate,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('User tidak ditemukan');

    // Pastikan profile ada
    await _ensureProfileExists(authUser.id, authUser.email ?? '');

    // Cek apakah ini kartu pertama, jika ya maka set sebagai primary
    final existingAccounts = await getBankAccounts();
    final isPrimary = existingAccounts.isEmpty;

    // Ambil last 4 digit dari nomor rekening
    final cleanNumber = accountNumber.replaceAll(RegExp(r'\s+'), '');
    final last4 = cleanNumber.length >= 4
        ? cleanNumber.substring(cleanNumber.length - 4)
        : cleanNumber.padLeft(4, '0');

    final payload = {
      'id_masyarakat': authUser.id,
      'nama_bank': bankName,
      'jenis_kartu': cardType ?? 'Debit',
      'nama_pemilik': ownerName,
      'last4_digit': last4,
      'expiry_date': expiryDate,
      'kartu_utama': isPrimary,
      'status_aktif': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client.from('kartu_pembayaran').insert(payload);
  }

  @override
  Future<void> updateBankAccount({
    required String cardId,
    required String bankName,
    String? cardType,
    required String ownerName,
    required String accountNumber,
    String? expiryDate,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('User tidak ditemukan');

    final cleanNumber = accountNumber.replaceAll(RegExp(r'\s+'), '');
    final last4 = cleanNumber.length >= 4
        ? cleanNumber.substring(cleanNumber.length - 4)
        : cleanNumber.padLeft(4, '0');

    final payload = {
      'nama_bank': bankName,
      'jenis_kartu': cardType ?? 'Debit',
      'nama_pemilik': ownerName,
      'last4_digit': last4,
      'expiry_date': expiryDate,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client
        .from('kartu_pembayaran')
        .update(payload)
        .eq('id_kartu', int.parse(cardId))
        .eq('id_masyarakat', authUser.id);
  }

  @override
  Future<void> deleteBankAccount(String cardId) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('User tidak ditemukan');

    await _client
        .from('kartu_pembayaran')
        .update({
          'status_aktif': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id_kartu', int.parse(cardId))
        .eq('id_masyarakat', authUser.id);
  }

  @override
  Future<void> setPrimaryBankAccount(String cardId) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('User tidak ditemukan');

    await _client
        .from('kartu_pembayaran')
        .update({
          'kartu_utama': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id_masyarakat', authUser.id);

    // Set kartu yang dipilih sebagai utama
    await _client
        .from('kartu_pembayaran')
        .update({
          'kartu_utama': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id_kartu', int.parse(cardId))
        .eq('id_masyarakat', authUser.id);
  }

  // ========== HELPER METHODS ==========

  Future<void> _ensureProfileExists(String userId, String email) async {
    try {
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        print('🔵 Profile not found for user: $userId, creating now...');

        await _client.from('profiles').insert({
          'id': userId,
          'nama_lengkap': 'Pengguna ReWorth',
          'email': email,
          'no_telp': '',
          'total_poin': 0,
          'total_laporan_valid': 0,
          'role': 'user',
          'status_pengajuan_seller': 'pending',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        print('✅ Profile created successfully for user: $userId');
      }
    } catch (e) {
      print('⚠️ Error in _ensureProfileExists: $e');
    }
  }
}
