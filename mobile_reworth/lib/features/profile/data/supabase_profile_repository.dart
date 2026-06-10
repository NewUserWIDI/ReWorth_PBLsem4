import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/bank_account.dart';
import '../domain/profile_user.dart';
import '../domain/reward_item.dart';
import 'profile_repository.dart';
import '../domain/seller_application.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  // ========== PROFILE METHODS ==========

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
        final now = DateTime.now();
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
          streakPoin: 0,
          setorSampahKg: 0,
          role: 'user',
          statusPengajuanSeller: null,
          createdAt: now,
        );

        try {
          await _client.from('profiles').insert({
            'id': authUser.id,
            'nama_lengkap': newProfile.nama,
            'no_telp': newProfile.noTelp,
            'email': newProfile.email,
            'role': 'user',
            'nama': newProfile.nama,
            'nomor_hp': newProfile.noTelp,
            'streak_poin': 0,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          });
        } catch (e) {
          print('Error creating profile: $e');
        }
        return newProfile;
      }

      return ProfileUser.fromJson(row);
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
      return ProfileUser.fromJson(row);
    } catch (e) {
      print('Error getProfileById: $e');
      return null;
    }
  }

  @override
  Future<ProfileUser> updateProfile({
    required String namaLengkap,
    required String noTelp,
    String? fotoProfil,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('User belum login');
    }

    try {
      final updateData = {
        'nama_lengkap': namaLengkap,
        'no_telp': noTelp,
        'nama': namaLengkap,
        'nomor_hp': noTelp,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fotoProfil != null && fotoProfil.isNotEmpty) {
        updateData['foto_profil'] = fotoProfil;
      }

      await _client.from('profiles').update(updateData).eq('id', authUser.id);

      return await getProfile();
    } catch (e) {
      print('Error updateProfile: $e');
      rethrow;
    }
  }

  @override
  Future<String?> uploadProfilePhoto(File imageFile) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    try {
      final Uint8List fileBytes = await imageFile.readAsBytes();

      if (fileBytes.isEmpty || fileBytes.length < 100) {
        print('❌ File terlalu kecil atau kosong');
        return null;
      }

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${authUser.id}_$timestamp.jpg';
      const String bucket = 'profil';

      print(
        '📤 Uploading $fileName (${fileBytes.length} bytes) to bucket: $bucket',
      );

      await _client.storage
          .from(bucket)
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final publicUrl = _client.storage.from(bucket).getPublicUrl(fileName);
      print('✅ Upload success: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploadProfilePhoto: $e');
      return null;
    }
  }

  // ========== REWARD METHODS ==========

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
          .select('total_poin, no_telp, nomor_hp, nama_lengkap')
          .eq('id', authUser.id)
          .single();

      final currentPoints =
          (profileResponse['total_poin'] as num?)?.toInt() ?? 0;

      if (currentPoints < pointsRequired) {
        return false;
      }

      final userPhone =
          (profileResponse['no_telp'] as String?)?.trim().isNotEmpty == true
          ? (profileResponse['no_telp'] as String).trim()
          : ((profileResponse['nomor_hp'] as String?) ?? '').trim();

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

      try {
        await _client.from('riwayat_poin').insert({
          'id_masyarakat': authUser.id,
          'jenis_transaksi': 'Keluar',
          'sumber_poin': 'Tukar Reward: ${reward.namaReward}',
          'jumlah_poin': pointsRequired,
          'saldo_setelah': newPoints,
          'keterangan':
              'Penukaran ${reward.namaReward} - ${reward.description}',
          'tanggal': now.toIso8601String(),
        });
      } catch (e) {
        print('Warning riwayat_poin insert failed: $e');
      }

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
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 8));

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

    await _ensureProfileExists(authUser.id, authUser.email ?? '');

    final existingAccounts = await getBankAccounts();
    final isPrimary = existingAccounts.isEmpty;

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
          'no_telp': '',
          'email': email,
          'role': 'user',
          'nama': 'Pengguna ReWorth',
          'nomor_hp': '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        print('✅ Profile created successfully for user: $userId');
      }
    } catch (e) {
      print('⚠️ Error in _ensureProfileExists: $e');
    }
  }

  // ========== UPLOAD SELLER PHOTO ==========

  @override
  Future<String?> uploadSellerPhoto(File imageFile, String jenis) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    try {
      final Uint8List fileBytes = await imageFile.readAsBytes();

      if (fileBytes.isEmpty || fileBytes.length < 100) {
        print('❌ File terlalu kecil atau kosong');
        return null;
      }

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'seller_${authUser.id}_${jenis}_$timestamp.jpg';
      const String bucket = 'seller_documents';

      await _client.storage
          .from(bucket)
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final publicUrl = _client.storage.from(bucket).getPublicUrl(fileName);
      print('✅ Upload seller photo success: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploadSellerPhoto: $e');
      return null;
    }
  }

  // ========== SELLER APPLICATION METHODS ==========

  @override
  Future<SellerApplication?> getLatestSellerApplication() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    try {
      final result = await _client
          .from('pengajuan_seller')
          .select()
          .eq('id_masyarakat', authUser.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (result == null) return null;
      return SellerApplication.fromJson(result);
    } catch (e) {
      print('Error getLatestSellerApplication: $e');
      return null;
    }
  }

  @override
  Future<SellerApplication?> getSellerApplicationStatus() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    try {
      final result = await _client
          .from('pengajuan_seller')
          .select()
          .eq('id_masyarakat', authUser.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (result == null) return null;
      return SellerApplication.fromJson(result);
    } catch (e) {
      print('Error getSellerApplicationStatus: $e');
      return null;
    }
  }

  @override
  Future<void> submitSellerApplication({
    required String namaTokoUsulan,
    String? deskripsiToko,
    String? alamatToko,
    String? kategoriJualan,
    String? jenisProdukJualan,
    required String usernameUsulan,
    required String passwordHashUsulan,
    String? fotoToko,
    String? fotoProdukContoh,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('User belum login');
    }

    print('🔵 SUBMIT: Untuk user ${authUser.id}');
    print('   Nama Toko: $namaTokoUsulan');
    print('   Username: $usernameUsulan');
    print('   Foto Toko: $fotoToko');
    print('   Foto Produk: $fotoProdukContoh');

    // Cek apakah sudah ada pengajuan Pending
    final existingApplication = await getSellerApplicationStatus();
    if (existingApplication != null &&
        existingApplication.statusPengajuan == 'Pending') {
      print(
        '❌ Ada pengajuan Pending sebelumnya: ${existingApplication.idPengajuan}',
      );
      throw Exception('Anda sudah memiliki pengajuan yang sedang diproses');
    }

    final now = DateTime.now();

    // Update status_pengajuan_seller di profiles menjadi 'pending'
    print('🟡 Mengupdate profile status ke pending...');
    await _client
        .from('profiles')
        .update({
          'status_pengajuan_seller': 'pending',
          'updated_at': now.toIso8601String(),
        })
        .eq('id', authUser.id);

    // Insert pengajuan
    print('🟡 Insert ke pengajuan_seller...');
    await _client.from('pengajuan_seller').insert({
      'id_masyarakat': authUser.id,
      'nama_toko_usulan': namaTokoUsulan,
      'deskripsi_toko': deskripsiToko,
      'alamat_toko': alamatToko,
      'kategori_jualan': kategoriJualan,
      'jenis_produk_jualan': jenisProdukJualan,
      'username_usulan': usernameUsulan,
      'password_hash_usulan': passwordHashUsulan,
      'foto_toko': fotoToko,
      'foto_produk_contoh': fotoProdukContoh,
      'status_pengajuan': 'Pending',
      'tanggal_pengajuan': now.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    print('✅ SUBMIT: Berhasil!');
  }
}
