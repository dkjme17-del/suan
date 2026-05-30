import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../community/domain/services/real_community_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communauté'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Classement'),
            Tab(text: 'Amis'),
            Tab(text: 'Actualités'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardTab(),
          _buildFriendsTab(),
          _buildFeedTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          FontAwesomeIcons.plus,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return StreamBuilder<List<UserProfile>>(
      stream: RealCommunityService().streamLeaderboard(limit: 1000),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final leaderboard = snapshot.data ?? [];
        if (leaderboard.isEmpty) {
          return const Center(child: Text('Aucun utilisateur trouvé.'));
        }

        return Column(
          children: [
            _buildTopThree(leaderboard),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final user = leaderboard[index];
                  return _buildLeaderboardItem(user, index + 1);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopThree(List<UserProfile> leaderboard) {
    if (leaderboard.length < 3) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Top 3',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPodiumUser(leaderboard[1], 2, Colors.grey),
              _buildPodiumUser(leaderboard[0], 1, Colors.amber),
              _buildPodiumUser(leaderboard[2], 3, Colors.brown),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumUser(UserProfile user, int rank, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color, width: 2),
          ),
          child: const Icon(
            FontAwesomeIcons.user,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.username,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${user.totalPoints} pts',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(UserProfile user, int rank) {
    return InkWell(
      onTap: () => _showUserDetails(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
                color: rank <= 3
                    ? _getMedalColor(rank).withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? _getMedalColor(rank) : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.bio ?? 'Pas de bio',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Niveau ${user.level} • ${user.streakDays} jours',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.totalPoints}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  'points',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(UserProfile user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                user.bio ?? 'Aucune bio disponible.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text('Points: ${user.totalPoints}'),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('Niveau: ${user.level}'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Amis: ${user.friends.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Rejoint le ${user.createdAt.toLocal().toString().split(' ').first}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFriendsTab() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Connectez-vous pour voir vos amis.'));
    }

    return Column(
      children: [
        _buildAddFriendSection(),
        Expanded(
          child: StreamBuilder<DocumentSnapshot<Object?>>(
            stream: RealCommunityService().streamUserProfile(currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('Profil introuvable.'));
              }

              final rawData = snapshot.data!.data();
              final data = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
              final friendIds = List<String>.from(data['friends'] ?? []);

              if (friendIds.isEmpty) {
                return _buildEmptyFriendsState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: friendIds.length,
                itemBuilder: (context, index) {
                  final friendId = friendIds[index];
                  return _buildFriendItem(friendId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddFriendSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.userPlus,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ajoutez des amis pour apprendre ensemble!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _showAddFriendDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFriendsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.userFriends,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun ami pour le moment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des amis pour partager votre progression',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showAddFriendDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ajouter un ami'),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(String friendId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(friendId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
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
            child: const Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Chargement...'),
              ],
            ),
          );
        }

        final friendData = snapshot.data!.data() as Map<String, dynamic>?;
        final username = friendData?['username'] ?? 'Utilisateur inconnu';

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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  FontAwesomeIcons.user,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ami',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.userMinus,
                  color: Colors.red,
                ),
                onPressed: () => _removeFriend(friendId),
                tooltip: 'Supprimer cet ami',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedTab() {
    return StreamBuilder<List<CommunityPost>>(
      stream: RealCommunityService().streamCommunityPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text('Aucun post pour le moment.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildPostItem(post);
          },
        );
      },
    );
  }

  Widget _buildPostItem(CommunityPost post) {
    final authorName = post.username;
    final timestamp = post.createdAt;
    final content = post.content;
    final imageUrl = post.imageUrl;
    final likes = post.likes;
    final comments = post.comments;
    final postId = post.id;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  FontAwesomeIcons.user,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (imageUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: const Center(
                child: Icon(
                  FontAwesomeIcons.image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionButton(
                icon: FontAwesomeIcons.heart,
                count: likes,
                onTap: () => _likePost(postId),
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: FontAwesomeIcons.comment,
                count: comments.length,
                onTap: () => _showComments(postId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} j';
    }
  }

  void _showAddFriendDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un ami'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nom d\'utilisateur',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = controller.text.trim();
              if (username.isEmpty) return;

              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez vous connecter.')),
                );
                return;
              }

              try {
                // Rechercher l'utilisateur par username
                final querySnapshot = await FirebaseFirestore.instance
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

                if (friendId == currentUser.uid) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vous ne pouvez pas vous ajouter vous-même')),
                    );
                  }
                  return;
                }

                // Assurer que le service sait qui est l'utilisateur courant
                RealCommunityService().setCurrentUser(
                  UserProfile(
                    id: currentUser.uid,
                    username: currentUser.displayName ?? 'Utilisateur',
                    level: 1,
                    totalPoints: 0,
                    streakDays: 0,
                    createdAt: DateTime.now(),
                  ),
                );

                await RealCommunityService().addFriend(friendId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ami ajouté avec succès!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur ajout ami: $e')),
                  );
                }
              }

              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Partager votre progression',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Que voulez-vous partager?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final content = controller.text.trim();
                    if (content.isEmpty) return;

                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez vous connecter.')),
                      );
                      return;
                    }

                    // Assurer que le service connaît l'utilisateur courant
                    RealCommunityService().setCurrentUser(
                      UserProfile(
                        id: currentUser.uid,
                        username: currentUser.displayName ?? 'Utilisateur',
                        level: 1,
                        totalPoints: 0,
                        streakDays: 0,
                        createdAt: DateTime.now(),
                      ),
                    );

                    await RealCommunityService().createPost(content: content);
                    Navigator.pop(context);
                  },
                  child: const Text('Publier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _likePost(String postId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Assurer que le service connaît l'utilisateur courant
    RealCommunityService().setCurrentUser(
      UserProfile(
        id: currentUser.uid,
        username: currentUser.displayName ?? 'Utilisateur',
        level: 1,
        totalPoints: 0,
        streakDays: 0,
        createdAt: DateTime.now(),
      ),
    );

    await RealCommunityService().likePost(postId);
  }

  void _showComments(String postId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Commentaires',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<String>>(
                future: RealCommunityService().getPostComments(postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data ?? [];
                  if (comments.isEmpty) {
                    return const Text('Aucun commentaire pour le moment.');
                  }

                  return Column(
                    children: comments
                        .map((comment) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(comment),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setModalState) {
                  final _commentController = TextEditingController();
                  return TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Ajouter un commentaire',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.send),
                    ),
                    onSubmitted: (value) async {
                      if (value.trim().isEmpty) return;
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez vous connecter')));
                        }
                        return;
                      }
                      await RealCommunityService().commentPost(postId: postId, comment: value.trim());
                      _commentController.clear();
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeFriend(String friendId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter.')),
        );
      }
      return;
    }

    // Assurer que le service sait qui est l'utilisateur courant
    RealCommunityService().setCurrentUser(
      UserProfile(
        id: currentUser.uid,
        username: currentUser.displayName ?? 'Utilisateur',
        level: 1,
        totalPoints: 0,
        streakDays: 0,
        createdAt: DateTime.now(),
      ),
    );

    try {
      await RealCommunityService().removeFriend(friendId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ami supprimé avec succès!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur suppression ami: $e')),
        );
      }
    }
  }
}
