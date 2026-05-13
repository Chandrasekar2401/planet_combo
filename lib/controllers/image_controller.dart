import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:planetcombo/common/app_logger.dart';

class ProfileImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getOrUploadProfileImage(String googleImageUrl) async {
    if (googleImageUrl.isEmpty) {
      AppLogger.d('Empty Google image URL provided');
      return null;
    }

    try {
      // Generate a unique filename using timestamp
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('profile_images/$fileName');

      AppLogger.d('Attempting to download image from Google: $googleImageUrl');

      // Download the image from Google
      final response = await http.get(Uri.parse(googleImageUrl));

      if (response.statusCode != 200) {
        AppLogger.d('Failed to download from Google. Status: ${response.statusCode}');
        return googleImageUrl;
      }

      AppLogger.d('Successfully downloaded image from Google. Size: ${response.bodyBytes.length} bytes');

      // Upload to Firebase Storage
      try {
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
            'source': 'google_profile'
          },
        );

        AppLogger.d('Starting upload to Firebase Storage');
        await storageRef.putData(response.bodyBytes, metadata);
        AppLogger.d('Successfully uploaded to Firebase Storage');

        // Get the download URL
        final downloadUrl = await storageRef.getDownloadURL();
        AppLogger.d('Generated download URL: $downloadUrl');

        return downloadUrl;
      } catch (uploadError) {
        AppLogger.d('Firebase Storage upload error: $uploadError');
        return googleImageUrl;
      }
    } catch (e) {
      AppLogger.d('Error in getOrUploadProfileImage: $e');
      return googleImageUrl;
    }
  }
}