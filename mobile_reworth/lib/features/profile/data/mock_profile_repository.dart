import 'profile_repository.dart';
import '../domain/profile_summary.dart';

class MockProfileRepository implements ProfileRepository {
  @override
  Future<ProfileSummary> getProfileSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const ProfileSummary(
      nama: 'Demo ReWorth',
      email: 'demo@reworth.app',
      nomorHp: '081234567890',
      totalPoin: 0,
      totalLaporanValid: 0,
    );
  }
}
