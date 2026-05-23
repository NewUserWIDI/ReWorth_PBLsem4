import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
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
=======

import '../data/mock_profile_repository.dart';
import 'profile_state.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      return ProfileController();
    });

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(ProfileState()) {
    loadProfile();
  }

  final _repository = MockProfileRepository();
>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);

<<<<<<< HEAD
    try {
      final user = await _repository.getProfile();
      state = state.copyWith(isLoading: false, user: user);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
=======
    final user = await _repository.getProfile();

    state = state.copyWith(isLoading: false, user: user);
>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
  }
}
