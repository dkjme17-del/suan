import 'dart:io';
import 'package:flutter/material.dart' hide ProgressIndicator;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suan/core/theme/app_theme.dart';
import 'package:suan/features/user/presentation/viewmodels/user_realtime_viewmodel.dart';
import 'package:suan/shared/services/firebase_service.dart';

/// ÉCRAN 10: Profil Utilisateur - TEMPS RÉEL FIRESTORE
class UserProfilePage extends StatefulWidget {
  final String? userId; // ID utilisateur optionnel

  const UserProfilePage({super.key, this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isUploading = false;

  Future<void> _pickAndUploadProfilePicture() async {
    if (_isUploading) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery, // Default gallery, can add dialog for camera
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      if (!mounted) return;

      final userVM = context.read<UserRealtimeViewModel>();
      if (userVM.userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur: utilisateur non identifié')),
          );
        }
        return;
      }

      final file = File(image.path);
      final firebaseService = FirebaseService();
      await firebaseService.uploadProfilePicture(userVM.userId, file);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Photo de profil mise à jour !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Erreur upload: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialiser le ViewModel avec l'ID utilisateur si fourni
    if (widget.userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserRealtimeViewModel>().initialize(widget.userId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: context.read<UserRealtimeViewModel>().streamUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final userData = snapshot.data?.data() ?? {};

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header - Données temps réel Firestore
                _buildProfileHeader(context, userData),
                _buildStatsSection(context, userData),
                _buildSettingsSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    Map<String, dynamic> userData,
  ) {
    final username = userData['username'] ?? userData['name'] ?? 'Utilisateur';
    final email = userData['email'] ?? 'email@example.com';
    final level = userData['currentLevel'] ?? userData['level'] ?? 'beginner';
    final avatar = userData['avatar'] ?? '👤';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isUploading ? null : _pickAndUploadProfilePicture,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  if (avatar.startsWith('http'))
                    ClipOval(
                      child: Image.network(
                        avatar,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                    )
                  else
                    Icon(Icons.person, size: 40, color: Colors.white),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(
              color: Colors
                  .black, // Changed from white to black for better visibility
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              color: Colors
                  .black54, // Changed from white70 to black54 for better contrast
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(
                alpha: 0.2,
              ), // Adjusted for better contrast
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Niveau: ${_levelToFrench(level)}',
              style: const TextStyle(
                color: Colors
                    .black87, // Changed from white to black87 for better readability
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    Map<String, dynamic> userData,
  ) {
    final stats = userData['stats'] as Map<String, dynamic>? ?? {};
    final totalPoints = (stats['totalPoints'] as num?)?.toInt() ?? 0;
    final streak = (stats['currentStreak'] as num?)?.toInt() ?? 0;
    final lessonsCompleted = (stats['lessonsCompleted'] as num?)?.toInt() ?? 0;
    final quizzesCompleted = (stats['quizzesCompleted'] as num?)?.toInt() ?? 0;
    // Ajout du nombre d'amis
    final friends = userData['friends'] as List?;
    final friendsCount = friends?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard('⭐', 'Points', '$totalPoints'),
              _buildStatCard('🔥', 'Série', '$streak jours'),
              _buildStatCard('📚', 'Leçons', '$lessonsCompleted'),
              _buildStatCard('🧠', 'Quiz', '$quizzesCompleted'),
              _buildStatCard('👥', 'Amis', '$friendsCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.notifications,
            label: 'Notifications',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications settings')),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.language,
            label: 'Langue',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language settings')),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.logout,
            label: 'Déconnexion',
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _levelToFrench(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case '1':
        return 'Débutant';
      case 'intermediate':
      case '2':
        return 'Intermédiaire';
      case 'advanced':
      case '3':
        return 'Avancé';
      default:
        return level;
    }
  }
}
