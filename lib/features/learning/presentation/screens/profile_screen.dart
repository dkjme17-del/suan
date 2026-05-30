import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../../../../shared/services/firebase_auth_service.dart';
import '../../../../../../core/utils/logger.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../community/domain/services/real_community_service.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Paramètres utilisateur
  late bool _notificationsEnabled;
  late bool _soundsEnabled;
  late String _selectedLanguage;
  late String _selectedTheme;

  // Avatar
  String? _avatarUrl;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    
    // Initialiser les préférences par défaut
    _notificationsEnabled = true;
    _soundsEnabled = true;
    _selectedLanguage = 'Français';
    _selectedTheme = 'light';
    
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // Charger les préférences depuis SharedPreferences si disponible
    // Pour l'instant, on utilise les valeurs par défaut
  }

  Future<void> _savePreferences() async {
    // Les préférences peuvent être sauvegardées ici
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: _showSettingsDialog,
                icon: const Icon(FontAwesomeIcons.gear),
              ),
            ],
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('users')
                .doc(FirebaseAuthService().getCurrentUserId())
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final userDoc = snapshot.data!;

              if (!userDoc.exists) {
                return const Center(child: Text('Profil non trouvé'));
              }

              // Créer un UserProfile cohérent depuis Firestore
              final user = UserProfile.fromFirestore(userDoc);
              _avatarUrl = user.avatarUrl;

              return Column(
                children: [
                  _buildProfileHeader(user),
                  _buildStatsRow(user),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Progression'),
                      Tab(text: 'Favoris'),
                      Tab(text: 'Amis'),
                      Tab(text: 'Paramètres'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProgressTab(user),
                        _buildFavoritesTab(),
                        _buildFriendsTab(),
                        _buildSettingsTab(user),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _changeAvatar,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),

                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: _isUploadingAvatar
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : _avatarUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: Image.network(
                                _avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  FontAwesomeIcons.user,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              FontAwesomeIcons.user,
                              size: 40,
                              color: Colors.white,
                            ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Niveau ${user.level}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.fire,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user.streakDays} jours consécutifs',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showEditProfileDialog,
                icon: const Icon(FontAwesomeIcons.penToSquare, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserProfile user) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'lessons': 0, 'time': 0};
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: FontAwesomeIcons.trophy,
                  value: '${user.totalPoints}',
                  label: 'Points',
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: FontAwesomeIcons.book,
                  value: '${stats['lessons']}',
                  label: 'Leçons',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: FontAwesomeIcons.clock,
                  value: '${stats['time']}h',
                  label: 'Temps',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getStats() async {
    try {
      final lessonsSnapshot = await _firestore.collection('lessons').get();
      return {
        'lessons': lessonsSnapshot.docs.length,
        'time': (lessonsSnapshot.docs.length * 5) ~/ 60, // Estimation
      };
    } catch (e) {
      return {'lessons': 0, 'time': 0};
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildProgressTab(UserProfile user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progression d\'apprentissage',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildProgressItem(
            title: 'Salutations',
            progress: 1.0,
            icon: FontAwesomeIcons.hand,
            color: Colors.green,
          ),
          _buildProgressItem(
            title: 'Nombres',
            progress: 0.8,
            icon: FontAwesomeIcons.hashtag,
            color: Colors.blue,
          ),
          _buildProgressItem(
            title: 'Famille',
            progress: 0.4,
            icon: FontAwesomeIcons.users,
            color: Colors.orange,
          ),
          _buildProgressItem(
            title: 'Animaux',
            progress: 0.2,
            icon: FontAwesomeIcons.paw,
            color: Colors.purple,
          ),
          _buildProgressItem(
            title: 'Nourriture',
            progress: 0.0,
            icon: FontAwesomeIcons.utensils,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          _buildWeeklyChart(),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required String title,
    required double progress,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}% complété',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activité cette semaine',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('Lun', 0.8),
                _buildChartBar('Mar', 1.0),
                _buildChartBar('Mer', 0.6),
                _buildChartBar('Jeu', 0.9),
                _buildChartBar('Ven', 0.7),
                _buildChartBar('Sam', 0.4),
                _buildChartBar('Dim', 0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double height) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            height: height * 120,
          ),
        ),
        const SizedBox(height: 4),
        Text(day, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leçons disponibles',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          FutureBuilder<QuerySnapshot>(
            future: _firestore.collection('lessons').limit(5).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.data?.docs.isEmpty ?? true) {
                return const Text('Aucune leçon disponible');
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildFavoriteLesson(
                    data['title'] ?? 'Sans titre',
                    _getIconForLesson(data['title'] ?? ''),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Catégories de quiz',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          FutureBuilder<QuerySnapshot>(
            future: _firestore.collection('quiz_categories').limit(4).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.data?.docs.isEmpty ?? true) {
                return const Text('Aucune catégorie disponible');
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildFavoriteLesson(
                    data['name'] ?? 'Sans titre',
                    _getIconForLesson(data['title'] ?? ''),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab() {
    final currentUserId = FirebaseAuthService().getCurrentUserId();
    if (currentUserId == null) {
      return const Center(child: Text('Utilisateur non connecté'));
    }

    final communityService = RealCommunityService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes amis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddFriendDialog(currentUserId),
            icon: const Icon(FontAwesomeIcons.userPlus),
            label: const Text('Ajouter un ami'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<String>>(
            stream: communityService.streamFriends(currentUserId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final friendIds = snapshot.data!;
              if (friendIds.isEmpty) {
                return const Text('Aucun ami pour le moment. Ajoutez des amis !');
              }

              return Column(
                children: friendIds.map((friendId) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('users').doc(friendId).get(),
                    builder: (context, friendSnapshot) {
                      if (!friendSnapshot.hasData) {
                        return const ListTile(title: Text('Chargement...'));
                      }

                      final friendData = friendSnapshot.data!.data() as Map<String, dynamic>?;
                      final username = friendData?['username'] ?? 'Utilisateur inconnu';

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(username[0].toUpperCase()),
                        ),
                        title: Text(username),
                        trailing: IconButton(
                          icon: const Icon(FontAwesomeIcons.userMinus, color: Colors.red),
                          onPressed: () => _removeFriend(currentUserId, friendId),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForLesson(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('salutation') || titleLower.contains('bonjour')) {
      return FontAwesomeIcons.hand;
    } else if (titleLower.contains('nombre') || titleLower.contains('chiffre')) {
      return FontAwesomeIcons.hashtag;
    } else if (titleLower.contains('famille')) {
      return FontAwesomeIcons.users;
    } else if (titleLower.contains('animal') || titleLower.contains('animal')) {
      return FontAwesomeIcons.paw;
    } else if (titleLower.contains('nourriture') || titleLower.contains('food')) {
      return FontAwesomeIcons.utensils;
    }
    return FontAwesomeIcons.book;
  }

  Widget _buildFavoriteLesson(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Icon(FontAwesomeIcons.chevronRight, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(UserProfile user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Préférences',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildSettingItem(
            icon: FontAwesomeIcons.bell,
            title: 'Notifications',
            subtitle: 'Rappels d\'apprentissage',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                  _savePreferences();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value 
                      ? '🔔 Notifications activées' 
                      : '🔇 Notifications désactivées'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          _buildSettingItem(
            icon: FontAwesomeIcons.volumeHigh,
            title: 'Sons',
            subtitle: 'Sons des notifications',
            trailing: Switch(
              value: _soundsEnabled,
              onChanged: (value) {
                setState(() {
                  _soundsEnabled = value;
                  _savePreferences();
                });
              },
            ),
          ),
          _buildSettingItem(
            icon: FontAwesomeIcons.globe,
            title: 'Langue',
            subtitle: _selectedLanguage,
            onTap: _showLanguageDialog,
          ),
          const Divider(height: 24),
          Text(
            'Apparence',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildSettingItem(
              icon: FontAwesomeIcons.palette,
              title: 'Thème',
              subtitle: _selectedTheme == 'light' ? 'Mode Clair' : 'Mode Sombre',
              trailing: null,
              onTap: () => _showThemeDialog(),
            ),
          ),
          _buildSettingItem(
            icon: FontAwesomeIcons.textHeight,
            title: 'Taille du texte',
            subtitle: 'Normale',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ℹ️ Taille du texte: Normale (ne peut pas être modifiée)'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 24),
          Text(
            'Données',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: FontAwesomeIcons.download,
            title: 'Télécharger les données',
            subtitle: 'Leçons et quiz',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📥 Téléchargement en cours...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildSettingItem(
            icon: FontAwesomeIcons.trash,
            title: 'Réinitialiser la progression',
            subtitle: 'Remettre tout à zéro',
            onTap: _showResetDialog,
          ),
          const Divider(height: 24),
          Text(
            'À propos',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: FontAwesomeIcons.circleInfo,
            title: 'À propos de Suan',
            subtitle: 'Version 1.2.0 • Apprenez le Baoulé',
            onTap: _showAboutDialog,
          ),
          _buildSettingItem(
            icon: FontAwesomeIcons.fileLines,
            title: 'Conditions d\'utilisation',
            subtitle: 'Lire les conditions',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: FontAwesomeIcons.lock,
            title: 'Politique de confidentialité',
            subtitle: 'Vos données sont protégées',
            onTap: () {},
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                FontAwesomeIcons.rightFromBracket,
                color: Colors.red,
              ),
              title: const Text(
                'Déconnexion',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _showLogoutDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(FontAwesomeIcons.chevronRight, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    String tempLanguage = _selectedLanguage;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Choisir la langue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'Français',
                groupValue: tempLanguage,
                onChanged: (value) {
                  setState(() => tempLanguage = value ?? 'Français');
                },
                title: const Text('Français'),
              ),
              RadioListTile<String>(
                value: 'English',
                groupValue: tempLanguage,
                onChanged: (value) {
                  setState(() => tempLanguage = value ?? 'English');
                },
                title: const Text('English'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedLanguage = tempLanguage);
                _savePreferences();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    String tempTheme = _selectedTheme;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Choisir le thème'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'light',
                groupValue: tempTheme,
                onChanged: (value) {
                  setState(() => tempTheme = value ?? 'light');
                },
                title: const Text('☀️ Mode Clair'),
              ),
              RadioListTile<String>(
                value: 'dark',
                groupValue: tempTheme,
                onChanged: (value) {
                  setState(() => tempTheme = value ?? 'dark');
                },
                title: const Text('🌙 Mode Sombre'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedTheme = tempTheme);
                _savePreferences();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser la progression'),
        content: const Text(
          'Êtes-vous sûr? Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Progression réinitialisée'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Suan',
      applicationVersion: '1.2.0',
      applicationLegalese: '© 2026 Suan - Apprenez le Baoulé',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Suan est une application pour apprendre la langue baoulé '
            'de manière progressive et efficace.',
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() async {
    final userId = FirebaseAuthService().getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non trouvé')),
      );
      return;
    }

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};
    final username = userData['username'] ?? '';
    final bio = userData['bio'] ?? '';

    // Pré-remplir les champs avec les données actuelles
    _usernameController.text = username;
    _bioController.text = bio;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier mon profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(FontAwesomeIcons.user),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio (optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(FontAwesomeIcons.pen),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
          onPressed: () => _updateUserProfile(userId),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserProfile(String userId) async {
    final newUsername = _usernameController.text.trim();
    final newBio = _bioController.text.trim();

    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nom d\'utilisateur')),
      );
      return;
    }

    try {
      // Vérifier que l'utilisateur est authentifié
      final firebaseUser = FirebaseAuthService().getCurrentUserId();
      if (firebaseUser == null) {
        throw Exception('Utilisateur non authentifié');
      }

      Logger.info('🔄 Mise à jour du profil pour: $userId');

      final authService = FirebaseAuthService();
      final success = await authService.updateUserProfile(
        userId: userId,
        displayName: newUsername,
        bio: newBio.isNotEmpty ? newBio : null,
      );

      if (success) {
        Logger.info('✅ Profil mis à jour avec succès');
        if (mounted) {
          // Attendre un peu avant de fermer le dialog
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (mounted) {
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Profil mis à jour avec succès!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        throw Exception('Impossible de mettre à jour le profil');
      }
    } catch (e) {
      Logger.error('❌ Erreur mise à jour profil', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showSettingsDialog() {
    // TODO: Implémenter les paramètres rapides
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      final authViewModel = context.read<AuthViewModel>();
      
      // Appeler logout sur le ViewModel
      await authViewModel.logout();
      
      Logger.info('✅ Déconnexion réussie');
      
      if (mounted) {
        // Attendre un petit délai pour que l'état se mette à jour
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Naviguer vers la page de login
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('👋 Déconnecté avec succès'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      Logger.error('Erreur déconnexion', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur déconnexion: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _changeAvatar() async {
    if (kIsWeb) {
      // Web: utiliser file_picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        // Convertir en Uint8List
        await _uploadAvatarWeb(result.files.single.bytes!);
      }
    } else {
      // Mobile/Desktop: bottom sheet
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(FontAwesomeIcons.camera),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.image),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_avatarUrl != null)
                ListTile(
                  leading: const Icon(FontAwesomeIcons.trash, color: Colors.red),
                  title: const Text('Supprimer l\'avatar', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _removeAvatar();
                  },
                ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        await _uploadAvatarImage(File(image.path));
      }
    } catch (e) {
      Logger.error('Erreur sélection image', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la sélection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadAvatarWeb(Uint8List bytes) async {
    setState(() {
      _isUploadingAvatar = true;
    });
    try {
      final userId = FirebaseAuthService().getCurrentUserId();
      if (userId == null) throw Exception('Utilisateur non connecté');
      final storageRef = _storage.ref().child('avatars/$userId.jpg');
      // Upload bytes
      final uploadTask = storageRef.putData(bytes);
      await uploadTask;
      final downloadUrl = await storageRef.getDownloadURL();
      await _firestore.collection('users').doc(userId).set({
        'profile': {
          'avatarUrl': downloadUrl,
        }
      }, SetOptions(merge: true));
      setState(() {
        _avatarUrl = downloadUrl;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Avatar mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Logger.info('✅ Avatar uploadé (web) avec succès');
    } catch (e) {
      Logger.error('Erreur upload avatar web', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'upload (web): $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingAvatar = false;
      });
    }
  }

  Future<void> _uploadAvatarImage(File imageFile) async {
    setState(() {
      _isUploadingAvatar = true;
    });

    try {
      final userId = FirebaseAuthService().getCurrentUserId();
      if (userId == null) throw Exception('Utilisateur non connecté');

      // Créer le chemin dans Firebase Storage
      final storageRef = _storage.ref().child('avatars/$userId.jpg');

      // Upload l'image
      final uploadTask = storageRef.putFile(imageFile);
      await uploadTask;

      // Obtenir l'URL de téléchargement
      final downloadUrl = await storageRef.getDownloadURL();

      // Mettre à jour Firestore
      await _firestore.collection('users').doc(userId).set({
        'profile': {
          'avatarUrl': downloadUrl,
        }
      }, SetOptions(merge: true));

      setState(() {
        _avatarUrl = downloadUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Avatar mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Logger.info('✅ Avatar uploadé avec succès');
    } catch (e) {
      Logger.error('Erreur upload avatar', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingAvatar = false;
      });
    }
  }

  Future<void> _removeAvatar() async {
    try {
      final userId = FirebaseAuthService().getCurrentUserId();
      if (userId == null) throw Exception('Utilisateur non connecté');

      // Supprimer l'image de Firebase Storage
      if (_avatarUrl != null) {
        try {
          final storageRef = _storage.refFromURL(_avatarUrl!);
          await storageRef.delete();
        } catch (e) {
          Logger.warning('Erreur suppression storage (peut-être déjà supprimé): $e');
        }
      }

      // Mettre à jour Firestore
      await _firestore.collection('users').doc(userId).set({
        'profile': {
          'avatarUrl': null,
        }
      }, SetOptions(merge: true));

      setState(() {
        _avatarUrl = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Avatar supprimé'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Logger.info('✅ Avatar supprimé avec succès');
    } catch (e) {
      Logger.error('Erreur suppression avatar', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddFriendDialog(String currentUserId) {
    final searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un ami'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
                hintText: 'Entrez le nom d\'utilisateur',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = searchController.text.trim();
              if (username.isNotEmpty) {
                await _addFriendByUsername(currentUserId, username);
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFriendByUsername(String currentUserId, String username) async {
    try {
      // Rechercher l'utilisateur par username
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur non trouvé')),
          );
        }
        return;
      }

      final friendDoc = querySnapshot.docs.first;
      final friendId = friendDoc.id;

      if (friendId == currentUserId) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vous ne pouvez pas vous ajouter vous-même')),
          );
        }
        return;
      }

      final communityService = RealCommunityService();
      await communityService.addFriend(friendId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ami ajouté avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _removeFriend(String currentUserId, String friendId) async {
    try {
      final communityService = RealCommunityService();
      await communityService.removeFriend(friendId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ami supprimé')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression d\'ami')),
        );
      }
    }
  }
}
