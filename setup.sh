#!/bin/bash
# Script d'installation et de configuration

echo "🚀 Installation de Suan..."

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Vérifier Flutter
echo -e "${YELLOW}[1/5]${NC} Vérification de Flutter..."
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter n'est pas installé${NC}"
    echo "Veuillez installer Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi
echo -e "${GREEN}✓ Flutter trouvé${NC}"

# 2. Vérifier Dart
echo -e "${YELLOW}[2/5]${NC} Vérification de Dart..."
if ! command -v dart &> /dev/null; then
    echo -e "${RED}✗ Dart n'est pas installé${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Dart trouvé${NC}"

# 3. Mettre à jour Flutter
echo -e "${YELLOW}[3/5]${NC} Mise à jour de Flutter..."
flutter upgrade

# 4. Installer les dépendances
echo -e "${YELLOW}[4/5]${NC} Installation des dépendances..."
flutter pub get

# 5. Générer les fichiers build_runner
echo -e "${YELLOW}[5/5]${NC} Génération des fichiers build_runner..."
flutter pub run build_runner build

echo -e "${GREEN}✓ Installation terminée!${NC}"
echo ""
echo "Pour lancer l'application:"
echo "  flutter run"
echo ""
echo "Pour plus d'informations:"
echo "  flutter doctor -v"
