import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Upload avatar depuis un File (Mobile)
  Future<String?> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      print('📤 Upload avatar (Mobile) pour userId: $userId');

      final ref = _storage
          .ref()
          .child('avatars')
          .child('$userId.jpg');

      // Upload du fichier
      await ref.putFile(imageFile);

      // Récupérer l'URL de téléchargement
      final downloadUrl = await ref.getDownloadURL();

      print('✅ Avatar uploadé avec succès: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Erreur upload avatar (Mobile): $e');
      return null;
    }
  }

  /// Upload avatar depuis des bytes (Web)
  Future<String?> uploadAvatarFromBytes({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    try {
      print('📤 Upload avatar (Web) pour userId: $userId');
      print('📊 Taille de l\'image: ${imageBytes.length} bytes');

      final ref = _storage
          .ref()
          .child('avatars')
          .child('$userId.jpg');

      // Métadonnées pour l'image
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload des bytes
      await ref.putData(imageBytes, metadata);

      // Récupérer l'URL de téléchargement
      final downloadUrl = await ref.getDownloadURL();

      print('✅ Avatar uploadé avec succès: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Erreur upload avatar (Web): $e');
      return null;
    }
  }

  /// Supprimer un avatar
  Future<void> deleteAvatar(String userId) async {
    try {
      print('🗑️ Suppression avatar pour userId: $userId');

      final ref = _storage
          .ref()
          .child('avatars')
          .child('$userId.jpg');

      await ref.delete();

      print('✅ Avatar supprimé avec succès');
    } catch (e) {
      print('❌ Erreur suppression avatar: $e');
    }
  }

  /// Sélectionner une image depuis la galerie
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('✅ Image sélectionnée depuis la galerie: ${pickedFile.path}');
        return File(pickedFile.path);
      }

      return null;
    } catch (e) {
      print('❌ Erreur sélection image galerie: $e');
      return null;
    }
  }

  /// Prendre une photo avec la caméra
  Future<File?> takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('✅ Photo prise avec la caméra: ${pickedFile.path}');
        return File(pickedFile.path);
      }

      return null;
    } catch (e) {
      print('❌ Erreur prise de photo: $e');
      return null;
    }
  }

  /// Sélectionner une image (retourne bytes pour Web, File pour Mobile)
  Future<Map<String, dynamic>?> pickImage({
    required ImageSource source,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('✅ Image sélectionnée: ${pickedFile.path}');

        if (kIsWeb) {
          // Sur Web, retourner les bytes
          final bytes = await pickedFile.readAsBytes();
          print('✅ Bytes chargés (Web): ${bytes.length} bytes');
          return {
            'bytes': bytes,
            'file': null,
          };
        } else {
          // Sur Mobile, retourner le File
          print('✅ File créé (Mobile)');
          return {
            'bytes': null,
            'file': File(pickedFile.path),
          };
        }
      }

      return null;
    } catch (e) {
      print('❌ Erreur sélection image: $e');
      return null;
    }
  }
}