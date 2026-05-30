import 'package:supabase_flutter/supabase_flutter.dart';

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
        // Buat profile baru jika belum ada
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
          role: 'Masyarakat',
          statusPengajuanSeller: 'Belum Daftar',
        );

        try {
          await _client.from('profiles').insert({
            'id': authUser.id,
            'nama_lengkap': newProfile.nama,
            'email': newProfile.email,
            'no_telp': newProfile.noTelp,
            'total_poin': 0,
            'total_laporan_valid': 0,
            'role': 'Masyarakat',
            'status_pengajuan_seller': 'Belum Daftar',
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
        role: row['role'] as String? ?? 'Masyarakat',
        statusPengajuanSeller:
            row['status_pengajuan_seller'] as String? ?? 'Belum Daftar',
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
        role: row['role'] as String? ?? 'Masyarakat',
        statusPengajuanSeller:
            row['status_pengajuan_seller'] as String? ?? 'Belum Daftar',
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
      return []; // Return empty list instead of mock data
    }
  }

  @override
  Future<bool> redeemReward(int rewardId) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return false;

    try {
      // 1. Get reward details
      final rewardResponse = await _client
          .from('reward')
          .select('*')
          .eq('id_reward', rewardId)
          .single();

      final reward = RewardItem.fromJson(rewardResponse);
      final pointsRequired = reward.poinDibutuhkan;

      // 2. Get current user points
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

      // 3. Get user phone number (required for penukaran_poin)
      final userPhone = (profileResponse['no_telp'] as String?) ?? '';

      if (userPhone.isEmpty) {
        print('User phone number is required for redemption');
        return false;
      }

      // 4. Create redemption record in penukaran_poin table
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

      // 5. Update user points in profiles table
      final newPoints = currentPoints - pointsRequired;
      await _client
          .from('profiles')
          .update({
            'total_poin': newPoints,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', authUser.id);

      // 6. Create points history record in riwayat_poin table
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
}
