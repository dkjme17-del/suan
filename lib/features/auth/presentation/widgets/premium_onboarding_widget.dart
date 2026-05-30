import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PremiumOnboardingWidget extends StatefulWidget {
  final Function()? onGetStarted;
  final VoidCallback? onSkip;

  const PremiumOnboardingWidget({
    Key? key,
    this.onGetStarted,
    this.onSkip,
  }) : super(key: key);

  @override
  State<PremiumOnboardingWidget> createState() => _PremiumOnboardingWidgetState();
}

class _PremiumOnboardingWidgetState extends State<PremiumOnboardingWidget>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController(initialPage: 0);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD97706),
      body: SafeArea(
        child: Column(
          children: [
            _buildSkipButton(),
            Expanded(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return _buildOnboardingPage(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: TextButton(
        onPressed: widget.onSkip,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white.withValues(alpha: 0.8),
        ),
        child: const Text('Passer'),
      ),
    );
  }

  Widget _buildOnboardingPage(int index) {
    switch (index) {
      case 0:
        return _buildWelcomePage();
      case 1:
        return _buildFeaturesPage();
      case 2:
        return _buildLearningPage();
      case 3:
        return _buildCommunityPage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomePage() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              FontAwesomeIcons.graduationCap,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Bienvenue dans\nSuan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Votre voyage pour apprendre\nle baoulé commence ici',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Text(
            'Découvrez nos fonctionnalités',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(        
            child: Column(
              children: [
                _buildFeatureCard(
                  icon: FontAwesomeIcons.microphone,
                  title: 'Audio & Prononciation',
                  description: 'Enregistrez et améliorez votre prononciation avec notre IA avancée',
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(height: 20),
                _buildFeatureCard(
                  icon: FontAwesomeIcons.camera,
                  title: 'Reconnaissance d\'objets',
                  description: 'Pointez votre caméra et découvrez le nom des objets en baoulé',
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 20),
                _buildFeatureCard(
                  icon: FontAwesomeIcons.gamepad,
                  title: 'Jeux & Quiz',
                  description: 'Apprenez en vous amusant avec nos quiz interactifs',
                  color: const Color(0xFF8B5CF),
                ),
                const SizedBox(height: 20),
                _buildFeatureCard(
                  icon: FontAwesomeIcons.users,
                  title: 'Communauté',
                  description: 'Connectez-vous avec d\'autres apprenants et partagez votre progression',
                  color: const Color(0xFF3B82F6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPage() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Text(
            'Apprentissage personnalisé',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildLearningMode(
                  icon: FontAwesomeIcons.book,
                  title: 'Classique',
                  description: 'Apprentissage traditionnel avec leçons structurées',
                  isSelected: true,
                ),
                const SizedBox(height: 16),
                _buildLearningMode(
                  icon: FontAwesomeIcons.gamepad,
                  title: 'Ludique',
                  description: 'Apprentissage par jeux et défis',
                  isSelected: false,
                ),
                const SizedBox(height: 16),
                _buildLearningMode(
                  icon: FontAwesomeIcons.child,
                  title: 'Enfant',
                  description: 'Interface simplifiée pour les plus jeunes',
                  isSelected: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningMode({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // Sélectionner le mode d'apprentissage
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFD97706) : Colors.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFD97706) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? const Color(0xFFD97706) : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                FontAwesomeIcons.checkCircle,
                color: Color(0xFFD97706),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityPage() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Text(
            'Rejoignez notre communauté',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCommunityFeature(
                      icon: FontAwesomeIcons.trophy,
                      title: 'Classements',
                      description: 'Comparez votre progression',
                    ),
                    _buildCommunityFeature(
                      icon: FontAwesomeIcons.userFriends,
                      title: 'Amis',
                      description: 'Apprenez ensemble',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCommunityFeature(
                      icon: FontAwesomeIcons.comments,
                      title: 'Forum',
                      description: 'Posez vos questions',
                    ),
                    _buildCommunityFeature(
                      icon: FontAwesomeIcons.shareAlt,
                      title: 'Partage',
                      description: 'Diffusez vos succès',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton précédent
          IconButton(
            onPressed: _currentPage > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: const Icon(
              FontAwesomeIcons.arrowLeft,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          // Indicateurs de page
          Row(
            children: [
              for (int i = 0; i < 4; i++)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == _currentPage ? Colors.white : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
          
          // Bouton suivant
          IconButton(
            onPressed: _currentPage < 3
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: const Icon(
              FontAwesomeIcons.arrowRight,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
