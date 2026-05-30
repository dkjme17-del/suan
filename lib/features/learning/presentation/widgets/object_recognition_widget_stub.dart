import 'package:flutter/material.dart';

class ObjectRecognitionWidget extends StatelessWidget {
  const ObjectRecognitionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.25), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.camera_alt_outlined, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Caméra / reconnaissance d'objets indisponible sur Chrome (Web).\n"
              "Lance l'app sur Windows/Android pour utiliser cette fonctionnalité.",
              style: TextStyle(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

