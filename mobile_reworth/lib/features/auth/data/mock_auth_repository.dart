import '../domain/app_user.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    final demo = AppUser(
      nama: 'Demo ReWorth',
      nomorHp: '081234567890',
      email: 'demo@reworth.app',
      password: 'password123',
      poin: 0,
      streak: 0,
      jumlahLaporanValid: 0,
      alamatTersimpan: const [],
      metodePembayaran: const [],
      wishlist: const [],
      cart: const [],
    );
    _users.add(demo);
  }

  final List<AppUser> _users = [];
  AppUser? _sessionUser;

  @override
  Future<AppUser?> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    for (final user in _users) {
      if (user.email.toLowerCase() == email.toLowerCase() && user.password == password) {
        _sessionUser = user;
        return user;
      }
    }
    return null;
  }

  @override
  Future<AppUser?> register(RegisterRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final exists = _users.any((u) => u.email.toLowerCase() == request.email.toLowerCase());
    if (exists) {
      return null;
    }

    final user = AppUser(
      nama: request.nama,
      nomorHp: request.nomorHp,
      email: request.email,
      password: request.password,
      poin: 0,
      streak: 0,
      jumlahLaporanValid: 0,
      alamatTersimpan: const [],
      metodePembayaran: const [],
      wishlist: const [],
      cart: const [],
    );

    _users.add(user);
    _sessionUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    _sessionUser = null;
  }

  @override
  AppUser? getCurrentUser() => _sessionUser;
}
