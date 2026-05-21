import '../domain/profile_summary.dart';

abstract class ProfileRepository {
  Future<ProfileSummary> getProfileSummary();
}
