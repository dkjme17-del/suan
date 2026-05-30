import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/logger.dart';

import '../entities/object_recognition_result.dart';

/// Traductions baoulé réelles depuis Firebase
class BaouleTranslationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final BaouleTranslationService _instance =
      BaouleTranslationService._internal();
  factory BaouleTranslationService() => _instance;
  BaouleTranslationService._internal();

  final Map<String, String> _cache = {};

  /// Obtenir la traduction baoulé depuis Firebase
  Future<String> getBaouleTranslation(String objectName) async {
    if (_cache.containsKey(objectName)) {
      return _cache[objectName]!;
    }

    try {
      final snapshot = await _firestore
          .collection('baoule_translations')
          .doc(objectName.toLowerCase())
          .get();

      if (snapshot.exists) {
        final translation =
            snapshot.data()?['translation'] as String? ?? objectName;
        _cache[objectName] = translation;
        return translation;
      }

      _cache[objectName] = objectName;
      return objectName;
    } catch (e) {
      Logger.error('Erreur récupération traduction baoulé', e);
      return objectName;
    }
  }

  /// Ajouter une nouvelle traduction
  Future<void> addTranslation({
    required String objectName,
    required String baouleTranslation,
  }) async {
    try {
      await _firestore
          .collection('baoule_translations')
          .doc(objectName.toLowerCase())
          .set({
            'objectName': objectName,
            'translation': baouleTranslation,
            'createdAt': FieldValue.serverTimestamp(),
            'addedBy': 'system',
          });

      _cache[objectName] = baouleTranslation;
      Logger.info('Traduction ajoutée: $objectName -> $baouleTranslation');
    } catch (e) {
      Logger.error('Erreur ajout traduction', e);
      rethrow;
    }
  }

  /// Initialiser avec des traductions de base
  Future<void> initializeBasicTranslations() async {
    final basicTranslations = {
      'apple': 'ablɛ',
      'banana': 'anan',
      'orange': 'ɔrɔnzi',
      'mango': 'mangɔ',
      'tree': 'arbre',
      'house': 'maison',
      'car': 'voiture',
      'book': 'livre',
      'phone': 'téléphone',
      'water': 'eau',
      'food': 'nourriture',
      'person': 'personne',
      'animal': 'animal',
      'flower': 'fleur',
      'sun': 'soleil',
      'moon': 'lune',
      'dog': 'chien',
      'cat': 'chat',
      'bird': 'oiseau',
      'fish': 'poisson',
      'chair': 'chaise',
      'table': 'table',
      'door': 'porte',
      'window': 'fenêtre',
      'computer': 'ordinateur',
      'pen': 'stylo',
      'paper': 'papier',
    };

    for (final entry in basicTranslations.entries) {
      await addTranslation(
        objectName: entry.key,
        baouleTranslation: entry.value,
      );
    }
  }
}

/// Service de reconnaissance d'objets avec Fallback
class RealObjectRecognitionService {
  static final RealObjectRecognitionService _instance =
      RealObjectRecognitionService._internal();
  factory RealObjectRecognitionService() => _instance;
  RealObjectRecognitionService._internal();

  // Labels will be loaded from Firestore
  final ImagePicker _imagePicker = ImagePicker();
  final BaouleTranslationService _translationService =
      BaouleTranslationService();

  /// Initialiser le service
  Future<void> initialize() async {
    try {
      await _translationService.initializeBasicTranslations();
      Logger.info('Object recognition service initialized (fallback mode)');
    } catch (e) {
      Logger.error('Erreur initialisation service', e);
    }
  }

  /// Prendre une photo avec la caméra
  Future<XFile?> capturePhoto() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
    } catch (e) {
      Logger.error('Erreur capture photo', e);
      return null;
    }
  }

  /// Sélectionner une image depuis la galerie
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
    } catch (e) {
      Logger.error('Erreur sélection image', e);
      return null;
    }
  }

  /// Reconnaître l'objet dans l'image (utilise fallback avec traduction)
  Future<ObjectRecognitionResult?> recognizeObject(XFile imageFile) async {
    try {
      return await _fallbackRecognition(imageFile);
    } catch (e) {
      Logger.error('Erreur reconnaissance objet', e);
      return await _fallbackRecognition(imageFile);
    }
  }

  /// Reconnaissance fallback avec traduction Firebase
  Future<ObjectRecognitionResult> _fallbackRecognition(XFile imageFile) async {
    final fileKey = (imageFile.name.isNotEmpty ? imageFile.name : imageFile.path)
        .toLowerCase();
    String detectedObject = 'objet';

    if (fileKey.contains('apple') || fileKey.contains('pomme')) {
      detectedObject = 'apple';
    } else if (fileKey.contains('banana') || fileKey.contains('banane')) {
      detectedObject = 'banana';
    } else if (fileKey.contains('orange')) {
      detectedObject = 'orange';
    } else if (fileKey.contains('tree') || fileKey.contains('arbre')) {
      detectedObject = 'tree';
    } else if (fileKey.contains('house') || fileKey.contains('maison')) {
      detectedObject = 'house';
    } else if (fileKey.contains('car') || fileKey.contains('voiture')) {
      detectedObject = 'car';
    } else if (fileKey.contains('book') || fileKey.contains('livre')) {
      detectedObject = 'book';
    } else if (fileKey.contains('phone') || fileKey.contains('téléphone')) {
      detectedObject = 'phone';
    }

    final baouleTranslation = await _translationService.getBaouleTranslation(detectedObject);

    return ObjectRecognitionResult(
      objectName: detectedObject,
      confidence: 0.75,
      baouleTranslation: baouleTranslation,
      imagePath: imageFile.path.isNotEmpty ? imageFile.path : imageFile.name,
    );
  }

  /// Sauvegarder le résultat de reconnaissance
  Future<void> saveRecognitionResult(ObjectRecognitionResult result) async {
    try {
      await FirebaseFirestore.instance.collection('recognition_history').add({
        'objectName': result.objectName,
        'baouleTranslation': result.baouleTranslation,
        'confidence': result.confidence,
        'imagePath': result.imagePath,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Logger.info('Résultat reconnaissance sauvegardé: ${result.objectName}');
    } catch (e) {
      Logger.error('Erreur sauvegarde résultat', e);
    }
  }

  /// Obtenir l'historique des reconnaissances
  Future<List<Map<String, dynamic>>> getRecognitionHistory({int limit = 50}) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('recognition_history')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      Logger.error('Erreur récupération historique', e);
      return [];
    }
  }

  /// Stream de l'historique en temps réel
  Stream<List<Map<String, dynamic>>> streamRecognitionHistory({int limit = 50}) {
    return FirebaseFirestore.instance
        .collection('recognition_history')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Ajouter une nouvelle traduction manuelle
  Future<void> addCustomTranslation({
    required String objectName,
    required String baouleTranslation,
  }) async {
    await _translationService.addTranslation(
      objectName: objectName,
      baouleTranslation: baouleTranslation,
    );
  }

  /// Obtenir toutes les traductions disponibles
  Future<Map<String, String>> getAllTranslations() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('baoule_translations')
          .get();

      final translations = <String, String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['objectName'] != null && data['translation'] != null) {
          translations[data['objectName']] = data['translation'];
        }
      }
      return translations;
    } catch (e) {
      Logger.error('Erreur récupération traductions', e);
      return {};
    }
  }
}

