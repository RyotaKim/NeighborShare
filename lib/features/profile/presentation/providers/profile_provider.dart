import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

// Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    SupabaseService.client,
    ref.watch(storageServiceProvider),
  );
});

// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(SupabaseService.client);
});

// Current User's Profile Provider
final currentProfileProvider = StreamProvider<ProfileModel?>((ref) async* {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(profileRepositoryProvider);

  if (authState.value == null) {
    yield null;
    return;
  }

  final userId = authState.value!.session?.user.id;
  if (userId == null) {
    yield null;
    return;
  }

  // Initial fetch
  final profile = await repository.getProfile(userId);
  yield profile;

  // Listen to real-time updates
  final stream = SupabaseService.client
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', userId)
      .map((data) {
        if (data.isEmpty) return null;
        return ProfileModel.fromJson(data.first);
      });

  yield* stream;
});

// Other User's Profile Provider (by ID)
final profileByIdProvider = FutureProvider.family<ProfileModel?, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfile(userId);
});

// Profile Stats Provider
final profileStatsProvider = FutureProvider.family<ProfileStats, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);

  final itemsCount = await repository.getUserItemsCount(userId);
  final timesLent = await repository.getTimesLentCount(userId);

  return ProfileStats(
    itemsListed: itemsCount,
    timesLent: timesLent,
  );
});

// Profile Stats Model
class ProfileStats {
  final int itemsListed;
  final int timesLent;

  ProfileStats({
    required this.itemsListed,
    required this.timesLent,
  });
}

// Profile Notifier for Profile Updates
class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel?>> {
  final ProfileRepository _repository;
  final String _userId;

  ProfileNotifier(this._repository, this._userId) : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getProfile(_userId);
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();
    try {
      final updatedProfile = await _repository.updateProfile(_userId, updates);
      state = AsyncValue.data(updatedProfile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> uploadAvatar(File imageFile) async {
    state = const AsyncValue.loading();
    try {
      await _repository.uploadAvatar(_userId, imageFile);
      await _loadProfile(); // Reload profile after avatar upload
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteAvatar(String avatarUrl) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteAvatar(_userId, avatarUrl);
      await _loadProfile(); // Reload profile after avatar deletion
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  void refresh() {
    _loadProfile();
  }
}

// Profile Notifier Provider
final profileNotifierProvider = StateNotifierProvider.family<ProfileNotifier, AsyncValue<ProfileModel?>, String>(
  (ref, userId) {
    return ProfileNotifier(
      ref.watch(profileRepositoryProvider),
      userId,
    );
  },
);

// Current User Profile Notifier Provider
final currentProfileNotifierProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel?>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.session?.user.id ?? '';

  if (userId.isEmpty) {
    return ProfileNotifier(ref.watch(profileRepositoryProvider), '');
  }

  return ProfileNotifier(
    ref.watch(profileRepositoryProvider),
    userId,
  );
});

// Neighborhood Profiles Provider
final neighborhoodProfilesProvider = FutureProvider.family<List<ProfileModel>, String>((ref, neighborhood) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getNeighborhoodProfiles(neighborhood);
});

// Search Profiles Provider
final searchProfilesProvider = FutureProvider.family<List<ProfileModel>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final repository = ref.watch(profileRepositoryProvider);
  return repository.searchProfiles(query);
});
