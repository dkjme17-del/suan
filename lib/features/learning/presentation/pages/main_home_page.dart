import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../audio/domain/services/audio_service.dart';
import '../../../community/domain/services/real_community_service.dart';
import '../viewmodels/learning_viewmodel.dart';
import '../screens/quiz_screen.dart';
import '../screens/community_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/learning_screen.dart';
import '../widgets/home_dashboard.dart';
import '../../../user/presentation/pages/statistics_page.dart';
import '../../../../core/utils/logger.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _servicesInitialized = false;

  final List<Widget> _pages = [
    const HomeDashboard(),
    const LearningScreen(),
    const QuizScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
    const StatisticsPage(),
  ];

  final List<IconData> _icons = [
    FontAwesomeIcons.house,
    FontAwesomeIcons.bookOpen,
    FontAwesomeIcons.gamepad,
    FontAwesomeIcons.users,
    FontAwesomeIcons.user,
    FontAwesomeIcons.masksTheater,
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialiser les services
      await AudioService().initialize();

      // L'initialisation du service communauté sera faite dans le build method
      // avec un Consumer pour s'assurer que le contexte est disponible
    } catch (e) {
      Logger.error('Erreur initialisation services', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LearningViewModel, RealCommunityService>(
      builder: (context, learningVM, communityService, _) {
        // Initialiser le service communauté avec l'utilisateur courant
        if (learningVM.currentUser != null && !_servicesInitialized) {
          communityService.setCurrentUser(learningVM.currentUser!);
          _servicesInitialized = true;
        }

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _pages,
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'main_chat_fab',
            onPressed: () => Navigator.pushNamed(context, '/chatbot'),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.chat_bubble_outline),
          ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60,
        items: _icons
            .map((icon) => Icon(icon, size: 24, color: Colors.white))
            .toList(),
        color: Theme.of(context).primaryColor,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
