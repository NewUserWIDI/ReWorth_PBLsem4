import '../domain/app_user.dart';

class RegisterRequest {
  const RegisterRequest({
    required this.nama,
    required this.nomorHp,
    required this.email,
    required this.password,
  });

  final String nama;
  final String nomorHp;
  final String email;
  final String password;
}

abstract class AuthRepository {
  Future<AppUser?> login({required String email, required String password});
  Future<AppUser?> register(RegisterRequest request);
  Future<void> logout();
  AppUser? getCurrentUser();
}
