import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  /// Upload d'avatar
  Future<String?> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      print('📤 Upload avatar pour utilisateur: $userId');

      // Référence vers le fichier
      final ref = _storage.ref().child('avatars/$userId.jpg');

      // Upload
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Récupérer l'URL
      final downloadUrl = await ref.getDownloadURL();

      print('✅ Avatar uploadé: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Erreur upload avatar: $e');
      return null;
    }
  }

  /// Sélectionner une image depuis la galerie
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      print('❌ Erreur sélection image: $e');
      return null;
    }
  }

  /// Prendre une photo avec la caméra
  Future<File?> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      print('❌ Erreur capture photo: $e');
      return null;
    }
  }

  /// Upload d'un fichier audio
  Future<String?> uploadAudio({
    required String fileName,
    required File audioFile,
  }) async {
    try {
      print('📤 Upload audio: $fileName');

      final ref = _storage.ref().child('sounds/$fileName');

      await ref.putFile(
        audioFile,
        SettableMetadata(contentType: 'audio/mpeg'),
      );

      final downloadUrl = await ref.getDownloadURL();

      print('✅ Audio uploadé: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Erreur upload audio: $e');
      return null;
    }
  }

  /// Supprimer un fichier
  Future<bool> deleteFile(String filePath) async {
    try {
      await _storage.ref(filePath).delete();
      print('✅ Fichier supprimé: $filePath');
      return true;
    } catch (e) {
      print('❌ Erreur suppression: $e');
      return false;
    }
  }
}