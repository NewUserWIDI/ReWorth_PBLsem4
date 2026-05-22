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
  }

  final ProfileRepository _repository;

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await _repository.getProfile();
      state = state.copyWith(isLoading: false, user: user);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}
