# Checklist de Déploiement - Suan

## ✅ Avant le Déploiement

### Code Quality
- [ ] Tous les lints passent (`flutter analyze`)
- [ ] Tous les tests passent (`flutter test`)
- [ ] Aucun warning dans la console
- [ ] Code formaté (`dart format lib/`)
- [ ] Pas de code mort ou de commentaires inutiles

### Fonctionnalités
- [ ] Authentification fonctionne correctement
- [ ] Mode d'apprentissage sélectionnable
- [ ] Leçons chargent et s'affichent
- [ ] Quiz fonctionnent et enregistrent les résultats
- [ ] Paramètres sauvegardés correctement
- [ ] Navigation fluide entre les écrans
- [ ] Messages d'erreur clairs
- [ ] Pas de crash identifiés

### Performance
- [ ] App démarre rapidement (< 2s)
- [ ] Pas de lag visible au scroll
- [ ] Pas de memory leak
- [ ] Images optimisées
- [ ] Pas de requêtes réseau inutiles

### Sécurité
- [ ] Mots de passe non stockés en clair
- [ ] Tokens chiffrés localement
- [ ] Validation des entrées utilisateur
- [ ] Pas de données sensibles en logs
- [ ] HTTPS pour les requêtes réseau

### Ui/UX
- [ ] Design cohérent sur tous les écrans
- [ ] Responsive sur mobile et tablette
- [ ] Boutons de taille adéquate
- [ ] Textes lisibles (contraste suffisant)
- [ ] Icônes clairs et intuitifs
- [ ] Pas de texte coupé

### Localisation
- [ ] Textes traduits en français et baoulé
- [ ] Pas de hardcoded strings
- [ ] Dates formatées correctement
- [ ] Symboles de monnaie appropriés

### Documentation
- [ ] README à jour
- [ ] Code commenté pour les parties complexes
- [ ] DEVELOPER_GUIDE complet
- [ ] CHANGELOG à jour
- [ ] License présente

## ✅ Android Deployment

### Configuration
- [ ] `versionCode` incrémenté
- [ ] `versionName` mis à jour (semver)
- [ ] App name correct
- [ ] Package name correct
- [ ] Icons générées correctement
- [ ] Splash screen présent

### Tests
- [ ] Testé sur API 21+ (Android 5.0)
- [ ] Testé sur dispositifs variés
- [ ] Testé en portrait et landscape
- [ ] Permissions requises déclarées
- [ ] Pas d'erreurs lors du démarrage

### Build
```bash
flutter clean
flutter build apk --release
# ou
flutter build appbundle --release
```

### Play Store
- [ ] Screenshots prêts (en français)
- [ ] Description mise à jour
- [ ] Privacy policy définie
- [ ] Rating content approprié
- [ ] Pricing et distribution configurés

## ✅ iOS Deployment

### Configuration
- [ ] Build number incrémenté
- [ ] Version number mis à jour
- [ ] Bundle identifier correct
- [ ] Team ID configuré
- [ ] Certificates valides

### Tests
- [ ] Testé sur iPhone 12/13/14
- [ ] Testé sur iOS 14+
- [ ] Landscape et portrait
- [ ] Pas de warnings en build

### Build
```bash
flutter clean
flutter build ios --release
# Archiver dans Xcode
```

### App Store
- [ ] Screenshots prêts
- [ ] Description localisée
- [ ] Keywords optimisés
- [ ] Version release notes
- [ ] Privacy manifest

## ✅ Post-Deployment

### Monitoring
- [ ] Crash reporting activé
- [ ] Analytics en place
- [ ] Performance monitoring
- [ ] User feedback mechanism

### Support
- [ ] Support email configuré
- [ ] FAQ prêt
- [ ] Community chat/discord
- [ ] Issue tracking en place

### Marketing
- [ ] Annonce sur réseaux sociaux
- [ ] Email aux early users
- [ ] Press release (si applicable)
- [ ] Listing sur app discovery

## 🚨 Blockers Critiques

Résoudre **avant** le déploiement:
- [ ] Pas de crash lors du login
- [ ] Pas de perte de données
- [ ] Pas d'erreur réseau non gérée
- [ ] Pas de permission manquante
- [ ] Pas de donnée sensible exposée

## 📋 Rollback Plan

En cas de problème critique:
1. Retirer du store ou marquer comme deprecated
2. Pinner la version précédente
3. Enquête sur la cause
4. Fix et redéploiement
5. Post-mortem

---

**Version**: 1.0.0  
**Date Check**: [Complétez la date]  
**Responsable**: [Nom]  
**Approuvé par**: [Nom]
