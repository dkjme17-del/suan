/// Result of object recognition
class ObjectRecognitionResult {
  final String objectName;
  final double confidence;
  final String baouleTranslation;
  final String imagePath;

  const ObjectRecognitionResult({
    required this.objectName,
    required this.confidence,
    required this.baouleTranslation,
    required this.imagePath,
  });

  @override
  String toString() {
    return 'ObjectRecognitionResult(objectName: $objectName, confidence: $confidence, baouleTranslation: $baouleTranslation)';
  }
}
