import '../domain/bank_account.dart';
import '../domain/profile_user.dart';
import '../domain/reward_item.dart';

abstract class ProfileRepository {
  Future<ProfileUser> getProfile();
  Future<List<RewardItem>> getAvailableRewards();
  Future<bool> redeemReward(int rewardId);
  Future<ProfileUser?> getProfileById(String userId);

  // ========== METHODS FOR BANK ACCOUNTS ==========
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
