import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suan/core/theme/app_theme.dart';
import 'package:suan/shared/widgets/common_widgets.dart';
import '../viewmodels/auth_viewmodel.dart';

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(title: 'Choisir votre mode d\'apprentissage'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionnez le mode qui vous convient',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _ModeCard(
                      icon: Icons.school,
                      title: 'Mode Classique',
                      description: 'Apprenez avec des leçons structurées',
                      onTap: () => _selectMode(context, 'classic'),
                    ),
                    SizedBox(height: 16),
                    _ModeCard(
                      icon: Icons.games,
                      title: 'Mode Ludique',
                      description: 'Apprenez en jouant à des jeux',
                      onTap: () => _selectMode(context, 'ludique'),
                    ),
                    SizedBox(height: 16),
                    _ModeCard(
                      icon: Icons.hearing,
                      title: 'Mode Non Alphabétisé',
                      description: 'Apprentissage basé sur l\'audio',
                      onTap: () => _selectMode(context, 'non_alphabetic'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectMode(BuildContext context, String mode) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    await authVM.updateUserLearningMode(mode);
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        onTap: onTap,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 32),
            ),
            SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
