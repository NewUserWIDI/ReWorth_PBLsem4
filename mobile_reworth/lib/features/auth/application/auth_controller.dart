import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_action_result.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(Supabase.instance.client);
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

  Future<void> refreshCurrentUser() async {
    _currentUser = _repository.getCurrentUser();
    notifyListeners();
  }

  Future<AuthActionResult> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      print('🔵 Login attempt for: $email');

      final user = await _repository
          .login(email: email.trim(), password: password)
          .timeout(const Duration(seconds: 20));

      if (user == null) {
        print('❌ Login failed: user null');
        return const AuthActionResult(
          success: false,
          message: 'Email atau kata sandi salah',
        );
      }

      _currentUser = user;
      notifyListeners();
      print('✅ Login success for: $email');
      return const AuthActionResult(success: true, message: 'Login berhasil');
    } on AuthException catch (error) {
      print('❌ AuthException: ${error.message}');
      return AuthActionResult(
        success: false,
        message: _authErrorMessage(error.message),
      );
    } catch (e) {
      print('❌ Login error: $e');
      return const AuthActionResult(
        success: false,
        message: 'Login gagal. Periksa koneksi dan data akun Anda.',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthActionResult> register({
    required String nama,
    required String nomorHp,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      print('🔵 ===== STARTING REGISTRATION =====');
      print('🔵 Nama: $nama');
      print('🔵 Email: $email');
      print('🔵 No HP: $nomorHp');

      final user = await _repository
          .register(
            RegisterRequest(
              nama: nama.trim(),
              nomorHp: nomorHp.trim(),
              email: email.trim(),
              password: password,
            ),
          )
          .timeout(const Duration(seconds: 20));

      if (user == null) {
        print('❌ Registration failed: user returned null');
        return const AuthActionResult(
          success: false,
          message: 'Email sudah terdaftar',
        );
      }

      print('✅ Registration user object received');
      _currentUser = user;

      // Delay singkat untuk memastikan profile sudah tersimpan di database
      print('🔵 Waiting 500ms for profile to be saved...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Refresh untuk memastikan data dari tabel profiles terbaca
      print('🔵 Refreshing current user...');
      await refreshCurrentUser();

      notifyListeners();
      print('✅ ===== REGISTRATION COMPLETE =====');
      print('✅ User: ${user.nama}, Email: ${user.email}');

      return const AuthActionResult(
        success: true,
        message: 'Registrasi berhasil',
      );
    } on AuthException catch (error) {
      print('❌ AuthException: ${error.message}');
      return AuthActionResult(
        success: false,
        message: _authErrorMessage(error.message),
      );
    } catch (e) {
      print('❌ Registration error: $e');
      print('❌ Error stack: ${StackTrace.current}');
      return const AuthActionResult(
        success: false,
        message: 'Registrasi gagal. Periksa koneksi dan coba lagi.',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthActionResult> logout() async {
    _setLoading(true);
    try {
      await _repository.logout();
      _currentUser = null;
      notifyListeners();
      return const AuthActionResult(
        success: true,
        message: 'Anda berhasil keluar',
      );
    } catch (e) {
      print('❌ Logout error: $e');
      return const AuthActionResult(success: false, message: 'Gagal keluar');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _authErrorMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('invalid login credentials')) {
      return 'Email atau kata sandi salah';
    }
    if (lower.contains('email rate limit')) {
      return 'Terlalu banyak percobaan. Coba lagi sebentar.';
    }
    if (lower.contains('already registered') ||
        lower.contains('user already registered')) {
      return 'Email sudah terdaftar';
    }
    if (lower.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek inbox Anda terlebih dahulu.';
    }

    return message.isEmpty ? 'Terjadi kesalahan autentikasi' : message;
  }
}
