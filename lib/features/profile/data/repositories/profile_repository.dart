import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/storage_service.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final SupabaseClient _supabase;
  final StorageService _storageService;

  ProfileRepository(this._supabase, this._storageService);

  /// Get profile by user ID
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(message: 'Failed to fetch profile: ${e.message}', code: e.code);
    } catch (e) {
      throw UnknownException(message: 'Failed to fetch profile: $e');
    }
  }

  /// Update profile information
  Future<ProfileModel> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.profilesTable)
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return ProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException(message: 'Failed to update profile: ${e.message}', code: e.code);
    } catch (e) {
      throw UnknownException(message: 'Failed to update profile: $e');
    }
  }

  /// Upload avatar and update profile
  Future<String> uploadAvatar(String userId, File imageFile) async {
    try {
      // Upload avatar to storage
      final avatarUrl = await _storageService.uploadAvatar(
        userId: userId,
        avatarFile: imageFile,
      );

      // Update profile with new avatar URL
      await updateProfile(userId, {'avatar_url': avatarUrl});

      return avatarUrl;
    } on AppStorageException {
      rethrow;
    } catch (e) {
      throw AppStorageException(message: 'Failed to upload avatar: $e');
    }
  }

  /// Delete avatar
  Future<void> deleteAvatar(String userId, String avatarUrl) async {
    try {
      // Delete from storage
      await _storageService.deleteFile(avatarUrl);

      // Update profile to remove avatar URL
      await updateProfile(userId, {'avatar_url': null});
    } on AppStorageException {
      rethrow;
    } catch (e) {
      throw UnknownException(message: 'Failed to delete avatar: $e');
    }
  }

  /// Get current user's profile
  Future<ProfileModel?> getCurrentProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }
    return getProfile(userId);
  }

  /// Check if profile is complete (has required fields)
  Future<bool> isProfileComplete(String userId) async {
    final profile = await getProfile(userId);
    if (profile == null) return false;

    // A complete profile should have at least username and neighborhood
    return profile.username.isNotEmpty && profile.hasNeighborhood;
  }

  /// Get user's items count
  Future<int> getUserItemsCount(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.itemsTable)
          .select('*')
          .eq('user_id', userId)
          .count(CountOption.exact);

      return response.data.length;
    } on PostgrestException catch (e) {
      throw DatabaseException(message: 'Failed to count items: ${e.message}', code: e.code);
    } catch (e) {
      throw UnknownException(message: 'Failed to count items: $e');
    }
  }

  /// Get times lent count (items currently on loan)
  Future<int> getTimesLentCount(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.itemsTable)
          .select('*')
          .eq('user_id', userId)
          .eq('status', 'On Loan')
          .count(CountOption.exact);

      return response.data.length;
    } on PostgrestException catch (e) {
      throw DatabaseException(message: 'Failed to count lent items: ${e.message}', code: e.code);
    } catch (e) {
      throw UnknownException(message: 'Failed to count lent items: $e');
    }
  }

  /// Get all profiles in a neighborhood
  Future<List<ProfileModel>> getNeighborhoodProfiles(String neighborhood) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.profilesTable)
          .select()
          .eq('neighborhood', neighborhood);

      return (response as List)
          .map((json) => ProfileModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(message: 'Failed to fetch neighborhood profiles: ${e.message}', code: e.code);
    } catch (e) {
      throw UnknownException(message: 'Failed to fetch neighborhood profiles: $e');
    }
  }

  /// Search profiles by username
  Future<List<ProfileModel>> searchProfiles(String query) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.profilesTable)
          .select()
          .ilike('username', '%$query%')
          .limit(20);

      return (response as List)
          .map((json) => ProfileModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException(message: 'Failed to search profiles: ${e.message}', code: e.code);
    } catch (e) {
      throw UnknownException(message: 'Failed to search profiles: $e');
    }
  }
}
