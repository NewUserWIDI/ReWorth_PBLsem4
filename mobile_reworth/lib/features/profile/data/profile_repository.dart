// lib/features/profile/data/profile_repository.dart

import 'dart:io';
import '../domain/bank_account.dart';
import '../domain/profile_user.dart';
import '../domain/reward_item.dart';
import '../domain/seller_application.dart';

abstract class ProfileRepository {
  // Profile methods
  Future<ProfileUser> getProfile();
  Future<ProfileUser?> getProfileById(String userId);

  // Update profile methods
  Future<ProfileUser> updateProfile({
    required String namaLengkap,
    required String noTelp,
    String? fotoProfil,
  });

  // Upload profile photo
  Future<String?> uploadProfilePhoto(File imageFile);

  // Reward methods
  Future<List<RewardItem>> getAvailableRewards();
  Future<bool> redeemReward(int rewardId);

  // Bank account methods
  Future<List<BankAccount>> getBankAccounts();
  Future<void> addBankAccount({
    required String bankName,
    String? cardType,
    required String ownerName,
    required String accountNumber,
    String? expiryDate,
  });
  Future<void> updateBankAccount({
    required String cardId,
    required String bankName,
    String? cardType,
    required String ownerName,
    required String accountNumber,
    String? expiryDate,
  });
  Future<void> deleteBankAccount(String cardId);
  Future<void> setPrimaryBankAccount(String cardId);

  // Seller photo upload
  Future<String?> uploadSellerPhoto(File imageFile, String jenis);

  // Seller application methods
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
  });

  Future<SellerApplication?> getSellerApplicationStatus();
}
