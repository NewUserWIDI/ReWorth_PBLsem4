import '../domain/profile_user.dart';

abstract class ProfileRepository {
  Future<ProfileUser> getProfile();
}
