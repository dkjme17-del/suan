import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';  // Disabled for Windows build
import '../../../../core/utils/logger.dart';

import '../entities/object_recognition_result.dart';

class ObjectRecognitionService {
  static final ObjectRecognitionService _instance =
      ObjectRecognitionService._internal();
  factory ObjectRecognitionService() => _instance;
  ObjectRecognitionService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  // Dictionnaire de traduction baoulé simulé
  final Map<String, String> _baouleTranslations = {
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
  };

  // Initialiser le modèle TensorFlow Lite
  Future<void> initialize() async {
    try {
      Logger.info('Object recognition service initialized (TFLite disabled)');
    } catch (e) {
      Logger.error('Erreur initialisation modèle', e);
    }
  }

  // Prendre une photo avec la caméra
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

  // Sélectionner une image depuis la galerie
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

  // Reconnaître l'objet dans l'image (using fallback)
  Future<ObjectRecognitionResult?> recognizeObject(XFile imageFile) async {
    try {
      return _simulateRecognition(imageFile);
    } catch (e) {
      Logger.error('Erreur reconnaissance objet', e);
      return null;
    }
  }

  // Simulation de reconnaissance (fallback)
  ObjectRecognitionResult _simulateRecognition(XFile imageFile) {
    final fileKey =
        (imageFile.name.isNotEmpty ? imageFile.name : imageFile.path)
            .toLowerCase();
    String detectedObject = 'object';

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

    return ObjectRecognitionResult(
      objectName: detectedObject,
      confidence: 0.85,
      baouleTranslation: _getBaouleTranslation(detectedObject),
      imagePath: imageFile.path.isNotEmpty ? imageFile.path : imageFile.name,
    );
  }

  // Obtenir la traduction baoulé
  String _getBaouleTranslation(String objectName) {
    return _baouleTranslations[objectName.toLowerCase()] ?? objectName;
  }

  // Libérer les ressources
  void dispose() {
    // No-op for simulation mode
  }
}
