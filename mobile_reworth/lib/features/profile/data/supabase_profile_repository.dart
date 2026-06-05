import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/bank_account.dart';
import '../domain/profile_user.dart';
import '../domain/reward_item.dart';
import '../domain/seller_application.dart';
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
          setorSampahKg: 0,
          role: 'Masyarakat',
          statusPengajuanSeller: 'Belum Daftar',
          createdAt: now,
        );

        try {
          await _client.from('profiles').insert({
            'id': authUser.id,
            'nama_lengkap': newProfile.nama,
            'nama': newProfile.nama,
            'email': newProfile.email,
            'no_telp': newProfile.noTelp,
            'nomor_hp': newProfile.noTelp,
            'foto_profil': '',
            'total_poin': 0,
            'total_laporan_valid': 0,
            'laporan_valid': 0,
            'streak_poin': 0,
            'setor_sampah_kg': 0,
            'role': 'Masyarakat',
            'status_pengajuan_seller': 'Belum Daftar',
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
      final updateData = <String, dynamic>{
        'nama_lengkap': namaLengkap,
        'nama': namaLengkap,
        'no_telp': noTelp,
        'nomor_hp': noTelp,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fotoProfil != null) {
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
      final fileBytes = await imageFile.readAsBytes();
      if (fileBytes.isEmpty || fileBytes.length < 100) {
        print('File terlalu kecil atau kosong');
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${authUser.id}_$timestamp.jpg';
      const bucket = 'profil';

      await _client.storage.from(bucket).uploadBinary(
        fileName,
        fileBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );

      return _client.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      print('Error uploadProfilePhoto: $e');
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
      if (currentPoints < pointsRequired) return false;

      final userPhone = (profileResponse['no_telp'] as String?) ?? '';
      if (userPhone.isEmpty) return false;

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
      return rows.map(BankAccount.fromJson).toList();
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

    await _client.from('kartu_pembayaran').insert({
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
    });
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

    await _client
        .from('kartu_pembayaran')
        .update({
          'nama_bank': bankName,
          'jenis_kartu': cardType ?? 'Debit',
          'nama_pemilik': ownerName,
          'last4_digit': last4,
          'expiry_date': expiryDate,
          'updated_at': DateTime.now().toIso8601String(),
        })
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

  @override
  Future<String?> uploadSellerPhoto(File imageFile, String jenis) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    try {
      final fileBytes = await imageFile.readAsBytes();
      if (fileBytes.isEmpty || fileBytes.length < 100) {
        print('File terlalu kecil atau kosong');
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'seller_${authUser.id}_${jenis}_$timestamp.jpg';
      const bucket = 'seller_documents';

      await _client.storage.from(bucket).uploadBinary(
        fileName,
        fileBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
      );

      return _client.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      print('Error uploadSellerPhoto: $e');
      return null;
    }
  }

  @override
  Future<SellerApplication?> getLatestSellerApplication() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    try {
      final row = await _client
          .from('pengajuan_seller')
          .select()
          .eq('id_masyarakat', authUser.id)
          .order('tanggal_pengajuan', ascending: false)
          .limit(1)
          .maybeSingle();

      if (row == null) return null;
      return SellerApplication.fromJson(row);
    } catch (e) {
      print('Error getLatestSellerApplication: $e');
      rethrow;
    }
  }

  @override
  Future<SellerApplication?> getSellerApplicationStatus() async {
    try {
      return await getLatestSellerApplication();
    } catch (e) {
      print('Error getSellerApplicationStatus: $e');
      return null;
    }
  }

  @override
  Future<void> submitSellerApplication({
    String? fullName,
    String? phone,
    String? email,
    String? storeName,
    String? storeDescription,
    String? storeAddress,
    String? category,
    String? productTypes,
    String? usernameProposal,
    String? passwordProposal,
    String? namaTokoUsulan,
    String? deskripsiToko,
    String? alamatToko,
    String? kategoriJualan,
    String? jenisProdukJualan,
    String? usernameUsulan,
    String? passwordHashUsulan,
    String? fotoToko,
    String? fotoProdukContoh,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('User belum login');
    }

    final existing = await getLatestSellerApplication();
    if (existing != null && (existing.isPending || existing.isApproved)) {
      throw Exception(
        'Pengajuan seller Anda masih aktif. Silakan cek detail pengajuan di profil.',
      );
    }

    final bankAccounts = await getBankAccounts();
    if (bankAccounts.isEmpty) {
      throw Exception(
        'Tambahkan akun bank terlebih dahulu untuk rekening pencairan seller.',
      );
    }

    final resolvedFullName =
        fullName ??
        authUser.userMetadata?['nama_lengkap'] as String? ??
        authUser.userMetadata?['nama'] as String?;
    final resolvedPhone =
        phone ?? authUser.userMetadata?['no_telp'] as String?;
    final resolvedEmail = email ?? authUser.email ?? '';
    final resolvedStoreName = storeName ?? namaTokoUsulan;
    final resolvedStoreDescription = storeDescription ?? deskripsiToko ?? '';
    final resolvedStoreAddress = storeAddress ?? alamatToko ?? '';
    final resolvedCategory = category ?? kategoriJualan ?? '';
    final resolvedProductTypes = productTypes ?? jenisProdukJualan ?? '';
    final resolvedUsername = usernameProposal ?? usernameUsulan;
    final resolvedPassword = passwordProposal ?? passwordHashUsulan;

    if (resolvedStoreName == null || resolvedStoreName.trim().isEmpty) {
      throw Exception('Nama toko wajib diisi.');
    }
    if (resolvedUsername == null || resolvedUsername.trim().isEmpty) {
      throw Exception('Username dashboard wajib diisi.');
    }
    if (resolvedPassword == null || resolvedPassword.trim().isEmpty) {
      throw Exception('Password dashboard wajib diisi.');
    }

    await _ensureProfileExists(authUser.id, resolvedEmail);

    final now = DateTime.now().toIso8601String();
    await _client.from('pengajuan_seller').insert({
      'id_masyarakat': authUser.id,
      'nama_toko_usulan': resolvedStoreName,
      'deskripsi_toko': resolvedStoreDescription,
      'alamat_toko': resolvedStoreAddress,
      'kategori_jualan': resolvedCategory,
      'jenis_produk_jualan': resolvedProductTypes,
      'foto_toko': fotoToko ?? '',
      'foto_produk_contoh': fotoProdukContoh ?? '',
      'username_usulan': resolvedUsername,
      'password_hash_usulan': resolvedPassword,
      'status_pengajuan': 'Pending',
      'alasan_penolakan': '',
      'tanggal_pengajuan': now,
      'created_at': now,
      'updated_at': now,
    });

    try {
      await _client
          .from('profiles')
          .update({
            if (resolvedFullName != null && resolvedFullName.isNotEmpty)
              'nama_lengkap': resolvedFullName,
            if (resolvedFullName != null && resolvedFullName.isNotEmpty)
              'nama': resolvedFullName,
            if (resolvedEmail.isNotEmpty) 'email': resolvedEmail,
            if (resolvedPhone != null) 'no_telp': resolvedPhone,
            if (resolvedPhone != null) 'nomor_hp': resolvedPhone,
            'status_pengajuan_seller': 'Pending',
            'updated_at': now,
          })
          .eq('id', authUser.id);
    } catch (e) {
      print('Error update profile after seller application: $e');
    }
  }

  Future<void> _ensureProfileExists(String userId, String email) async {
    try {
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        await _client.from('profiles').insert({
          'id': userId,
          'nama_lengkap': 'Pengguna ReWorth',
          'nama': 'Pengguna ReWorth',
          'email': email,
          'no_telp': '',
          'nomor_hp': '',
          'foto_profil': '',
          'total_poin': 0,
          'total_laporan_valid': 0,
          'laporan_valid': 0,
          'streak_poin': 0,
          'setor_sampah_kg': 0,
          'role': 'Masyarakat',
          'status_pengajuan_seller': 'Belum Daftar',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error in _ensureProfileExists: $e');
    }
  }

  String _generateReferenceCode() {
    return 'RWD-${DateTime.now().millisecondsSinceEpoch}';
  }
}
