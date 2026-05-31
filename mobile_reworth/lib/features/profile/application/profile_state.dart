import '../domain/bank_account.dart';
import '../domain/profile_user.dart';
import '../domain/reward_item.dart';

class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.user,
    this.availableRewards = const [],
    this.isRedeeming = false,
    // Bank account states
    this.bankAccounts = const [],
    this.isLoadingBankAccounts = false,
    this.isAddingBankAccount = false,
    this.isUpdatingBankAccount = false,
    this.isDeletingBankAccount = false,
    this.isSettingPrimaryBank = false,
  });

  final bool isLoading;
  final ProfileUser? user;
  final List<RewardItem> availableRewards;
  final bool isRedeeming;

  final List<BankAccount> bankAccounts;
  final bool isLoadingBankAccounts;
  final bool isAddingBankAccount;
  final bool isUpdatingBankAccount;
  final bool isDeletingBankAccount;
  final bool isSettingPrimaryBank;

  ProfileState copyWith({
    bool? isLoading,
    ProfileUser? user,
    List<RewardItem>? availableRewards,
    bool? isRedeeming,
    List<BankAccount>? bankAccounts,
    bool? isLoadingBankAccounts,
    bool? isAddingBankAccount,
    bool? isUpdatingBankAccount,
    bool? isDeletingBankAccount,
    bool? isSettingPrimaryBank,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      availableRewards: availableRewards ?? this.availableRewards,
      isRedeeming: isRedeeming ?? this.isRedeeming,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      isLoadingBankAccounts:
          isLoadingBankAccounts ?? this.isLoadingBankAccounts,
      isAddingBankAccount: isAddingBankAccount ?? this.isAddingBankAccount,
      isUpdatingBankAccount:
          isUpdatingBankAccount ?? this.isUpdatingBankAccount,
      isDeletingBankAccount:
          isDeletingBankAccount ?? this.isDeletingBankAccount,
      isSettingPrimaryBank: isSettingPrimaryBank ?? this.isSettingPrimaryBank,
    );
  }
}
