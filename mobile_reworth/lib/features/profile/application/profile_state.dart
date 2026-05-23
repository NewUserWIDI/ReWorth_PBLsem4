import '../domain/profile_user.dart';

class ProfileState {
  const ProfileState({this.isLoading = false, this.user});

  final bool isLoading;
  final ProfileUser? user;

  ProfileState copyWith({bool? isLoading, ProfileUser? user}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
    );
  }
}
