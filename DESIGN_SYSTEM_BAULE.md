// STYLE GUIDE - DESIGN SYSTÈME CULTUREL BAOULÉ
// =====================================================

// 📚 PALETTE DE COULEURS BAOULÉ
// =============================
// 🟡 OR (Prestige & Élégance)
  - Principal: #D4AF37 (BauleColors.gold)
  - Or Foncé: #C19A3B (BauleColors.darkGold)
  - Or Clair: #E8D5B7 (BauleColors.lightGold)
  - Accent Or: #FFD700 (BauleColors.accentGold)

// ⚫ NOIR (Force & Tradition)
  - Noir Profond: #1A1A1A (BauleColors.deepBlack)

// ⚪ BLANC CASSÉ (Sérénité)
  - Crème: #FAF7F2 (BauleColors.creamWhite)

// 🔴 ROUGE-ORANGE (Énergie)
  - Rouge-Orange: #D84315 (BauleColors.redOrange)

// 🌑 NEUTRES
  - Texte Foncé: #2C2C2C
  - Texte Clair: #757575
  - Bordure: #E0E0E0

// 🎨 ÉLÉMENTS VISUELS BAOULÉ
// ============================

1. **Motifs Géométriques**
   - Diamants répétés (symbole traditionnel)
   - Triangles aux coins (harmonie)
   - Cercles concentriques (unité & cycle)
   - Lignes dorées (connexion spirituelle)

2. **Décoration Baoulé**
   - Bordure supérieure avec cercles dorés
   - Bordure inférieure avec gradient or
   - Cercles géométriques en haut à droite
   - Ligne verticale or avant le titre

3. **Typographie**
   - Titres: Gras, couleur noir profond (#1A1A1A)
   - Corps: Régulier, couleur grise (#757575)
   - Accents: Or (#D4AF37) pour les liens/actions

// 📱 COMPOSANTS BAOULÉ
// ====================

✅ **Champs de Texte**
   - Bordure: Or 1.5px
   - Ombre: Or transparent 0.1
   - Icône Préfixe: Or
   - Focus Bordure: Or 2px
   - Background: Blanc

✅ **Boutons Primaires**
   - Couleur: Or (#D4AF37)
   - Texte: Noir Profond
   - Forme: Arrondie 12px
   - Ombre: Or transparent 0.4
   - Élévation: 4

✅ **Checkbox**
   - Coché: Or (#D4AF37)
   - Non coché: Blanc + bordure grise
   - Icône: Noir Profond

✅ **Boutons Sociaux**
   - Bordure: Or transparent 0.3
   - Ombre: Or transparent 0.08
   - Forme: Arrondie 12px

✅ **Messages d'Erreur**
   - Background: Rouge transparent 0.1
   - Bordure: Rouge transparent 0.3
   - Texte: Rouge-Orange

// 🌟 GUIDANCE PRATIQUE
// ====================

Pour maintenir la cohérence:

1. Toujours utiliser BauleColors pour les couleurs
2. Utiliser BauleDecorationBorder pour les séparations
3. Utiliser BaulePatternBackground pour le fond
4. Utiliser BauleCirclePattern pour les accents
5. Maintenir l'espacement uniforme avec SizedBox

// 🎯 MOTIFS TRADITIONNELS BAOULÉ REPRÉSENTÉS
// ============================================

▪️ Masques Baoulé → Formes géométriques épurées
▪️ Textiles → Motifs répétitifs (diamants, triangles)
▪️ Artisanat → Précision des lignes
▪️ Harmonie Spirituelle → Cercles concentriques
▪️ Connexion → Lignes continues dorées

// 📝 UTILISATION FUTURE
// =====================

Ces éléments peuvent être étendus à:
- Page Register
- Page Forgot Password
- Page Mode Selection
- Tous les écrans de navigation
- Dialogues et modales

Import les classes:
```dart
import 'package:suan/core/theme/baule_colors.dart';
import 'package:suan/shared/widgets/baule_decoration.dart';
```
