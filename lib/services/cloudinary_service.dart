import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/cupertino.dart';

class CloudinaryException implements Exception {
  final String message;
  CloudinaryException(this.message);
  @override
  String toString() => message;
}

class CloudinaryService {
  final String _cloudName = 'dt9qsvvp2';
  final String _uploadPreset = 'dt9qsvvp2_preset'; // TODO: Replace with your actual Unsigned Upload Preset name

  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  /// Uploads an image to Cloudinary and returns the optimized secure URL.
  /// 
  /// Throws [CloudinaryException] if the upload fails.
  Future<String> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final String secureUrl = response.secureUrl;
      
      if (secureUrl.contains('/upload/')) {
        return secureUrl.replaceFirst('/upload/', '/upload/q_auto,f_auto/');
      }
      
      return secureUrl;
    } catch (e) {
      debugPrint("Cloudinary Upload Error Details: $e");
      throw CloudinaryException("Upload failed: ${e.toString()}");
    }
  }
}
