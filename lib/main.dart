import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/mode_selection_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/admin/presentation/pages/add_test_data_page.dart';
import 'features/chatbot/presentation/pages/chat_screen.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/learning/presentation/pages/main_home_page.dart';
import 'features/learning/presentation/pages/pronunciation_practice_page.dart';
import 'features/learning/presentation/pages/lesson_detail_page.dart';
import 'features/learning/presentation/viewmodels/learning_viewmodel.dart';
import 'features/quiz/presentation/pages/quiz_page.dart';
import 'features/quiz/presentation/viewmodels/quiz_viewmodel.dart';
import 'features/quiz/presentation/viewmodels/quiz_realtime_viewmodel.dart';
import 'features/user/presentation/pages/settings_page.dart';
import 'features/user/presentation/pages/achievements_page.dart';
import 'features/user/presentation/pages/realtime_leaderboard_page.dart';
import 'features/user/presentation/pages/statistics_page.dart';
import 'features/user/presentation/viewmodels/user_statistics_viewmodel.dart';
import 'shared/services/auth_service.dart';
import 'shared/services/firebase_auth_service.dart';
import 'shared/services/lesson_service.dart';
import 'shared/services/quiz_service.dart';
import 'shared/services/storage_service.dart';
import 'features/community/domain/services/community_service.dart';
import 'features/community/domain/services/real_community_service.dart';
import 'features/audio/domain/services/audio_service.dart';
import 'features/chatbot/domain/services/chatbot_service.dart';
import 'shared/widgets/baule_decoration.dart';
import 'core/theme/baule_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider(create: (_) => storageService),
        Provider(create: (_) => AuthService(storageService: storageService)),
        Provider(create: (_) => FirebaseAuthService()),
        Provider(create: (_) => LessonService()),
        Provider(create: (_) => QuizService()),
        Provider(create: (_) => CommunityService()),
        Provider(create: (_) => RealCommunityService()),
        Provider(create: (_) => AudioService()),
        ChangeNotifierProvider(create: (_) => ChatbotService()),

        // ViewModels
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            firebaseAuthService: context.read<FirebaseAuthService>(),
            localAuthService: context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LearningViewModel(
            lessonService: context.read<LessonService>(),
            communityService: context.read<RealCommunityService>(),
            storageService: context.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              QuizViewModel(quizService: context.read<QuizService>()),
        ),
        ChangeNotifierProvider(create: (context) => QuizRealtimeViewModel()),
        ChangeNotifierProvider(create: (context) => UserStatisticsViewModel()),
      ],
      child: MaterialApp(
        title: 'Suan - Apprenez le Baoulé',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Stack(
            children: [
              const Positioned.fill(
                child: BaulePatternBackground(
                  backgroundColor: BauleColors.creamWhite,
                  opacity: 0.08,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        BauleColors.gold.withValues(alpha: 0.04),
                        Colors.transparent,
                        BauleColors.deepBlack.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              ),
              if (child != null) child,
            ],
          );
        },
        home: _buildHome(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/chatbot': (context) => const ChatScreen(),
          '/mode-selection': (context) => const ModeSelectionPage(),
          '/home': (context) => const MainHomePage(),
          '/pronunciation-practice': (context) =>
              const PronunciationPracticePage(),
          '/lesson': (context) {
            final lessonId =
                ModalRoute.of(context)?.settings.arguments as String?;
            return LessonDetailPage(lessonId: lessonId ?? '');
          },
          '/quiz': (context) => const QuizListPage(),
          '/quiz-play': (context) {
            final quizId =
                ModalRoute.of(context)?.settings.arguments as String?;
            return QuizPlayPage(quizId: quizId ?? '');
          },
          '/settings': (context) => const SettingsPage(),
          '/achievements': (context) => const AchievementsPage(),
          '/leaderboard': (context) => const RealtimeLeaderboardPage(),
          '/add-test-data': (context) => const AddTestDataPage(),
          '/catalogue-baoule': (context) => const StatisticsPage(),
        },
      ),
    );
  }

  Widget _buildHome() {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        // Initialiser le viewmodel
        if (authVM.currentUser == null && !authVM.isLoading) {
          Future.microtask(() => authVM.init());
        }

        if (authVM.isLoggedIn) {
          return const MainHomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
