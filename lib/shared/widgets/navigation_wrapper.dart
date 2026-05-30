import 'package:flutter/material.dart';
import 'package:suan/core/theme/app_theme.dart';
import 'package:suan/features/learning/presentation/pages/home_page.dart';
import 'package:suan/features/quiz/presentation/pages/quiz_page.dart';
import 'package:suan/features/user/presentation/pages/settings_page.dart';

/// Wrapper de navigation principale avec 5 onglets
class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(), // Accueil
    const LearningPage(), // Apprendre
    const QuizListPage(), // Jeux
    const CommunityPage(), // Communauté
    const SettingsPage(), // Profil
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Apprendre'),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: 'Jeux'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Communauté',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

/// Page d'apprentissage (leçons)
class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage(); // Réutilise la page existing
  }
}

/// Page de communauté (placeholder)
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communauté'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            const Text(
              'Communauté',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Connectez-vous avec d\'autres apprenants, partagez vos progrès et participez à des défis collectifs!',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
