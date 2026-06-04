// lib/features/profile/application/profile_controller.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/profile_repository.dart';
import '../data/supabase_profile_repository.dart';
import 'profile_state.dart';
import '../domain/seller_application.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository(Supabase.instance.client);
});

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      return ProfileController(ref.watch(profileRepositoryProvider));
    });

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this._repository) : super(const ProfileState()) {
    loadProfile();
    loadAvailableRewards();
    loadBankAccounts();
  }

  final ProfileRepository _repository;

  // ========== PROFILE METHODS ==========

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.getProfile();
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      print('Error loadProfile: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<String?> uploadProfilePhoto(File imageFile) async {
    try {
      return await _repository.uploadProfilePhoto(imageFile);
    } catch (e) {
      print('Error uploadProfilePhoto: $e');
      return null;
    }
  }

  Future<bool> updateProfile({
    required String namaLengkap,
    required String noTelp,
    String? fotoProfil,
  }) async {
    state = state.copyWith(isUpdatingProfile: true, updateErrorMessage: null);

    try {
      final updatedUser = await _repository.updateProfile(
        namaLengkap: namaLengkap,
        noTelp: noTelp,
        fotoProfil: fotoProfil,
      );

      state = state.copyWith(isUpdatingProfile: false, user: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdatingProfile: false,
        updateErrorMessage: e.toString(),
      );
      return false;
    }
  }

  void clearUpdateError() {
    state = state.copyWith(updateErrorMessage: null);
  }

  // ========== REWARD METHODS ==========

  Future<void> loadAvailableRewards() async {
    try {
      final rewards = await _repository.getAvailableRewards();
      state = state.copyWith(availableRewards: rewards);
    } catch (e) {
      print('Error loading rewards: $e');
      state = state.copyWith(availableRewards: []);
    }
  }

  Future<bool> redeemReward(int rewardId) async {
    state = state.copyWith(isRedeeming: true);

    try {
      final success = await _repository.redeemReward(rewardId);
      if (success) {
        await loadProfile();
        await loadAvailableRewards();
        return true;
      }
      return false;
    } catch (e) {
      print('Error redeemReward: $e');
      return false;
    } finally {
      state = state.copyWith(isRedeeming: false);
    }
  }

  // ========== BANK ACCOUNT METHODS ==========

  Future<void> loadBankAccounts() async {
    state = state.copyWith(isLoadingBankAccounts: true);
    try {
      final accounts = await _repository.getBankAccounts();
      state = state.copyWith(
        isLoadingBankAccounts: false,
        bankAccounts: accounts,
      );
    } catch (e) {
      print('Error loadBankAccounts: $e');
      state = state.copyWith(isLoadingBankAccounts: false, bankAccounts: []);
    }
  }

  Future<bool> addBankAccount({
    required String bankName,
    String? cardType,
    required String ownerName,
    required String accountNumber,
    String? expiryDate,
  }) async {
    state = state.copyWith(isAddingBankAccount: true);
    try {
      await _repository.addBankAccount(
        bankName: bankName,
        cardType: cardType,
        ownerName: ownerName,
        accountNumber: accountNumber,
        expiryDate: expiryDate,
      );
      await loadBankAccounts();
      return true;
    } catch (e) {
      print('Error addBankAccount: $e');
      return false;
    } finally {
      state = state.copyWith(isAddingBankAccount: false);
    }
  }

  Future<bool> updateBankAccount({
    required String cardId,
    required String bankName,
    String? cardType,
    required String ownerName,
    required String accountNumber,
    String? expiryDate,
  }) async {
    state = state.copyWith(isUpdatingBankAccount: true);
    try {
      await _repository.updateBankAccount(
        cardId: cardId,
        bankName: bankName,
        cardType: cardType,
        ownerName: ownerName,
        accountNumber: accountNumber,
        expiryDate: expiryDate,
      );
      await loadBankAccounts();
      return true;
    } catch (e) {
      print('Error updateBankAccount: $e');
      return false;
    } finally {
      state = state.copyWith(isUpdatingBankAccount: false);
    }
  }

  Future<bool> deleteBankAccount(String cardId) async {
    state = state.copyWith(isDeletingBankAccount: true);
    try {
      await _repository.deleteBankAccount(cardId);
      await loadBankAccounts();
      return true;
    } catch (e) {
      print('Error deleteBankAccount: $e');
      return false;
    } finally {
      state = state.copyWith(isDeletingBankAccount: false);
    }
  }

  Future<bool> setPrimaryBankAccount(String cardId) async {
    state = state.copyWith(isSettingPrimaryBank: true);
    try {
      await _repository.setPrimaryBankAccount(cardId);
      await loadBankAccounts();
      return true;
    } catch (e) {
      print('Error setPrimaryBankAccount: $e');
      return false;
    } finally {
      state = state.copyWith(isSettingPrimaryBank: false);
    }
  }

  // ========== SELLER APPLICATION METHODS ==========

  Future<String?> uploadSellerPhoto(File imageFile, String jenis) async {
    try {
      return await _repository.uploadSellerPhoto(imageFile, jenis);
    } catch (e) {
      print('Error uploadSellerPhoto: $e');
      return null;
    }
  }

  Future<bool> submitSellerApplication({
    required String namaTokoUsulan,
    String? deskripsiToko,
    String? alamatToko,
    String? kategoriJualan,
    String? jenisProdukJualan,
    required String usernameUsulan,
    required String passwordHashUsulan,
    String? fotoToko,
    String? fotoProdukContoh,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.submitSellerApplication(
        namaTokoUsulan: namaTokoUsulan,
        deskripsiToko: deskripsiToko,
        alamatToko: alamatToko,
        kategoriJualan: kategoriJualan,
        jenisProdukJualan: jenisProdukJualan,
        usernameUsulan: usernameUsulan,
        passwordHashUsulan: passwordHashUsulan,
        fotoToko: fotoToko,
        fotoProdukContoh: fotoProdukContoh,
      );

      await loadProfile();
      return true;
    } catch (e) {
      print('Error submitSellerApplication: $e');
      state = state.copyWith(updateErrorMessage: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<SellerApplication?> getSellerApplicationStatus() async {
    try {
      return await _repository.getSellerApplicationStatus();
    } catch (e) {
      print('Error getSellerApplicationStatus: $e');
      return null;
    }
  }

  // HAPUS: Future<bool> cancelSellerApplication() ... (tidak ada)
}
