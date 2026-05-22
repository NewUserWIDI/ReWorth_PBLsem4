import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_profile_repository.dart';
import 'profile_state.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      return ProfileController();
    });

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(const ProfileState()) {
    loadProfile();
  }

  final _repository = MockProfileRepository();

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);

    final user = await _repository.getProfile();

    state = state.copyWith(isLoading: false, user: user);
  }
}
