// 📱 GUIDE D'INTÉGRATION - ÉLÉMENTS BAOULÉ
// ========================================

// 🎯 Pour appliquer le design Baoulé à n'importe quelle page:

// 1️⃣ IMPORTS NÉCESSAIRES
// ======================
import 'package:suan/core/theme/baule_colors.dart';
import 'package:suan/shared/widgets/baule_decoration.dart';

// 2️⃣ STRUCTURE DE BASE
// ====================

class MyPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BauleColors.creamWhite,
      body: Stack(
        children: [
          // Fond avec motifs Baoulé
          BaulePatternBackground(
            backgroundColor: BauleColors.creamWhite,
            primaryColor: BauleColors.gold,
            opacity: 0.08,
          ),
          
          // Votre contenu ici
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Décoration en haut
                  BauleDecorationBorder(isTop: true),
                  // ... votre contenu
                  // Décoration en bas
                  BauleDecorationBorder(isTop: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3️⃣ COMPOSANTS RÉUTILISABLES
// ============================

// ✅ CHAMPS DE TEXTE
TextField(
  decoration: InputDecoration(
    hintText: 'Votre texte',
    prefixIcon: Icon(Icons.email_outlined, color: BauleColors.gold),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: BauleColors.gold, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: BauleColors.gold, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
  ),
),

// ✅ BOUTONS
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: BauleColors.gold,
    foregroundColor: BauleColors.deepBlack,
    elevation: 4,
    shadowColor: BauleColors.gold.withOpacity(0.4),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  child: const Text('Mon Bouton'),
),

// ✅ TITRE AVEC ACCENT BAOULÉ
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
      'Mon Titre',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: BauleColors.deepBlack,
      ),
    ),
  ],
),

// ✅ CERCLES GÉOMÉTRIQUES
BauleCirclePattern(
  color: BauleColors.gold,
  size: 100,
  alignment: Alignment.topRight,
),

// ✅ CHECKBOX
Container(
  width: 20,
  height: 20,
  decoration: BoxDecoration(
    color: isChecked ? BauleColors.gold : Colors.white,
    border: Border.all(
      color: isChecked ? BauleColors.gold : BauleColors.borderColor,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(4),
  ),
  child: isChecked 
    ? const Icon(Icons.check, size: 14, color: BauleColors.deepBlack)
    : null,
),

// ✅ BOUTONS SOCIAUX
Container(
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
  child: Icon(Icons.facebook, color: iconColor),
),

// ✅ MESSAGE D'ERREUR
Container(
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
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          'Votre message d\'erreur',
          style: TextStyle(color: BauleColors.redOrange),
        ),
      ),
    ],
  ),
),

// 4️⃣ PALETTE RAPIDE
// =================
// Titres & texte principal: BauleColors.deepBlack
// Accents & highlights: BauleColors.gold
// Fond: BauleColors.creamWhite
// Texte secondaire: BauleColors.lightText
// Erreurs: BauleColors.redOrange
// Icônes: BauleColors.gold ou BauleColors.deepBlack

// 5️⃣ PAGES À AMÉLIORER
// ====================
// ✅ Login Page          - COMPLÉTÉE
// ✅ Register Page       - EN COURS
// ⏳ Forgot Password     - À FAIRE
// ⏳ Mode Selection      - À FAIRE
// ⏳ Home Page          - À FAIRE
// ⏳ Profile Page       - À FAIRE
// ⏳ Chat/Messages      - À FAIRE
// ⏳ Community          - À FAIRE

// 6️⃣ CONSEILS D'UTILISATION
// ==========================
// 1. Toujours grouper les éléments Baoulé au début du Scaffold
// 2. Maintenir l'espacement de 8px entre les sections
// 3. Utiliser les constantes BauleColors, ne pas coder les couleurs en dur
// 4. Garder les ombres douces avec opacity 0.08-0.4
// 5. Utiliser des borderRadius uniformes: 8px (petits), 12px (moyens)
// 6. Combiner les décorateurs (haut et bas) pour cadrer le contenu
