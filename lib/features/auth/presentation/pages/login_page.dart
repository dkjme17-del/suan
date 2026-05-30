import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../../../../core/theme/baule_colors.dart';
import '../../../../shared/widgets/baule_decoration.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    return Scaffold(
      backgroundColor: BauleColors.creamWhite,
      body: Stack(
        children: [
          // Fond avec motifs géométriques Baoulé
          BaulePatternBackground(
            backgroundColor: BauleColors.creamWhite,
            primaryColor: BauleColors.gold,
            opacity: 0.08,
          ),
          
          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isIOS ? 20 : 24, 
                  vertical: isIOS ? 12 : 16
                ),
                child: Consumer<AuthViewModel>(
                  builder: (context, authVM, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isIOS ? 24 : 32),
                        
                        // Décoration Baoulé - Cercles géométriques en haut à droite
                        Stack(
                          children: [
                            BauleCirclePattern(
                              color: BauleColors.gold,
                              size: 100,
                              alignment: Alignment.topRight,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Titre avec accent Baoulé
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: BauleColors.gold,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'connexion',
                                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: BauleColors.deepBlack,
                                        fontSize: 28,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Description
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    'Entrez vos identifiants pour accéder\nà votre compte.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: BauleColors.lightText,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        
                        // Décoration Baoulé en haut
                        BauleDecorationBorder(
                          height: 35,
                          thickness: 2,
                          isTop: true,
                        ),
                        const SizedBox(height: 24),
                        
                        // Email Field avec décoration Baoulé
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: BauleColors.gold,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: BauleColors.gold.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Adresse Email',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: BauleColors.gold,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: BauleColors.gold,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              fontSize: isIOS ? 16 : 14,
                              color: BauleColors.darkText,
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Password Field avec décoration Baoulé
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: BauleColors.gold,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: BauleColors.gold.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Mot de passe',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: BauleColors.gold,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: BauleColors.gold,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: BauleColors.gold,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: isIOS ? 16 : 14,
                              color: BauleColors.darkText,
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Remember Me & Forgot Password Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _rememberMe
                                          ? BauleColors.gold
                                          : Colors.white,
                                      border: Border.all(
                                        color: _rememberMe
                                            ? BauleColors.gold
                                            : BauleColors.borderColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: _rememberMe
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: BauleColors.deepBlack,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Se souvenir de moi',
                                    style: TextStyle(
                                      color: BauleColors.lightText,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/forgot-password');
                              },
                              child: Text(
                                'Mot de passe oublié',
                                style: TextStyle(
                                  color: BauleColors.gold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Error message
                        if (authVM.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: BauleColors.redOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: BauleColors.redOrange.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: BauleColors.redOrange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      authVM.error!,
                                      style: TextStyle(
                                        color: BauleColors.redOrange,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        // Login Button avec style Baoulé
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authVM.isLoading
                                ? null
                                : () async {
                                    final success = await authVM.login(
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                    if (success && mounted) {
                                      Navigator.of(context)
                                          .pushReplacementNamed('/home');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BauleColors.gold,
                              disabledBackgroundColor:
                                  BauleColors.gold.withOpacity(0.6),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: BauleColors.gold.withOpacity(0.4),
                            ),
                            child: authVM.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        BauleColors.deepBlack,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'connexion',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: BauleColors.deepBlack,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Sign Up Link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Vous n'avez pas de compte? ",
                              style: TextStyle(
                                color: BauleColors.lightText,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: "S'inscrire ici",
                                  style: TextStyle(
                                    color: BauleColors.gold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).pushNamed('/register');
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Décoration Baoulé en bas
                        BauleDecorationBorder(
                          height: 35,
                          thickness: 2,
                          isTop: false,
                        ),
                        const SizedBox(height: 20),
                        
                        // Divider avec style Baoulé
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey[300] ?? Colors.grey,
                                      BauleColors.gold.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Ou continuer avec',
                                style: TextStyle(
                                  color: BauleColors.lightText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      BauleColors.gold.withOpacity(0.5),
                                      Colors.grey[300] ?? Colors.grey,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Social Login Buttons avec accents Baoulé
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Facebook
                            _buildSocialButton(
                              context,
                              Icons.facebook,
                              const Color(0xFF1877F2),
                              'Facebook',
                            ),
                            const SizedBox(width: 16),
                            
                            // Google
                            _buildSocialButton(
                              context,
                              Icons.search,
                              const Color(0xFF4285F4),
                              'Google',
                            ),
                            const SizedBox(width: 16),
                            
                            // Apple
                            _buildSocialButton(
                              context,
                              Icons.apple,
                              Colors.black,
                              'Apple',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper pour construire les boutons sociaux avec style Baoulé
  Widget _buildSocialButton(
    BuildContext context,
    IconData icon,
    Color iconColor,
    String label,
  ) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label login coming soon'),
            duration: const Duration(seconds: 2),
            backgroundColor: BauleColors.gold,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: BauleColors.gold.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: BauleColors.gold.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }
}
