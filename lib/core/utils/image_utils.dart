import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';

/// Utility functions for image processing
/// Handles compression, thumbnail generation, and validation
class ImageUtils {
  /// Compress an image file to reduce size while maintaining quality
  /// Returns the compressed image file
  static Future<File> compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final fileSize = await file.length();
      
      // If file is already smaller than max size, return as is
      if (fileSize <= AppConstants.maxImageSizeBytes) {
        return file;
      }
      
      // Create output path
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      // Compress the image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: AppConstants.imageCompressionQuality,
        minWidth: 1080,
        minHeight: 1080,
        format: CompressFormat.jpeg,
      );
      
      if (compressedFile == null) {
        throw Exception('Failed to compress image');
      }
      
      return File(compressedFile.path);
    } catch (e) {
      print('[ImageUtils] Image compression failed: $e');
      rethrow;
    }
  }
  
  /// Generate a square thumbnail from an image
  /// Returns a File containing the thumbnail
  static Future<File> generateThumbnail(File file) async {
    try {
      final filePath = file.absolute.path;
      
      // Create output path
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      // Generate thumbnail (square crop from center)
      final thumbnailFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: AppConstants.thumbnailCompressionQuality,
        minWidth: AppConstants.thumbnailSize,
        minHeight: AppConstants.thumbnailSize,
        format: CompressFormat.jpeg,
      );
      
      if (thumbnailFile == null) {
        throw Exception('Failed to generate thumbnail');
      }
      
      return File(thumbnailFile.path);
    } catch (e) {
      print('[ImageUtils] Thumbnail generation failed: $e');
      rethrow;
    }
  }
  
  /// Check if a file is a valid image
  /// Validates file type and size
  static Future<bool> isValidImage(File file) async {
    try {
      // Check file exists
      if (!await file.exists()) {
        return false;
      }
      
      // Check file size
      final fileSize = await file.length();
      if (fileSize > AppConstants.maxImageSizeBytes) {
        print('⚠️ Image too large: ${fileSize} bytes');
        return false;
      }
      
      if (fileSize == 0) {
        print('⚠️ Image file is empty');
        return false;
      }
      
      // Check file extension
      final extension = path.extension(file.path).toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
      
      if (!validExtensions.contains(extension)) {
        print('⚠️ Invalid image format: $extension');
        return false;
      }
      
      return true;
    } catch (e) {
      print('[ImageUtils] Image validation failed: $e');
      return false;
    }
  }
  
  /// Get file size in bytes
  static Future<int> getFileSizeInBytes(File file) async {
    try {
      return await file.length();
    } catch (e) {
      print('[ImageUtils] Failed to get file size: $e');
      return 0;
    }
  }
  
  /// Format file size for display (e.g., "2.5 MB")
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
