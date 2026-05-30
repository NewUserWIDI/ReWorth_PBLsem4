import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/profile_controller.dart';
import '../../domain/reward_item.dart';

class RewardsPage extends ConsumerStatefulWidget {
  const RewardsPage({super.key});

  @override
  ConsumerState<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends ConsumerState<RewardsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Pulsa', 'Kuota'];

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primarySoft = Color(0xFF81C784);
  static const Color accentGold = Color(0xFFD4A056);
  static const Color bgDark = Color(0xFF1A2E22);
  static const Color bgCard = Color(0xFF243B2A);
  static const Color textWhite = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFFB8C9B2);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileControllerProvider.notifier).loadAvailableRewards();
      ref.read(profileControllerProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RewardItem> _getFilteredRewards(List<RewardItem> rewards) {
    var filtered = rewards;

    if (_selectedCategory != 'Semua') {
      filtered = filtered
          .where((r) => r.jenisReward == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (r) =>
                r.namaReward.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                r.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  void _showRedeemDialog(RewardItem reward) {
    final state = ref.read(profileControllerProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: primarySoft.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.card_giftcard, color: primaryLight),
            const SizedBox(width: 8),
            const Text(
              'Tukar Reward',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Yakin ingin menukarkan ${reward.poinDibutuhkan} poin untuk',
              style: TextStyle(color: textWhite.withValues(alpha: 0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              reward.namaReward,
              style: TextStyle(
                color: primaryLight,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              reward.description,
              style: TextStyle(color: textGrey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Poin Anda', style: TextStyle(color: textGrey)),
                  Row(
                    children: [
                      Icon(Icons.star, color: accentGold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${state.user?.totalPoin ?? 0}',
                        style: TextStyle(
                          color: accentGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: textGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => Center(
                  child: CircularProgressIndicator(color: primaryLight),
                ),
              );

              final success = await ref
                  .read(profileControllerProvider.notifier)
                  .redeemReward(reward.idReward);

              if (context.mounted) Navigator.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Berhasil menukar ${reward.namaReward}!'
                          : 'Gagal menukar reward. Pastikan no HP sudah diisi dan poin cukup!',
                    ),
                    backgroundColor: success
                        ? primaryGreen
                        : Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                if (success) {
                  ref
                      .read(profileControllerProvider.notifier)
                      .loadAvailableRewards();
                  ref.read(profileControllerProvider.notifier).loadProfile();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ya, Tukar'),
          ),
        ],
      ),
    );
  }

  // CARD REWARD YANG LEBIH INFORMATIF
  Widget _buildRewardCard(
    RewardItem reward,
    int totalPoints,
    bool isRedeeming,
  ) {
    final canRedeem = totalPoints >= reward.poinDibutuhkan;

    final List<Color> gradientColors = reward.jenisReward == 'Pulsa'
        ? [const Color(0xFF1B3A4A), const Color(0xFF0F2A3A)]
        : [const Color(0xFF1A3A2A), const Color(0xFF0F2A1E)];

    final IconData rewardIcon = reward.jenisReward == 'Pulsa'
        ? Icons.phone_android_rounded
        : Icons.wifi_rounded;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(
          color: canRedeem
              ? primaryLight.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canRedeem && !isRedeeming
              ? () => _showRedeemDialog(reward)
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon dan badge poin
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(rewardIcon, color: primaryLight, size: 28),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: primaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reward.poinDibutuhkan}',
                            style: TextStyle(
                              color: primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Nama Reward
                Text(
                  reward.namaReward,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Provider & Nominal (lebih informatif)
                Text(
                  reward.description,
                  style: TextStyle(color: textGrey, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),
                const SizedBox(height: 10),

                // Tombol Tukar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: canRedeem
                        ? primaryGreen
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      canRedeem ? 'Tukar Reward' : 'Poin Kurang',
                      style: TextStyle(
                        color: canRedeem
                            ? Colors.white
                            : textGrey.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final totalPoints = state.user?.totalPoin ?? 0;
    final allRewards = state.availableRewards;
    final isLoading = state.isLoading;
    final filteredRewards = _getFilteredRewards(allRewards);

    return Scaffold(
      backgroundColor: bgDark,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        title: const Text(
          'Tukar Poin Reward',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header poin card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primarySoft.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: accentGold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Poin',
                          style: TextStyle(color: textGrey, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$totalPoints',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Tersedia',
                      style: TextStyle(
                        color: primaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari reward...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.grey.shade500,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: primaryLight, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Category chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;

                    return FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : 'Semua';
                        });
                      },
                      backgroundColor: isSelected ? primaryGreen : Colors.white,
                      selectedColor: primaryGreen,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? primaryGreen : Colors.grey.shade300,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Grid Rewards
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (filteredRewards.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: textGrey.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Reward "$_searchQuery" tidak ditemukan'
                            : 'Belum ada reward tersedia',
                        style: TextStyle(
                          color: textGrey.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: filteredRewards.length,
                itemBuilder: (context, index) {
                  final reward = filteredRewards[index];
                  return _buildRewardCard(
                    reward,
                    totalPoints,
                    state.isRedeeming,
                  );
                },
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
