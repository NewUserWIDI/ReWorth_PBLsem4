import 'dart:io';

import '../domain/bank_account.dart';
import '../domain/profile_user.dart';
import '../domain/reward_item.dart';
import '../domain/seller_application.dart';

abstract class ProfileRepository {
  Future<ProfileUser> getProfile();
  Future<ProfileUser?> getProfileById(String userId);

  Future<ProfileUser> updateProfile({
    required String namaLengkap,
    required String noTelp,
    String? fotoProfil,
  });

  Future<String?> uploadProfilePhoto(File imageFile);

  Future<List<RewardItem>> getAvailableRewards();
  Future<bool> redeemReward(int rewardId);

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

  Future<String?> uploadSellerPhoto(File imageFile, String jenis);
  Future<SellerApplication?> getLatestSellerApplication();
  Future<SellerApplication?> getSellerApplicationStatus();

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
  });
}
