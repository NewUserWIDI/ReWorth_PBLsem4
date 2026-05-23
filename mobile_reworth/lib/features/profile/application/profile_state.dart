import '../domain/profile_user.dart';

class ProfileState {
<<<<<<< HEAD
  const ProfileState({this.isLoading = false, this.user});

  final bool isLoading;
  final ProfileUser? user;

=======
  final bool isLoading;
  final ProfileUser? user;

  ProfileState({this.isLoading = false, this.user});

>>>>>>> e6c0d4058b20247b1e099610751b5cafa9f02321
  ProfileState copyWith({bool? isLoading, ProfileUser? user}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
    );
  }
}
