import 'dart:io';
import '../domain/bank_account.dart';
import '../domain/profile_user.dart';
import '../domain/reward_item.dart';

abstract class ProfileRepository {
  // Profile methods
  Future<ProfileUser> getProfile();
  Future<ProfileUser?> getProfileById(String userId);

  // Update profile methods (NEW)
  Future<ProfileUser> updateProfile({
    required String namaLengkap,
    required String noTelp,
    String? fotoProfil,
  });

  // Upload profile photo (NEW)
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
}
