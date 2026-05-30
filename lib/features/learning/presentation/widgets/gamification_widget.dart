import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:confetti/confetti.dart';

class GamificationWidget extends StatefulWidget {
  final int points;
  final int streak;
  final int level;
  final VoidCallback? onAchievementTap;

  const GamificationWidget({
    Key? key,
    required this.points,
    required this.streak,
    required this.level,
    this.onAchievementTap,
  }) : super(key: key);

  @override
  State<GamificationWidget> createState() => _GamificationWidgetState();
}

class _GamificationWidgetState extends State<GamificationWidget>
    with TickerProviderStateMixin {
  late AnimationController _streakController;
  late AnimationController _pointsController;
  late Animation<double> _streakAnimation;
  late Animation<double> _pointsAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _streakController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pointsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _streakAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _streakController, curve: Curves.elasticOut),
    );

    _pointsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pointsController, curve: Curves.easeOutBack),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Démarrer les animations
    _streakController.repeat(reverse: true);
    _pointsController.forward();
  }

  @override
  void dispose() {
    _streakController.dispose();
    _pointsController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStreakCard(),
              _buildPointsCard(),
              _buildLevelCard(),
            ],
          ),
          const SizedBox(height: 20),
          _buildAchievementsRow(),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _streakAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _streakAnimation.value,
                  child: Icon(
                    FontAwesomeIcons.fire,
                    color: Colors.orange,
                    size: 32,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.streak}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              'jours',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(FontAwesomeIcons.coins, color: Colors.amber, size: 32),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _pointsAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pointsAnimation.value,
                  child: Text(
                    '${widget.points}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                );
              },
            ),
            Text(
              'points',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              FontAwesomeIcons.trophy,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'N${widget.level}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              'niveau',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsRow() {
    return Container(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildAchievementBadge(
            icon: FontAwesomeIcons.medal,
            color: Colors.amber,
            title: 'Premier mot',
            isUnlocked: widget.points >= 10,
          ),
          _buildAchievementBadge(
            icon: FontAwesomeIcons.graduationCap,
            color: Colors.blue,
            title: 'Étudiant',
            isUnlocked: widget.points >= 100,
          ),
          _buildAchievementBadge(
            icon: FontAwesomeIcons.star,
            color: Colors.purple,
            title: 'Expert',
            isUnlocked: widget.points >= 500,
          ),
          _buildAchievementBadge(
            icon: FontAwesomeIcons.crown,
            color: Colors.orange,
            title: 'Maître',
            isUnlocked: widget.points >= 1000,
          ),
          _buildAchievementBadge(
            icon: FontAwesomeIcons.gem,
            color: Colors.red,
            title: 'Légende',
            isUnlocked: widget.points >= 5000,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge({
    required IconData icon,
    required Color color,
    required String title,
    required bool isUnlocked,
  }) {
    return GestureDetector(
      onTap: isUnlocked ? widget.onAchievementTap : null,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isUnlocked
              ? color.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? color.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isUnlocked ? color : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isUnlocked ? color : Colors.grey,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
