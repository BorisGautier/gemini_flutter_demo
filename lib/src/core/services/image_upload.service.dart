import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:kartia/src/core/services/log.service.dart';

/// Service pour gérer l'upload d'images vers Firebase Storage
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final LogService _logger = LogService();

  /// Uploader une image de profil utilisateur
  Future<String?> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      _logger.info('Début de l\'upload d\'image de profil pour: $userId');

      // Créer un nom de fichier unique
      final String fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // Référence vers le dossier des images de profil
      final Reference ref = _storage
          .ref()
          .child('profile_images')
          .child(fileName);

      // Métadonnées pour l'image
      final SettableMetadata metadata = SettableMetadata(
        contentType: _getContentType(imageFile.path),
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload du fichier
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);

      // Suivre le progrès de l'upload
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        _logger.info('Progrès upload: ${(progress * 100).toStringAsFixed(1)}%');
      });

      // Attendre la fin de l'upload
      final TaskSnapshot snapshot = await uploadTask;

      // Récupérer l'URL de téléchargement
      final String downloadURL = await snapshot.ref.getDownloadURL();

      _logger.info('Upload d\'image de profil réussi: $downloadURL');
      return downloadURL;
    } on FirebaseException catch (e) {
      _logger.error('Erreur Firebase lors de l\'upload d\'image: ${e.code}', e);

      switch (e.code) {
        case 'storage/unauthorized':
          throw Exception('Vous n\'êtes pas autorisé à uploader des images');
        case 'storage/canceled':
          throw Exception('Upload annulé');
        case 'storage/unknown':
          throw Exception('Une erreur inconnue s\'est produite');
        default:
          throw Exception('Erreur lors de l\'upload: ${e.message}');
      }
    } catch (e) {
      _logger.error('Erreur lors de l\'upload d\'image de profil', e);
      throw Exception('Impossible d\'uploader l\'image');
    }
  }

  /// Supprimer une image de profil existante
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      _logger.info('Suppression de l\'image de profil: $imageUrl');

      // Extraire la référence à partir de l'URL
      final Reference ref = _storage.refFromURL(imageUrl);

      // Supprimer le fichier
      await ref.delete();

      _logger.info('Image de profil supprimée avec succès');
    } on FirebaseException catch (e) {
      _logger.error(
        'Erreur Firebase lors de la suppression d\'image: ${e.code}',
        e,
      );

      if (e.code != 'storage/object-not-found') {
        throw Exception('Erreur lors de la suppression de l\'image');
      }
      // Si l'objet n'existe pas, on considère que c'est OK
    } catch (e) {
      _logger.error('Erreur lors de la suppression d\'image de profil', e);
      throw Exception('Impossible de supprimer l\'image');
    }
  }

  /// Uploader une image générale avec un chemin personnalisé
  Future<String?> uploadImage({
    required String path,
    required File imageFile,
    Map<String, String>? customMetadata,
  }) async {
    try {
      _logger.info('Upload d\'image vers: $path');

      // Référence vers le fichier
      final Reference ref = _storage.ref().child(path);

      // Métadonnées
      final SettableMetadata metadata = SettableMetadata(
        contentType: _getContentType(imageFile.path),
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          ...?customMetadata,
        },
      );

      // Upload
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);
      final TaskSnapshot snapshot = await uploadTask;

      // URL de téléchargement
      final String downloadURL = await snapshot.ref.getDownloadURL();

      _logger.info('Upload d\'image réussi: $downloadURL');
      return downloadURL;
    } catch (e) {
      _logger.error('Erreur lors de l\'upload d\'image', e);
      rethrow;
    }
  }

  /// Obtenir le type de contenu basé sur l'extension du fichier
  String _getContentType(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Par défaut
    }
  }

  /// Valider si le fichier est une image valide
  bool isValidImageFile(File file) {
    final String extension = path.extension(file.path).toLowerCase();
    final List<String> validExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
    ];

    return validExtensions.contains(extension);
  }

  /// Vérifier la taille du fichier (en MB)
  bool isValidFileSize(File file, {double maxSizeMB = 5.0}) {
    final int fileSizeInBytes = file.lengthSync();
    final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    return fileSizeInMB <= maxSizeMB;
  }

  /// Obtenir les métadonnées d'un fichier uploadé
  Future<FullMetadata?> getFileMetadata(String downloadUrl) async {
    try {
      final Reference ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      _logger.error('Erreur lors de la récupération des métadonnées', e);
      return null;
    }
  }

  /// Lister les images d'un utilisateur
  Future<List<String>> listUserImages(String userId) async {
    try {
      final Reference ref = _storage.ref().child('profile_images');
      final ListResult result = await ref.listAll();

      final List<String> imageUrls = [];

      for (Reference item in result.items) {
        // Vérifier si l'image appartient à l'utilisateur
        try {
          final FullMetadata metadata = await item.getMetadata();
          if (metadata.customMetadata?['userId'] == userId) {
            final String downloadUrl = await item.getDownloadURL();
            imageUrls.add(downloadUrl);
          }
        } catch (e) {
          _logger.warning(
            'Impossible de récupérer les métadonnées pour: ${item.name}',
          );
        }
      }

      return imageUrls;
    } catch (e) {
      _logger.error('Erreur lors de la liste des images utilisateur', e);
      return [];
    }
  }

  /// Nettoyer les anciennes images de profil d'un utilisateur
  Future<void> cleanupOldProfileImages(
    String userId, {
    int keepCount = 3,
  }) async {
    try {
      final List<String> userImages = await listUserImages(userId);

      if (userImages.length > keepCount) {
        // Trier par date de création et supprimer les plus anciennes
        final List<String> imagesToDelete =
            userImages.take(userImages.length - keepCount).toList();

        for (String imageUrl in imagesToDelete) {
          try {
            await deleteProfileImage(imageUrl);
          } catch (e) {
            _logger.warning(
              'Impossible de supprimer l\'ancienne image: $imageUrl',
            );
          }
        }

        _logger.info(
          'Nettoyage terminé: ${imagesToDelete.length} images supprimées',
        );
      }
    } catch (e) {
      _logger.error('Erreur lors du nettoyage des anciennes images', e);
    }
  }
}
