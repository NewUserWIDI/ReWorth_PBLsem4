import '../domain/profile_user.dart';

class ProfileState {
  final bool isLoading;
  final ProfileUser? user;

  ProfileState({this.isLoading = false, this.user});

  ProfileState copyWith({bool? isLoading, ProfileUser? user}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
    );
  }
}
