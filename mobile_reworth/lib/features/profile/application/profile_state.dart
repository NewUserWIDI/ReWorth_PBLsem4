import '../domain/bank_account.dart';
import '../domain/profile_user.dart';
import '../domain/reward_item.dart';
import '../domain/seller_application.dart';

class ProfileState {
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
  final SellerApplication? sellerApplication;
  final bool isLoadingSellerApplication;
  final bool isSubmittingSellerApplication;
  final String? sellerApplicationErrorMessage;

  // fields for edit profile
  final bool isUpdatingProfile;
  final String? updateErrorMessage;

  const ProfileState({
    this.isLoading = false,
    this.user,
    this.availableRewards = const [],
    this.isRedeeming = false,
    this.bankAccounts = const [],
    this.isLoadingBankAccounts = false,
    this.isAddingBankAccount = false,
    this.isUpdatingBankAccount = false,
    this.isDeletingBankAccount = false,
    this.isSettingPrimaryBank = false,
    this.sellerApplication,
    this.isLoadingSellerApplication = false,
    this.isSubmittingSellerApplication = false,
    this.sellerApplicationErrorMessage,
    this.isUpdatingProfile = false,
    this.updateErrorMessage,
  });

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
    SellerApplication? sellerApplication,
    bool? isLoadingSellerApplication,
    bool? isSubmittingSellerApplication,
    String? sellerApplicationErrorMessage,
    bool? isUpdatingProfile,
    String? updateErrorMessage,
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
      sellerApplication: sellerApplication ?? this.sellerApplication,
      isLoadingSellerApplication:
          isLoadingSellerApplication ?? this.isLoadingSellerApplication,
      isSubmittingSellerApplication:
          isSubmittingSellerApplication ?? this.isSubmittingSellerApplication,
      sellerApplicationErrorMessage:
          sellerApplicationErrorMessage ?? this.sellerApplicationErrorMessage,
      isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
      updateErrorMessage: updateErrorMessage ?? this.updateErrorMessage,
    );
  }
}
