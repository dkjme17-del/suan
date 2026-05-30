import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseInitializationService {
  static final FirebaseInitializationService _instance =
      FirebaseInitializationService._internal();
  factory FirebaseInitializationService() => _instance;
  FirebaseInitializationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _initKey = 'firebase_initialized';

  /// Initialise les données de base dans Firestore (une seule fois)
  Future<void> initializeFirebaseData() async {
    try {
      // Vérifier si les données ont déjà été initialisées
      final settingsDoc = await _firestore
          .collection('_settings')
          .doc('app')
          .get();
      final data = settingsDoc.data();
      if (settingsDoc.exists && data != null && data[_initKey] == true) {
        print('✅ Firestore déjà initialisé');
        return;
      }

      print('🚀 Initialisation de Firestore...');

      // Initialiser les leçons
      await _initializeLessons();
      print('✅ Leçons créées');

      // Initialiser les catégories de quiz
      await _initializeQuizCategories();
      print('✅ Catégories de quiz créées');

      // Initialiser les questions de quiz
      await _initializeQuizQuestions();
      print('✅ Questions de quiz créées');

      // Initialiser les défis quotidiens
      await _initializeDailyChallenges();
      print('✅ Défis quotidiens créés');

      // Note: Les posts communautaires sont créés seulement par les vrais utilisateurs lors de leur inscription

      // Marquer comme initialisé
      await _firestore.collection('_settings').doc('app').set({
        _initKey: true,
        'initializedAt': FieldValue.serverTimestamp(),
      });

      print('✨ Initialisation Firestore terminée avec succès!');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation: $e');
      // Ne pas relancer l'erreur pour ne pas bloquer l'app
    }
  }

  Future<void> _initializeLessons() async {
    final lessons = <Map<String, dynamic>>[
      {
        'id': 'lesson_1',
        'title': 'Bonjour le Baoulé',
        'description': 'Apprenez les salutations basiques',
        'level': 'beginner',
        'content': 'Gbéhéfié (Bonjour), Akoa (Au revoir), Médja (Merci)',
        'vocabulary': ['Gbéhéfié', 'Akoa', 'Médja', 'Afia', 'Ahôh'],
        'durationMinutes': 5,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'lesson_2',
        'title': 'Les nombres',
        'description': 'Compter de 1 à 10 en baoulé',
        'level': 'beginner',
        'content': 'Yue (1), Ue (2), Yie (3), Ine (4), Onan (5)...',
        'vocabulary': [
          'Yue',
          'Ue',
          'Yie',
          'Ine',
          'Onan',
          'Nsia',
          'Nson',
          'Nwui',
          'N\'wie',
          'Oyo',
        ],
        'durationMinutes': 5,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'lesson_3',
        'title': 'La famille',
        'description': 'Les mots pour décrire la famille',
        'level': 'beginner',
        'content':
            'Die (Père), Na (Mère), Bia (Enfant), Nkosuen (Frère), Onukuo (Sœur)',
        'vocabulary': [
          'Die',
          'Na',
          'Bia',
          'Nkosuen',
          'Onukuo',
          'Okra',
          'Agnin',
        ],
        'durationMinutes': 5,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'lesson_4',
        'title': 'Conversation quotidienne',
        'description': 'Des conversations pratiques',
        'level': 'intermediate',
        'content':
            'Efe kou anwe? (Comment allez-vous?), Gna nyé fwe (Ça va bien)',
        'vocabulary': ['Efe', 'Kou', 'Anwe', 'Gna', 'Nyé', 'Fwe'],
        'durationMinutes': 10,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var lesson in lessons) {
      await _firestore
          .collection('lessons')
          .doc(lesson['id'] as String)
          .set(lesson);
    }
  }

  Future<void> _initializeQuizCategories() async {
    final categories = <Map<String, dynamic>>[
      {
        'id': 'vocabulary',
        'name': 'Vocabulaire',
        'description': 'Testez votre vocabulaire baoulé',
        'icon': 'book',
        'color': 'blue',
        'questionCount': 15,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'grammar',
        'name': 'Grammaire',
        'description': 'Exercices de grammaire',
        'icon': 'pencil',
        'color': 'green',
        'questionCount': 12,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'conversation',
        'name': 'Conversation',
        'description': 'Scénarios de conversation',
        'icon': 'comments',
        'color': 'orange',
        'questionCount': 8,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'culture',
        'name': 'Culture',
        'description': 'Culture baoulé',
        'icon': 'landmark',
        'color': 'purple',
        'questionCount': 10,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var category in categories) {
      await _firestore
          .collection('quiz_categories')
          .doc(category['id'] as String)
          .set(category);
    }
  }

  Future<void> _initializeQuizQuestions() async {
    final questions = <Map<String, dynamic>>[
      {
        'id': 'q1',
        'category': 'vocabulary',
        'question': 'Quel est le Baoulé pour "Bonjour"?',
        'options': ['Gbéhéfié', 'Médja', 'Akoa', 'Ahôh'],
        'correctAnswer': 'Gbéhéfié',
        'explanation': 'Gbéhéfié est la salutation standard baoulé',
        'points': 10,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'q2',
        'category': 'vocabulary',
        'question': 'Comment dire "Merci" en Baoulé?',
        'options': ['Médja', 'Akoa', 'Gbéhéné', 'Ahôh'],
        'correctAnswer': 'Médja',
        'explanation': 'Médja signifie merci',
        'points': 10,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'q3',
        'category': 'vocabulary',
        'question': 'Quel mot signifie "Au revoir"?',
        'options': ['Gbéhéfié', 'Akoa', 'Médja', 'Afia'],
        'correctAnswer': 'Akoa',
        'explanation': 'Akoa est la façon de dire au revoir',
        'points': 10,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'q4',
        'category': 'vocabulary',
        'question': 'Complétez: "Gbéhéfié, ___?"',
        'options': ['Bia?', 'Okoa?', 'Afia?', 'Nian?'],
        'correctAnswer': 'Bia?',
        'explanation': 'La formule de salutation complète est "Gbéhéfié, Bia?"',
        'points': 10,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'q5',
        'category': 'vocabulary',
        'question': 'Comment dit-on "Oui" en Baoulé?',
        'options': ['Awe', 'Yooo', 'Non', 'Ainsi'],
        'correctAnswer': 'Awe',
        'explanation': 'Awe signifie oui en baoulé',
        'points': 10,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var question in questions) {
      await _firestore
          .collection('quiz_questions')
          .doc(question['id'] as String)
          .set(question);
    }
  }

  Future<void> _initializeDailyChallenges() async {
    final challenges = <Map<String, dynamic>>[
      {
        'id': 'challenge_1',
        'title': 'Maître du vocabulaire',
        'description': 'Complétez 10 exercices de vocabulaire',
        'points': 50,
        'icon': 'trophy',
        'progress': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'challenge_2',
        'title': 'Conversation parfaite',
        'description': 'Atteignez 90% de précision',
        'points': 75,
        'icon': 'comments',
        'progress': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'challenge_3',
        'title': 'Série de 7 jours',
        'description': 'Apprenez sans interruption',
        'points': 100,
        'icon': 'fire',
        'progress': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'challenge_4',
        'title': 'Quiz Master',
        'description': 'Répondez correctement à tous les quiz',
        'points': 60,
        'icon': 'star',
        'progress': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var challenge in challenges) {
      await _firestore
          .collection('daily_challenges')
          .doc(challenge['id'] as String)
          .set(challenge);
    }
  }

  // Community posts are created by real users upon registration - no mock posts

  /// Récupère l'état d'initialisation
  Future<bool> isInitialized() async {
    try {
      final settingsDoc = await _firestore
          .collection('_settings')
          .doc('app')
          .get();
      return settingsDoc.exists && settingsDoc.get(_initKey) == true;
    } catch (e) {
      return false;
    }
  }

  /// Réinitialise les données (utile pour les tests)
  Future<void> resetData() async {
    try {
      // Supprimer toutes les collections
      await _deleteCollection('lessons');
      await _deleteCollection('quiz_categories');
      await _deleteCollection('quiz_questions');
      await _deleteCollection('daily_challenges');
      await _deleteCollection('community');
      await _firestore.collection('_settings').doc('app').delete();

      print('✅ Données réinitialisées');

      // Réinitialiser les données
      await initializeFirebaseData();
    } catch (e) {
      print('❌ Erreur lors de la réinitialisation: $e');
    }
  }

  Future<void> _deleteCollection(String collectionPath) async {
    try {
      final batchSize = 100;
      final query = _firestore.collection(collectionPath);

      final snapshot = await query.limit(batchSize).get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Récursivement supprimer les documents restants
      return _deleteCollection(collectionPath);
    } catch (e) {
      print('Erreur lors de la suppression de la collection: $e');
    }
  }

  /// Supprime les posts simulés de la communauté (posts avec authorId: 'system')
  /// N'execute qu'une seule fois
  Future<void> cleanupMockCommunityPosts() async {
    try {
      // Vérifier si nettoyage déjà effectué
      final settingsDoc = await _firestore
          .collection('_settings')
          .doc('app')
          .get();
      if (settingsDoc.exists &&
          settingsDoc.get('mock_posts_cleanup_done') == true) {
        print('✅ Posts simulés déjà nettoyés');
        return;
      }

      final snapshot = await _firestore
          .collection('community')
          .where('authorId', isEqualTo: 'system')
          .get();

      if (snapshot.docs.isEmpty) {
        // Marquer comme nettoyé même s'il n'y a rien
        await _firestore.collection('_settings').doc('app').set({
          'mock_posts_cleanup_done': true,
          'mock_posts_cleanup_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('✅ Aucun post simulé trouvé');
        return;
      }

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Marquer nettoyage comme effectué
      await _firestore.collection('_settings').doc('app').set({
        'mock_posts_cleanup_done': true,
        'mock_posts_cleanup_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Posts simulés supprimés');
    } catch (e) {
      print('⚠️ Erreur nettoyage posts simulés: $e');
    }
  }

  /// Initialise automatiquement le champ firebase_initialized dans Firestore si absent
  static Future<void> ensureFirebaseInitializedFlag() async {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('_settings').doc('app');
    final doc = await docRef.get();
    if (!doc.exists ||
        doc.data() == null ||
        doc.data()!['firebase_initialized'] != true) {
      await docRef.set({
        'firebase_initialized': true,
        'initializedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print(
        '✅ Champ firebase_initialized ajouté automatiquement dans Firestore',
      );
    } else {
      print('✅ Champ firebase_initialized déjà présent dans Firestore');
    }
  }
}
