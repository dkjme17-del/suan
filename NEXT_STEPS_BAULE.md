🔧 NEXT STEPS - CONTINUATION IMMÉDIATE
=======================================

## ⏳ ÉTAPE 1: COMPLÉTER REGISTER PAGE (Estimé: 1h)
================================================

FICHIER: lib/features/auth/presentation/pages/register_page.dart

### Remplacements à faire:

1. **Tous les Color(0xFF22C55E) → BauleColors.gold**
   Lignes approximatives: 478, 480, 523
   
   Avant:
   ```dart
   backgroundColor: const Color(0xFF22C55E),
   ```
   
   Après:
   ```dart
   backgroundColor: BauleColors.gold,
   foregroundColor: BauleColors.deepBlack,
   ```

2. **Tous les Colors.grey[X] pour les champs → BauleColors.***
   
   Remplacer:
   - `Colors.grey[400]` → `BauleColors.lightText.withOpacity(0.5)`
   - `Colors.grey[600]` → `BauleColors.gold`
   - `Colors.white` → `Colors.white` (KEEP)
   - `Colors.black87` → `BauleColors.deepBlack`

3. **Bordures des champs**
   
   Remplacer:
   ```dart
   boxShadow: [
     BoxShadow(
       color: Colors.black.withValues(alpha: 0.05),
   ```
   
   Par:
   ```dart
   border: Border.all(
     color: BauleColors.gold,
     width: 1.5,
   ),
   boxShadow: [
     BoxShadow(
       color: BauleColors.gold.withOpacity(0.1),
   ```

4. **Ajouter au début de Scaffold (après backgroundColor):**
   
   ```dart
   body: Stack(
     children: [
       BaulePatternBackground(
         backgroundColor: BauleColors.creamWhite,
         primaryColor: BauleColors.gold,
         opacity: 0.08,
       ),
       // SafeArea... (contenu existant)
     ],
   ),
   ```

### Lignes clés à modifier:
- ~75-80: Scaffold backgroundColor
- ~200+: Tous les champs de texte
- ~470+: Bouton "S'inscrire"
- ~520+: Lien Login

**Commande rapide:** Recherche & Replace
- Find: `Colors.grey\[`
- Find: `Color\(0xFF22C55E\)`
- Find: `Colors.black87`


## ⏳ ÉTAPE 2: FORGOT PASSWORD PAGE (Estimé: 30min)
================================================

FICHIER: lib/features/auth/presentation/pages/forgot_password_page.dart

### Actions:
1. Copier la structure de login_page.dart
2. Remplacer les sections par celles de forgot_password
3. Appliquer BauleColors & BauleDecoration

### Template minimal:
```dart
import 'package:suan/core/theme/baule_colors.dart';
import 'package:suan/shared/widgets/baule_decoration.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BauleColors.creamWhite,
      body: Stack(
        children: [
          BaulePatternBackground(
            backgroundColor: BauleColors.creamWhite,
            primaryColor: BauleColors.gold,
            opacity: 0.08,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Back button avec bordure or
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: BauleColors.gold.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: BauleColors.deepBlack,
                      ),
                    ),
                  ),
                  // ... titre avec barre or
                  // ... contenu
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```


## ⏳ ÉTAPE 3: MODE SELECTION PAGE (Estimé: 45min)
==============================================

FICHIER: lib/features/auth/presentation/pages/mode_selection_page.dart

### Modifications principales:

1. **Ajouter Stack avec background pattern**
2. **Titre avec accent or vertical**
3. **Cercles Baoulé autour des mode buttons**
4. **Séparateur doré entre les options**
5. **Bouton "Continuer" en or**

### Exemple pour boutons:
```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(
      color: isSelected ? BauleColors.gold : BauleColors.borderColor,
      width: isSelected ? 2 : 1.5,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? BauleColors.gold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? BauleColors.gold : BauleColors.lightText,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? BauleColors.deepBlack : BauleColors.lightText,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
```


## 📋 CHECKLIST POUR CHAQUE PAGE:
================================

- [ ] Import BauleColors et BauleDecoration
- [ ] Scaffold: backgroundColor = BauleColors.creamWhite
- [ ] Ajouter Stack avec BaulePatternBackground
- [ ] Ajouter SafeArea avec contenu
- [ ] Titre: Ajouter barre or verticale
- [ ] Tous les champs: bordure or 1.5px
- [ ] Tous les boutons: backgroundColor = BauleColors.gold
- [ ] Tous les icons: color = BauleColors.gold
- [ ] Messages erreur: redOrange
- [ ] Décoration top/bottom si pertinent
- [ ] Tester sur iOS et Android
- [ ] Vérifier contraste des couleurs


## 🎯 OBJECTIF COURT TERME:
==========================

Cette semaine:
✅ Register Page - Compléter les modifications de style
✅ Forgot Password Page - Appliquer le design complet
✅ Mode Selection - Ajouter les cercles & accents

Résultat: Toutes les pages d'authentification auront le design Baoulé cohérent!


## 💾 FICHIERS À AVOIR À PORTÉE:

1. **DESIGN_SYSTEM_BAULE.md** - Pour la palette rapide
2. **GUIDE_INTEGRATION_BAULE.md** - Pour copier/coller des composants
3. **login_page.dart** - Pour référencer la structure
4. **baule_colors.dart** - Pour voir toutes les constantes

## 🚀 COMMANDES UTILES:

```bash
# Pour chercher les couleurs à remplacer:
grep -r "0xFF22C55E" lib/features/auth/
grep -r "Colors.grey\[" lib/features/auth/
grep -r "Colors.black87" lib/features/auth/

# Pour tester l'app:
flutter pub get
flutter run

# Pour build:
flutter build apk
flutter build ios
```

---

**Prêt à continuer? Commence par Register Page!** 🚀
