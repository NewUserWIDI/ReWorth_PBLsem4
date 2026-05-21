import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_profile_repository.dart';
import '../data/profile_repository.dart';
import '../domain/profile_summary.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository();
});

final profileSummaryProvider = FutureProvider<ProfileSummary>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfileSummary();
});
