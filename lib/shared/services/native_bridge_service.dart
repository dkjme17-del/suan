import 'package:flutter/services.dart';
import '../../core/utils/logger.dart';

/// Service pour accès natif optimisé à la caméra
///
/// Utilise Platform Channels pour:
/// - Accès direct au matériel caméra
/// - Optimisations de performance
/// - Traitement natif des images

class NativeCameraService {
  static const platform = MethodChannel('com.suan.app/camera');
  static const eventChannel = EventChannel('com.suan.app/camera_events');

  /// Demander les permissions caméra
  static Future<bool> requestCameraPermission() async {
    try {
      final granted = await platform.invokeMethod<bool>(
        'requestCameraPermission',
      );
      return granted ?? false;
    } catch (e) {
      Logger.error('❌ Camera permission error', e);
      return false;
    }
  }

  /// Vérifier les permissions caméra
  static Future<bool> checkCameraPermission() async {
    try {
      final granted = await platform.invokeMethod<bool>(
        'checkCameraPermission',
      );
      return granted ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Capturer une photo optimisée
  static Future<String?> capturePhoto({
    int quality = 85,
    bool enableFocus = true,
    int timeoutMs = 5000,
  }) async {
    try {
      final imagePath = await platform.invokeMethod<String>('capturePhoto', {
        'quality': quality,
        'enableFocus': enableFocus,
        'timeout': timeoutMs,
      });
      return imagePath;
    } catch (e) {
      Logger.error('❌ Photo capture error', e);
      return null;
    }
  }

  /// Enregistrer une vidéo courte
  static Future<String?> recordVideo({
    int durationMs = 10000,
    bool enableAudio = false,
  }) async {
    try {
      final videoPath = await platform.invokeMethod<String>('recordVideo', {
        'duration': durationMs,
        'enableAudio': enableAudio,
      });
      return videoPath;
    } catch (e) {
      Logger.error('❌ Video record error', e);
      return null;
    }
  }

  /// Activer le mode torche
  static Future<bool> setTorchMode(bool enabled) async {
    try {
      final success = await platform.invokeMethod<bool>('setTorchMode', {
        'enabled': enabled,
      });
      return success ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Stream des événements caméra (autorisation refusée, app minimisée, etc.)
  static Stream<Map<dynamic, dynamic>> getCameraEvents() {
    return eventChannel.receiveBroadcastStream().map(
      (event) => Map<dynamic, dynamic>.from(event),
    );
  }

  /// Libérer les ressources caméra
  static Future<void> releaseCamera() async {
    try {
      await platform.invokeMethod('releaseCamera');
    } catch (e) {
      Logger.error('❌ Release camera error', e);
    }
  }
}

/// Service pour audio offline optimisé
///
/// Utilise Platform Channels pour:
/// - Accès direct à hardware audio
/// - Traitement natif audio/MP3
/// - Téléchargement et cache offline

class NativeAudioService {
  static const platform = MethodChannel('com.suan.app/audio');
  static const eventChannel = EventChannel('com.suan.app/audio_events');

  /// Initialiser le service audio
  static Future<bool> initialize({
    String cachePath = '',
    bool enableOfflineMode = true,
  }) async {
    try {
      final success = await platform.invokeMethod<bool>('initialize', {
        'cachePath': cachePath,
        'enableOfflineMode': enableOfflineMode,
      });
      return success ?? false;
    } catch (e) {
      Logger.error('❌ Audio init error', e);
      return false;
    }
  }

  /// Jouer un fichier audio local
  static Future<bool> playLocal(
    String filePath, {
    double playbackRate = 1.0,
  }) async {
    try {
      final success = await platform.invokeMethod<bool>('playLocal', {
        'filePath': filePath,
        'playbackRate': playbackRate,
      });
      return success ?? false;
    } catch (e) {
      Logger.error('❌ Play local error', e);
      return false;
    }
  }

  /// Jouer un fichier audio avec lecture lente
  static Future<bool> playSlowMode(
    String filePath, {
    double rate = 0.75,
  }) async {
    return playLocal(filePath, playbackRate: rate);
  }

  /// Télécharger audio pour mode offline
  static Future<bool> downloadForOffline({
    required String fileUrl,
    required String fileName,
    Function(double progress)? onProgress,
  }) async {
    try {
      final success = await platform.invokeMethod<bool>('downloadForOffline', {
        'url': fileUrl,
        'fileName': fileName,
      });

      // Écouter la progression
      eventChannel.receiveBroadcastStream().listen((progress) {
        onProgress?.call(progress as double);
      });

      return success ?? false;
    } catch (e) {
      Logger.error('❌ Download error', e);
      return false;
    }
  }

  /// Vérifier si un fichier est disponible offline
  static Future<bool> isAvailableOffline(String fileName) async {
    try {
      final available = await platform.invokeMethod<bool>(
        'isAvailableOffline',
        {'fileName': fileName},
      );
      return available ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Obtenir l'espace cache disponible
  static Future<int> getCacheSpace() async {
    try {
      final space = await platform.invokeMethod<int>('getCacheSpace');
      return space ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Nettoyer le cache audio
  static Future<bool> clearCache() async {
    try {
      final success = await platform.invokeMethod<bool>('clearCache');
      return success ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Enregistrer audio avec optimisations natives
  static Future<String?> recordAudio({
    int durationMs = 10000,
    String quality = 'high', // 'low', 'medium', 'high'
  }) async {
    try {
      final audioPath = await platform.invokeMethod<String>('recordAudio', {
        'duration': durationMs,
        'quality': quality,
      });
      return audioPath;
    } catch (e) {
      Logger.error('❌ Record audio error', e);
      return null;
    }
  }

  /// Stream des événements audio (lecture terminée, erreur, etc.)
  static Stream<AudioEvent> getAudioEvents() {
    return eventChannel.receiveBroadcastStream().map(
      (event) => AudioEvent.fromMap(Map<dynamic, dynamic>.from(event)),
    );
  }

  /// Arrêter la lecture audio
  static Future<bool> stop() async {
    try {
      final success = await platform.invokeMethod<bool>('stop');
      return success ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mettre en pause
  static Future<bool> pause() async {
    try {
      final success = await platform.invokeMethod<bool>('pause');
      return success ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Reprendre
  static Future<bool> resume() async {
    try {
      final success = await platform.invokeMethod<bool>('resume');
      return success ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Libérer les ressources
  static Future<void> dispose() async {
    try {
      await platform.invokeMethod('dispose');
    } catch (e) {
      Logger.error('❌ Dispose error', e);
    }
  }
}

/// Modèle pour événements audio
class AudioEvent {
  final AudioEventType type;
  final String message;
  final int? position;
  final int? duration;

  AudioEvent({
    required this.type,
    required this.message,
    this.position,
    this.duration,
  });

  factory AudioEvent.fromMap(Map<dynamic, dynamic> map) {
    return AudioEvent(
      type: AudioEventType.values.firstWhere(
        (e) => e.toString().endsWith(map['type'] ?? 'UNKNOWN'),
      ),
      message: map['message'] ?? '',
      position: map['position'],
      duration: map['duration'],
    );
  }
}

enum AudioEventType {
  started,
  paused,
  resumed,
  completed,
  error,
  progressUpdate,
}
