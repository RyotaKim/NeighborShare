import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

/// Service for handling file uploads and storage operations
/// Manages item images, avatars, and other media files in Supabase Storage
class StorageService {
  final SupabaseClient _supabase;
  
  StorageService(this._supabase);
  
  /// Upload an item image (full size and thumbnail)
  /// Returns a map with 'imageUrl' and 'thumbnailUrl'
  Future<Map<String, String>> uploadItemImage({
    required String userId,
    required String itemId,
    required File fullImage,
    required File thumbnail,
  }) async {
    try {
      // Upload full-size image
      final fullImagePath = SupabaseConstants.itemFullImagePath(userId, itemId);
      await _supabase.storage
          .from(SupabaseConstants.itemImagesBucket)
          .upload(
            fullImagePath,
            fullImage,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      
      // Upload thumbnail
      final thumbnailPath = SupabaseConstants.itemThumbnailPath(userId, itemId);
      await _supabase.storage
          .from(SupabaseConstants.itemImagesBucket)
          .upload(
            thumbnailPath,
            thumbnail,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      
      // Get public URLs
      final imageUrl = getPublicUrl(
        bucket: SupabaseConstants.itemImagesBucket,
        path: fullImagePath,
      );
      
      final thumbnailUrl = getPublicUrl(
        bucket: SupabaseConstants.itemImagesBucket,
        path: thumbnailPath,
      );
      
      return {
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
      };
    } catch (e) {
      print('❌ Failed to upload item image: $e');
      rethrow;
    }
  }
  
  /// Upload user avatar
  /// Returns the public URL of the uploaded avatar
  Future<String> uploadAvatar({
    required String userId,
    required File avatarFile,
  }) async {
    try {
      final avatarPath = SupabaseConstants.avatarPath(userId);
      
      await _supabase.storage
          .from(SupabaseConstants.avatarsBucket)
          .upload(
            avatarPath,
            avatarFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      
      return getPublicUrl(
        bucket: SupabaseConstants.avatarsBucket,
        path: avatarPath,
      );
    } catch (e) {
      print('❌ Failed to upload avatar: $e');
      rethrow;
    }
  }
  
  /// Delete an item's images (both full size and thumbnail)
  Future<void> deleteItemImages({
    required String userId,
    required String itemId,
  }) async {
    try {
      final fullImagePath = SupabaseConstants.itemFullImagePath(userId, itemId);
      final thumbnailPath = SupabaseConstants.itemThumbnailPath(userId, itemId);
      
      // Delete both files
      await _supabase.storage
          .from(SupabaseConstants.itemImagesBucket)
          .remove([fullImagePath, thumbnailPath]);
    } catch (e) {
      print('❌ Failed to delete item images: $e');
      rethrow;
    }
  }
  
  /// Delete user avatar
  Future<void> deleteAvatar({required String userId}) async {
    try {
      final avatarPath = SupabaseConstants.avatarPath(userId);
      
      await _supabase.storage
          .from(SupabaseConstants.avatarsBucket)
          .remove([avatarPath]);
    } catch (e) {
      print('❌ Failed to delete avatar: $e');
      rethrow;
    }
  }
  
  /// Delete a file from storage by its public URL
  Future<void> deleteFile(String publicUrl) async {
    try {
      // Extract bucket and path from public URL
      final uri = Uri.parse(publicUrl);
      final pathSegments = uri.pathSegments;
      
      // URL format: /storage/v1/object/public/{bucket}/{path}
      if (pathSegments.length < 5) {
        throw Exception('Invalid storage URL format');
      }
      
      final bucket = pathSegments[4];
      final path = pathSegments.sublist(5).join('/');
      
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      print('❌ Failed to delete file: $e');
      rethrow;
    }
  }
  
  /// Get public URL for a file in storage
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }
  
  /// Download a file from storage
  Future<Uint8List> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final bytes = await _supabase.storage.from(bucket).download(path);
      return bytes;
    } catch (e) {
      print('❌ Failed to download file: $e');
      rethrow;
    }
  }
  
  /// List files in a storage bucket path
  Future<List<FileObject>> listFiles({
    required String bucket,
    String? path,
  }) async {
    try {
      final files = await _supabase.storage.from(bucket).list(path: path);
      return files;
    } catch (e) {
      print('❌ Failed to list files: $e');
      rethrow;
    }
  }
}

