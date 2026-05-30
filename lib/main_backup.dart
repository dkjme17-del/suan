import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/mode_selection_page.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/learning/presentation/pages/home_page.dart';
import 'shared/services/auth_service.dart';
import 'shared/services/storage_service.dart';
import 'shared/services/lesson_service.dart';
import 'shared/services/quiz_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>(create: (_) => storageService),
        Provider<AuthService>(
          create: (_) => AuthService(storageService: storageService),
        ),
        Provider<LessonService>(create: (_) => LessonService()),
        Provider<QuizService>(create: (_) => QuizService()),
        ChangeNotifierProvider(
          create: (context) =>
              AuthViewModel(localAuthService: context.read<AuthService>())
                ..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Suan - Baoulé Learning',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/mode-selection': (context) => const ModeSelectionPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        if (authViewModel.isLoggedIn) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
