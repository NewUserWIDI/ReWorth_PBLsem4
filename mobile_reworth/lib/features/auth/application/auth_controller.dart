import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/mock_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_action_result.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    _currentUser = _repository.getCurrentUser();
  }

  final AuthRepository _repository;

  bool _isLoading = false;
  AppUser? _currentUser;

  bool get isLoading => _isLoading;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<AuthActionResult> login({required String email, required String password}) async {
    _setLoading(true);
    final user = await _repository.login(email: email.trim(), password: password);
    _setLoading(false);

    if (user == null) {
      return const AuthActionResult(success: false, message: 'Email atau kata sandi salah');
    }

    _currentUser = user;
    notifyListeners();
    return const AuthActionResult(success: true, message: 'Login berhasil');
  }

  Future<AuthActionResult> register({
    required String nama,
    required String nomorHp,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    final user = await _repository.register(
      RegisterRequest(
        nama: nama.trim(),
        nomorHp: nomorHp.trim(),
        email: email.trim(),
        password: password,
      ),
    );
    _setLoading(false);

    if (user == null) {
      return const AuthActionResult(success: false, message: 'Email sudah terdaftar');
    }

    _currentUser = user;
    notifyListeners();
    return const AuthActionResult(success: true, message: 'Registrasi berhasil');
  }

  Future<AuthActionResult> logout() async {
    _setLoading(true);
    await _repository.logout();
    _currentUser = null;
    _setLoading(false);
    notifyListeners();
    return const AuthActionResult(success: true, message: 'Anda berhasil keluar');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
