import '../domain/profile_user.dart';
import '../domain/reward_item.dart';

class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.user,
    this.availableRewards = const [],
    this.isRedeeming = false,
  });

  final bool isLoading;
  final ProfileUser? user;
  final List<RewardItem> availableRewards;
  final bool isRedeeming;

  ProfileState copyWith({
    bool? isLoading,
    ProfileUser? user,
    List<RewardItem>? availableRewards,
    bool? isRedeeming,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      availableRewards: availableRewards ?? this.availableRewards,
      isRedeeming: isRedeeming ?? this.isRedeeming,
    );
  }
}
