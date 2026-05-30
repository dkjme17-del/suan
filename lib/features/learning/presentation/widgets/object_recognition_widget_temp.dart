import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ObjectRecognitionWidget extends StatefulWidget {
  const ObjectRecognitionWidget({Key? key}) : super(key: key);

  @override
  State<ObjectRecognitionWidget> createState() =>
      _ObjectRecognitionWidgetState();
}

class _ObjectRecognitionWidgetState extends State<ObjectRecognitionWidget> {
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
          onPressed: () {
            // TODO: Implement camera functionality
          },
          icon: const Icon(FontAwesomeIcons.camera),
          label: const Text('Prendre une photo'),
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
          onPressed: () {
            // TODO: Implement gallery functionality
          },
          icon: const Icon(FontAwesomeIcons.image),
          label: const Text('Choisir depuis la galerie'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.orange,
          ),
        ),
      ],
    );
  }
}