import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/logger.dart';
import '../../../../features/camera/domain/entities/object_recognition_result.dart';
import '../../../../features/camera/domain/services/object_recognition_service.dart';

class ObjectRecognitionWidget extends StatefulWidget {
  const ObjectRecognitionWidget({Key? key}) : super(key: key);

  @override
  State<ObjectRecognitionWidget> createState() =>
      _ObjectRecognitionWidgetState();
}

class _ObjectRecognitionWidgetState extends State<ObjectRecognitionWidget> {
  final ObjectRecognitionService _recognitionService = ObjectRecognitionService();
  bool _isProcessing = false;
  ObjectRecognitionResult? _recognitionResult;
  XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildCameraSection(),
          const SizedBox(height: 16),
          _buildResultSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            FontAwesomeIcons.camera,
            color: Colors.orange,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reconnaissance d\'objets',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                'Prenez une photo et découvrez le nom en baoulé',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraSection() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _onCapturePhoto,
          icon: const Icon(FontAwesomeIcons.camera),
          label: Text(_isProcessing ? 'Ouverture caméra...' : 'Prendre une photo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _isProcessing ? null : _onPickFromGallery,
          icon: const Icon(FontAwesomeIcons.image),
          label: const Text('Choisir depuis la galerie'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    if (_isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recognitionResult == null) {
      return const Text('Aucun objet reconnu pour le moment.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedImage != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_selectedImage!.path),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          'Objet détecté : ${_recognitionResult!.objectName}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text('Confiance : ${( _recognitionResult!.confidence * 100 ).toStringAsFixed(0)}%'),
        Text('Baoulé : ${_recognitionResult!.baouleTranslation}'),
      ],
    );
  }

  Future<void> _onCapturePhoto() async {
    await _processImage(() => _recognitionService.capturePhoto());
  }

  Future<void> _onPickFromGallery() async {
    await _processImage(() => _recognitionService.pickImageFromGallery());
  }

  Future<void> _processImage(Future<XFile?> Function() imageProvider) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final imageFile = await imageProvider();
      if (imageFile == null) {
        _showFeedback('Aucune image sélectionnée.', isError: true);
        return;
      }

      _selectedImage = imageFile;
      final recognition = await _recognitionService.recognizeObject(imageFile);
      if (recognition == null) {
        _showFeedback('Échec de reconnaissance.', isError: true);
        return;
      }

      setState(() {
        _recognitionResult = recognition;
      });

      _showFeedback('Objet reconnu : ${recognition.objectName}');
    } catch (e, stackTrace) {
      Logger.error('Erreur objet reconnaissance', e, stackTrace);
      _showFeedback('Erreur lors de la reconnaissance.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
