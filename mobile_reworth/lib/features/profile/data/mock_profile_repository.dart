import '../domain/profile_user.dart';
import 'profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  @override
  Future<ProfileUser> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const ProfileUser(
      nama: 'Fatma Azzahhra',
      email: 'fatma@gmail.com',
      fotoProfil: 'https://i.pravatar.cc/300',
      totalPoin: 1271,
      laporanValid: 18,
      setorSampahKg: 37,
    );
  }
}
