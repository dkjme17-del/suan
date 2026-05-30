import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suan/core/theme/app_theme.dart';
import 'package:suan/shared/widgets/common_widgets.dart';
import 'package:suan/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Paramètres',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          final user = authVM.currentUser;
          if (user == null) return const SizedBox();

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profil utilisateur
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                  ),
                                  SizedBox(height: 8),
                                  LevelBadge(
                                    level: int.tryParse(user.currentLevel) ?? 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Mode d'apprentissage
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mode d\'apprentissage',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 12),
                        CustomCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getModeLabel(user.learningMode),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Cliquez pour changer',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Statistiques
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistiques',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Color(0xFFFFB800),
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${user.totalPoints}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Points',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: CustomCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      color: Color(0xFFFF6B6B),
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${user.currentStreak}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Séries',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Autres options
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Autres',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 12),
                        CustomCard(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications,
                                    color: AppTheme.primaryColor,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Notifications',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        CustomCard(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.language,
                                    color: AppTheme.primaryColor,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Langue',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        CustomCard(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: AppTheme.primaryColor,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'À propos',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Section développeur (uniquement en mode debug)
                  if (kDebugMode)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Développement',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 12),
                          CustomCard(
                            onTap: () =>
                                Navigator.pushNamed(context, '/add-test-data'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.science,
                                      color: AppTheme.primaryColor,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Ajouter des données de test',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 16),

                  // Bouton de déconnexion
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text('Se déconnecter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirmer la déconnexion'),
                            content: Text(
                              'Êtes-vous sûr de vouloir vous déconnecter?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await authVM.logout();
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed('/login');
                                  }
                                },
                                child: Text(
                                  'Confirmer',
                                  style: TextStyle(color: AppTheme.accentColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getModeLabel(String mode) {
    switch (mode) {
      case 'ludique':
        return 'Mode Ludique';
      case 'non_alphabetic':
        return 'Mode Non Alphabétisé';
      case 'classic':
      default:
        return 'Mode Classique';
    }
  }
}
