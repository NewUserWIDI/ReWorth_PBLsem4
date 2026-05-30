import '../domain/profile_user.dart';
import '../domain/reward_item.dart';

abstract class ProfileRepository {
  Future<ProfileUser> getProfile();
  Future<List<RewardItem>> getAvailableRewards();
  Future<bool> redeemReward(int rewardId);
  Future<ProfileUser?> getProfileById(String userId);
}
