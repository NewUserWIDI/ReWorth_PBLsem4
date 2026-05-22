import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_profile_repository.dart';
import 'profile_state.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>(
      (ref) => ProfileController(),
    );

class ProfileController extends StateNotifier<ProfileState> {
  final _repository = SupabaseProfileRepository();

  ProfileController() : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      state = state.copyWith(isLoading: true);

      final user = await _repository.getProfile();

      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      print('PROFILE ERROR: $e');

      state = state.copyWith(isLoading: false);
    }
  }
}
