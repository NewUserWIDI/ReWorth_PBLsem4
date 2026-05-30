import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/profile_repository.dart';
import '../data/supabase_profile_repository.dart';
import 'profile_state.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository(Supabase.instance.client);
});

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      return ProfileController(ref.watch(profileRepositoryProvider));
    });

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this._repository) : super(const ProfileState()) {
    loadProfile();
    loadAvailableRewards();
  }

  final ProfileRepository _repository;

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.getProfile();
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      print('Error loadProfile: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadAvailableRewards() async {
    try {
      final rewards = await _repository.getAvailableRewards();
      state = state.copyWith(availableRewards: rewards);
    } catch (e) {
      print('Error loading rewards: $e');
      state = state.copyWith(availableRewards: []);
    }
  }

  Future<bool> redeemReward(int rewardId) async {
    state = state.copyWith(isRedeeming: true);

    try {
      final success = await _repository.redeemReward(rewardId);
      if (success) {
        await loadProfile(); // Refresh points after successful redemption
        await loadAvailableRewards(); // Refresh rewards list
        return true;
      }
      return false;
    } catch (e) {
      print('Error redeemReward: $e');
      return false;
    } finally {
      state = state.copyWith(isRedeeming: false);
    }
  }
}
