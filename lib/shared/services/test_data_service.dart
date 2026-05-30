import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/logger.dart';
import 'firebase_initialization_service.dart';

class TestDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTestData() async {
    // S'assure que le champ firebase_initialized existe avant d'ajouter les données
    await FirebaseInitializationService.ensureFirebaseInitializedFlag();
    Logger.info('🚀 Ajout de données test SUAN...');

    try {
      await _addLessons();
      await _addQuizQuestions();
      await _addChallenges();
      await _addTestUsers();
      await _addNews();
      Logger.info('✅ Toutes les données test ont été ajoutées avec succès!');
      Logger.info('📱 Rafraîchissez votre app pour voir les changements');
    } catch (e) {
      Logger.error('❌ Erreur lors de l\'ajout des données', e);
      rethrow;
    }
  }

  Future<void> _addLessons() async {
    Logger.info('📚 Ajout des leçons...');

    final lessons = [
      {
        'id': 'lesson_3',
        'title': 'La famille',
        'description': 'Apprenez les mots de la famille',
        'level': 'beginner',
        'content':
            'Papa (père), Mama (mère), Wô (enfant), Niangban (frère), Niangba (sœur)',
        'vocabulary': ['Papa', 'Mama', 'Wô', 'Niangban', 'Niangba', 'Gô', 'Tô'],
        'durationMinutes': 7,
      },
      {
        'id': 'lesson_4',      
        'title': 'Les couleurs',
        'description': 'Découvrez les couleurs en baoulé',
        'level': 'beginner',
        'content':
            'Fîn (blanc), Djo (noir), Kô (rouge), Kôkô (bleu), Wê (vert)',
        'vocabulary': ['Fîn', 'Djo', 'Kô', 'Kôkô', 'Wê', 'Saki', 'Kôkôdjo'],
        'durationMinutes': 6,
      },
      {
        'id': 'lesson_5',
        'title': 'Les animaux',
        'description': 'Les animaux de la savane',
        'level': 'intermediate',
        'content':
            'Kpan (éléphant), Wôkô (lion), Kôkô (singe), Gbê (serpent), Kô (oiseau)',
        'vocabulary': ['Kpan', 'Wôkô', 'Kôkô', 'Gbê', 'Kô', 'Gbêkô', 'Wôgbê'],
        'durationMinutes': 8,
      },
      {
        'id': 'lesson_6',
        'title': 'La nourriture',
        'description': 'Les aliments traditionnels',
        'level': 'intermediate',
        'content':
            'Gbô (riz), Kô (igname), Gbê (viande), Kôkô (huile), Wê (eau)',
        'vocabulary': ['Gbô', 'Kô', 'Gbê', 'Kôkô', 'Wê', 'Gbêkô', 'Kôgbê'],
        'durationMinutes': 10,
      },
      {
        'id': 'lesson_7',
        'title': 'Les verbes d\'action',
        'description': 'Les actions courantes',
        'level': 'intermediate',
        'content':
            'Kô (aller), Gbê (venir), Kôkô (manger), Wê (boire), Gbô (dormir)',
        'vocabulary': ['Kô', 'Gbê', 'Kôkô', 'Wê', 'Gbô', 'Kôgbê', 'Wêkô'],
        'durationMinutes': 12,
      },
      {
        'id': 'lesson_8',
        'title': 'Expressions idiomatiques',
        'description': 'Expressions courantes avancées',
        'level': 'advanced',
        'content':
            'Kô gbê wê (Aller et venir), Gbô kôkô (Dormir et manger), Wê gbê kô (Boire et venir)',
        'vocabulary': [
          'Kô gbê wê',
          'Gbô kôkô',
          'Wê gbê kô',
          'Kôkô gbê',
          'Gbê wê kô',
        ],
        'durationMinutes': 15,
      },
    ];

    for (final lesson in lessons) {
      await _firestore.collection('lessons').doc(lesson['id'] as String).set({
        ...lesson,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    Logger.info('✅ ${lessons.length} leçons ajoutées');
  }

  Future<void> _addQuizQuestions() async {
    Logger.info('🧠 Ajout des questions de quiz...');

    final questions = [
      {
        'id': 'q4',
        'category': 'vocab',
        'question': 'Comment compter "1" en Baoulé?',
        'options': ['Yue', 'Ue', 'Yie', 'Ine'],
        'correctAnswer': 'Yue',
        'explanation': 'Yue signifie 1 en baoulé',
        'points': 10,
      },
      {
        'id': 'q5',
        'category': 'vocab',
        'question': 'Quel mot désigne le père?',
        'options': ['Mama', 'Papa', 'Wô', 'Niangban'],
        'correctAnswer': 'Papa',
        'explanation': 'Papa signifie père en baoulé',
        'points': 10,
      },
      {
        'id': 'q6',
        'category': 'vocab',
        'question': 'Quelle couleur est "Kô"?',
        'options': ['Blanc', 'Rouge', 'Bleu', 'Vert'],
        'correctAnswer': 'Rouge',
        'explanation': 'Kô signifie rouge en baoulé',
        'points': 10,
      },
      {
        'id': 'q7',
        'category': 'vocab',
        'question': 'Comment dire "éléphant"?',
        'options': ['Wôkô', 'Kpan', 'Kôkô', 'Gbê'],
        'correctAnswer': 'Kpan',
        'explanation': 'Kpan signifie éléphant en baoulé',
        'points': 15,
      },
      {
        'id': 'q8',
        'category': 'vocab',
        'question': 'Quel aliment est "Gbô"?',
        'options': ['Viande', 'Riz', 'Huile', 'Eau'],
        'correctAnswer': 'Riz',
        'explanation': 'Gbô signifie riz en baoulé',
        'points': 15,
      },
      {
        'id': 'q9',
        'category': 'grammar',
        'question': 'Quelle est la structure correcte pour "Je vais"?',
        'options': ['M\' kô', 'Kô m\'', 'M kô', 'Kô m'],
        'correctAnswer': 'M\' kô',
        'explanation': 'En baoulé, "Je vais" se dit "M\' kô"',
        'points': 20,
      },
      {
        'id': 'q10',
        'category': 'grammar',
        'question': 'Comment former le pluriel de "wô" (enfant)?',
        'options': ['Wôô', 'Wôwô', 'Wôlê', 'Wôba'],
        'correctAnswer': 'Wôô',
        'explanation': 'Le pluriel de wô (enfant) est wôô',
        'points': 20,
      },
    ];

    for (final question in questions) {
      await _firestore
          .collection('quiz_questions')
          .doc(question['id'] as String)
          .set(question);
    }

    Logger.info('✅ ${questions.length} questions de quiz ajoutées');
  }

  Future<void> _addChallenges() async {
    Logger.info('🏆 Ajout des défis...');

    final challenges = [
      {
        'id': 'challenge_3',
        'title': 'Apprenti du jour',
        'description': 'Complétez 3 leçons aujourd\'hui',
        'points': 30,
        'icon': 'book',
        'progress': 0.0,
      },
      {
        'id': 'challenge_4',
        'title': 'Maître des nombres',
        'description': 'Apprenez à compter jusqu\'à 20',
        'points': 40,
        'icon': 'calculator',
        'progress': 0.0,
      },
      {
        'id': 'challenge_5',
        'title': 'Famille unie',
        'description': 'Apprenez tous les mots de la famille',
        'points': 35,
        'icon': 'users',
        'progress': 0.0,
      },
      {
        'id': 'challenge_6',
        'title': 'Arc-en-ciel',
        'description': 'Maîtrisez toutes les couleurs',
        'points': 45,
        'icon': 'palette',
        'progress': 0.0,
      },
      {
        'id': 'challenge_7',
        'title': 'Safari virtuel',
        'description': 'Découvrez 5 animaux différents',
        'points': 50,
        'icon': 'paw',
        'progress': 0.0,
      },
      {
        'id': 'challenge_8',
        'title': 'Gourmet baoulé',
        'description': 'Apprenez 7 mots liés à la nourriture',
        'points': 55,
        'icon': 'utensils',
        'progress': 0.0,
      },
    ];

    for (final challenge in challenges) {
      await _firestore
          .collection('daily_challenges')
          .doc(challenge['id'] as String)
          .set({...challenge, 'createdAt': FieldValue.serverTimestamp()});
    }

    Logger.info('✅ ${challenges.length} défis ajoutés');
  }

  Future<void> _addTestUsers() async {
    Logger.info('👥 Ajout des utilisateurs de test...');

    final users = [
      {
        'id': 'user_demo_2',
        'username': 'marie_expert',
        'name': 'Marie Expert',
        'email': 'marie@example.com',
        'level': 8,
        'totalPoints': 850,
        'streakDays': 15,
        'isOnline': false,
        'friends': ['user_demo', 'user_demo_3'],
        'stats': {
          'friendsCount': 2,
          'lessonsCompleted': 12,
          'quizzesCompleted': 8,
          'totalPoints': 850,
          'currentStreak': 15,
          'averageLessonScore': 92.0,
          'totalLessonScore': 1104,
        },
      },
      {
        'id': 'user_demo_3',
        'username': 'pierre_novice',
        'name': 'Pierre Novice',
        'email': 'pierre@example.com',
        'level': 1,
        'totalPoints': 50,
        'streakDays': 2,
        'isOnline': true,
        'friends': ['user_demo', 'user_demo_2'],
        'stats': {
          'friendsCount': 2,
          'lessonsCompleted': 1,
          'quizzesCompleted': 0,
          'totalPoints': 50,
          'currentStreak': 2,
          'averageLessonScore': 75.0,
          'totalLessonScore': 75,
        },
      },
    ];

    for (final user in users) {
      await _firestore.collection('users').doc(user['id'] as String).set({
        ...user,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Mettre à jour l'utilisateur existant avec des amis
    await _firestore.collection('users').doc('user_demo').update({
      'friends': ['user_demo_2', 'user_demo_3'],
      'stats.friendsCount': 2,
    });

    Logger.info('✅ ${users.length + 1} utilisateurs mis à jour/ajoutés');
  }

  // Ajout d'une actualité d'essai
  Future<void> _addNews() async {
    Logger.info('📰 Ajout d\'une actualité d\'essai...');
    final news = {
      'id': 'news_essai',
      'title': 'Actualité de test',
      'content': 'Ceci est une actualité ajoutée pour essai.',
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _firestore
        .collection('community')
        .doc(news['id'] as String)
        .set(news);
    Logger.info('✅ Actualité d\'essai ajoutée');
  }

  // Méthodes pour récupérer les données depuis Firestore
  Future<Map<String, dynamic>> getTestDataStats() async {
    try {
      final lessonsCount = await _firestore
          .collection('lessons')
          .get()
          .then((snapshot) => snapshot.docs.length);
      final quizCount = await _firestore
          .collection('quiz_questions')
          .get()
          .then((snapshot) => snapshot.docs.length);
      final challengesCount = await _firestore
          .collection('daily_challenges')
          .get()
          .then((snapshot) => snapshot.docs.length);
      final usersCount = await _firestore
          .collection('users')
          .get()
          .then((snapshot) => snapshot.docs.length);

      Logger.info('📊 Statistiques Firestore:');
      Logger.info('  📚 Leçons: $lessonsCount');
      Logger.info('  🧠 Questions quiz: $quizCount');
      Logger.info('  🏆 Défis: $challengesCount');
      Logger.info('  👥 Utilisateurs: $usersCount');

      return {
        'lessons': lessonsCount,
        'quizQuestions': quizCount,
        'challenges': challengesCount,
        'users': usersCount,
      };
    } catch (e) {
      Logger.error('❌ Erreur lors de la récupération des statistiques: $e');
      return {'lessons': 0, 'quizQuestions': 0, 'challenges': 0, 'users': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getLessonsFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('lessons').get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      Logger.error('Erreur lors de la récupération des leçons: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getQuizQuestionsFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('quiz_questions').get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      Logger.error('Erreur lors de la récupération des questions de quiz: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getChallengesFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('daily_challenges').get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      Logger.error('Erreur lors de la récupération des défis: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUsersFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      Logger.error('Erreur lors de la récupération des utilisateurs: $e');
      return [];
    }
  }

  Future<void> verifyFirestoreData() async {
    Logger.info('🔍 Vérification des données dans Firestore...\n');

    try {
      // Vérifier les leçons
      Logger.info('📚 VÉRIFICATION DES LEÇONS:');
      final lessons = await getLessonsFromFirestore();
      if (lessons.isEmpty) {
        Logger.info('  ❌ Aucune leçon trouvée');
      } else {
        Logger.info('  ✅ ${lessons.length} leçons trouvées:');
        for (var lesson in lessons.take(3)) {
          Logger.info('    - ${lesson['title']} (${lesson['level']})');
        }
        if (lessons.length > 3) {
          Logger.info('    ... et ${lessons.length - 3} autres');
        }
      }

      // Vérifier les questions de quiz
      Logger.info('\n🧠 VÉRIFICATION DES QUESTIONS DE QUIZ:');
      final quizQuestions = await getQuizQuestionsFromFirestore();
      if (quizQuestions.isEmpty) {
        Logger.info('  ❌ Aucune question de quiz trouvée');
      } else {
        Logger.info('  ✅ ${quizQuestions.length} questions trouvées:');
        for (var question in quizQuestions.take(3)) {
          Logger.info(
            '    - ${question['question']} (${question['category']})',
          );
        }
        if (quizQuestions.length > 3) {
          Logger.info('    ... et ${quizQuestions.length - 3} autres');
        }
      }

      // Vérifier les défis
      Logger.info('\n🏆 VÉRIFICATION DES DÉFIS:');
      final challenges = await getChallengesFromFirestore();
      if (challenges.isEmpty) {
        Logger.info('  ❌ Aucun défi trouvé');
      } else {
        Logger.info('  ✅ ${challenges.length} défis trouvés:');
        for (var challenge in challenges.take(3)) {
          Logger.info(
            '    - ${challenge['title']} (${challenge['points']} points)',
          );
        }
        if (challenges.length > 3) {
          Logger.info('    ... et ${challenges.length - 3} autres');
        }
      }

      // Vérifier les utilisateurs
      Logger.info('\n👥 VÉRIFICATION DES UTILISATEURS:');
      final users = await getUsersFromFirestore();
      if (users.isEmpty) {
        Logger.info('  ❌ Aucun utilisateur trouvé');
      } else {
        Logger.info('  ✅ ${users.length} utilisateurs trouvés:');
        for (var user in users.take(3)) {
          final stats = user['stats'] as Map<String, dynamic>? ?? {};
          Logger.info(
            '    - ${user['name'] ?? user['username']} (Niveau ${user['level'] ?? 1}, ${stats['totalPoints'] ?? 0} points)',
          );
        }
        if (users.length > 3) {
          Logger.info('    ... et ${users.length - 3} autres');
        }
      }

      // Vérifier les posts communautaires
      Logger.info('\n💬 VÉRIFICATION DES POSTS COMMUNAUTAIRES:');
      final communityPosts = await _firestore.collection('community').get();
      if (communityPosts.docs.isEmpty) {
        Logger.info('  ❌ Aucun post communautaire trouvé');
      } else {
        Logger.info('  ✅ ${communityPosts.docs.length} posts trouvés');
      }

      Logger.info('\n🎯 VÉRIFICATION TERMINÉE');
    } catch (e) {
      Logger.error('❌ Erreur lors de la vérification des données', e);
    }
  }
}
