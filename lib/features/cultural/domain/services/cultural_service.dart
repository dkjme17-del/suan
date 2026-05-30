import 'dart:async';
import 'dart:math';

class CulturalService {
  static final CulturalService _instance = CulturalService._internal();
  factory CulturalService() => _instance;
  CulturalService._internal();

  final List<CulturalStory> _stories = [];
  final List<Proverb> _proverbs = [];
  final List<Elder> _elders = [];

  // Initialiser avec des données culturelles baoulé
  void initialize() {
    _loadCulturalContent();
  }

  // Obtenir les contes traditionnels
  List<CulturalStory> getStories({String? category, int limit = 10}) {
    var filteredStories = _stories;
    
    if (category != null) {
      filteredStories = _stories
          .where((story) => story.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
    
    filteredStories.sort((a, b) => b.popularity.compareTo(a.popularity));
    return filteredStories.take(limit).toList();
  }

  // Obtenir un conte spécifique
  CulturalStory? getStoryById(String storyId) {
    try {
      return _stories.firstWhere((story) => story.id == storyId);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les proverbes
  List<Proverb> getProverbs({int limit = 20}) {
    final shuffled = List<Proverb>.from(_proverbs)..shuffle(Random());
    return shuffled.take(limit).toList();
  }

  // Obtenir un proverbe aléatoire
  Proverb getRandomProverb() {
    final random = Random();
    return _proverbs[random.nextInt(_proverbs.length)];
  }

  // Obtenir les anciens/contributeurs
  List<Elder> getElders({int limit = 10}) {
    return _elders.take(limit).toList();
  }

  // Obtenir un ancien spécifique
  Elder? getElderById(String elderId) {
    try {
      return _elders.firstWhere((elder) => elder.id == elderId);
    } catch (e) {
      return null;
    }
  }

  // Rechercher du contenu culturel
  List<CulturalContent> searchContent(String query) {
    final results = <CulturalContent>[];
    final normalizedQuery = query.toLowerCase();

    // Rechercher dans les contes
    for (final story in _stories) {
      if (story.title.toLowerCase().contains(normalizedQuery) ||
          story.description.toLowerCase().contains(normalizedQuery) ||
          story.baouleText.toLowerCase().contains(normalizedQuery)) {
        results.add(story);
      }
    }

    // Rechercher dans les proverbes
    for (final proverb in _proverbs) {
      if (proverb.baouleProverb.toLowerCase().contains(normalizedQuery) ||
          proverb.frenchTranslation.toLowerCase().contains(normalizedQuery) ||
          proverb.explanation.toLowerCase().contains(normalizedQuery)) {
        results.add(proverb);
      }
    }

    return results;
  }

  // Marquer un contenu comme favori
  Future<bool> toggleFavorite(String contentId, String contentType) async {
    try {
      // Logique pour gérer les favoris (à implémenter avec SharedPreferences)
      return true;
    } catch (e) {
      print('Erreur gestion favoris: $e');
      return false;
    }
  }

  // Noter un contenu
  Future<bool> rateContent(String contentId, String contentType, double rating) async {
    try {
      // Mettre à jour la note du contenu
      if (contentType == 'story') {
        final story = _stories.firstWhere((s) => s.id == contentId);
        story.addRating(rating);
      } else if (contentType == 'proverb') {
        final proverb = _proverbs.firstWhere((p) => p.id == contentId);
        proverb.addRating(rating);
      }
      return true;
    } catch (e) {
      print('Erreur notation: $e');
      return false;
    }
  }

  // Charger le contenu culturel
  void _loadCulturalContent() {
    // Contes traditionnels baoulé
    _stories.addAll([
      CulturalStory(
        id: 'story_1',
        title: 'L\'arbre et l\'enfant',
        description: 'Un conte sur la sagesse et la patience',
        category: 'Sagesse',
        baouleText: 'Anian nian klô, anian b\'a...',
        frenchTranslation: 'Il était une fois, dans un village...',
        audioPath: 'assets/audio/stories/arbre_enfant.mp3',
        duration: Duration(minutes: 5),
        elderId: 'elder_1',
        imageUrl: 'assets/images/stories/arbre_enfant.jpg',
        popularity: 95,
      ),
      CulturalStory(
        id: 'story_2',
        title: 'Le liard et la tortue',
        description: 'L\'importance de la persévérance',
        category: 'Morale',
        baouleText: 'Kplê ma wôlô, kplê...',
        frenchTranslation: 'Le liard était très fier...',
        audioPath: 'assets/audio/stories/liard_tortue.mp3',
        duration: Duration(minutes: 7),
        elderId: 'elder_2',
        imageUrl: 'assets/images/stories/liard_tortue.jpg',
        popularity: 88,
      ),
      CulturalStory(
        id: 'story_3',
        title: 'Les trois frères',
        description: 'La valeur de l\'unité familiale',
        category: 'Famille',
        baouleText: 'N\'gban sôrô, n\'gban...',
        frenchTranslation: 'Il y avait trois frères...',
        audioPath: 'assets/audio/stories/trois_freres.mp3',
        duration: Duration(minutes: 6),
        elderId: 'elder_1',
        imageUrl: 'assets/images/stories/trois_freres.jpg',
        popularity: 92,
      ),
    ]);

    // Proverbes baoulé
    _proverbs.addAll([
      Proverb(
        id: 'proverb_1',
        baouleProverb: 'Klô djan klô, ka djè',
        frenchTranslation: 'Lentement, on va loin',
        explanation: 'Ce proverbe enseigne la patience et la persévérance',
        audioPath: 'assets/audio/proverbs/proverb_1.mp3',
        category: 'Patience',
      ),
      Proverb(
        id: 'proverb_2',
        baouleProverb: 'N\'gban ka, n\'gban bô',
        frenchTranslation: 'L\'union fait la force',
        explanation: 'L\'importance de la solidarité dans la communauté',
        audioPath: 'assets/audio/proverbs/proverb_2.mp3',
        category: 'Solidarité',
      ),
      Proverb(
        id: 'proverb_3',
        baouleProverb: 'Sôrô ma, wôrô ma',
        frenchTranslation: 'La main qui donne est toujours au-dessus de celle qui reçoit',
        explanation: 'La générosité et l\'importance de donner',
        audioPath: 'assets/audio/proverbs/proverb_3.mp3',
        category: 'Générosité',
      ),
      Proverb(
        id: 'proverb_4',
        baouleProverb: 'Anian dô, anian bê',
        frenchTranslation: 'Toute vérité n\'est pas bonne à dire',
        explanation: 'La sagesse dans la communication',
        audioPath: 'assets/audio/proverbs/proverb_4.mp3',
        category: 'Sagesse',
      ),
      Proverb(
        id: 'proverb_5',
        baouleProverb: 'Fêlê wôlô, fêlê bê',
        frenchTranslation: 'La connaissance est un trésor',
        explanation: 'La valeur de l\'éducation et du savoir',
        audioPath: 'assets/audio/proverbs/proverb_5.mp3',
        category: 'Éducation',
      ),
    ]);

    // Anciens et contributeurs culturels
    _elders.addAll([
      Elder(
        id: 'elder_1',
        name: 'N\'goran Kouadio',
        age: 78,
        village: 'Yamoussoukro',
        specialty: 'Contes traditionnels',
        bio: 'Gardien des traditions baoulé depuis plus de 40 ans',
        photoUrl: 'assets/images/elders/ngoran_kouadio.jpg',
        storiesCount: 25,
        rating: 4.8,
      ),
      Elder(
        id: 'elder_2',
        name: 'Adjoua Aya',
        age: 65,
        village: 'Bouaké',
        specialty: 'Proverbes et sagesse',
        bio: 'Connue pour sa connaissance des proverbes et leur signification',
        photoUrl: 'assets/images/elders/adjoua_aya.jpg',
        storiesCount: 18,
        rating: 4.9,
      ),
      Elder(
        id: 'elder_3',
        name: 'Kouamé Yéo',
        age: 82,
        village: 'Dimbokro',
        specialty: 'Histoires historiques',
        bio: 'Historien de la culture baoulé et expert en généalogie',
        photoUrl: 'assets/images/elders/kouame_yeo.jpg',
        storiesCount: 32,
        rating: 4.7,
      ),
    ]);
  }
}

// Classes de modèles
abstract class CulturalContent {
  final String id;
  final String title;
  final String description;
  final String audioPath;

  CulturalContent({
    required this.id,
    required this.title,
    required this.description,
    required this.audioPath,
  });
}

class CulturalStory extends CulturalContent {
  final String category;
  final String baouleText;
  final String frenchTranslation;
  final Duration duration;
  final String elderId;
  final String imageUrl;
  int popularity;
  double averageRating;
  int ratingsCount;

  CulturalStory({
    required String id,
    required String title,
    required String description,
    required this.category,
    required this.baouleText,
    required this.frenchTranslation,
    required String audioPath,
    required this.duration,
    required this.elderId,
    required this.imageUrl,
    required this.popularity,
    this.averageRating = 0.0,
    this.ratingsCount = 0,
  }) : super(id: id, title: title, description: description, audioPath: audioPath);

  void addRating(double rating) {
    averageRating = ((averageRating * ratingsCount) + rating) / (ratingsCount + 1);
    ratingsCount++;
  }
}

class Proverb extends CulturalContent {
  final String baouleProverb;
  final String frenchTranslation;
  final String explanation;
  final String category;
  double averageRating;
  int ratingsCount;

  Proverb({
    required String id,
    required this.baouleProverb,
    required this.frenchTranslation,
    required this.explanation,
    required String audioPath,
    required this.category,
    this.averageRating = 0.0,
    this.ratingsCount = 0,
  }) : super(
          id: id,
          title: baouleProverb,
          description: explanation,
          audioPath: audioPath,
        );

  void addRating(double rating) {
    averageRating = ((averageRating * ratingsCount) + rating) / (ratingsCount + 1);
    ratingsCount++;
  }
}

class Elder {
  final String id;
  final String name;
  final int age;
  final String village;
  final String specialty;
  final String bio;
  final String photoUrl;
  final int storiesCount;
  double rating;

  Elder({
    required this.id,
    required this.name,
    required this.age,
    required this.village,
    required this.specialty,
    required this.bio,
    required this.photoUrl,
    required this.storiesCount,
    required this.rating,
  });
}
