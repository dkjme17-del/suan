import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // Initialiser Firebase
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  print('🚀 Ajout de données test SUAN...');

  // Ajouter des leçons
  await firestore.collection('lessons').doc('lesson_1').set({
    'id': 'lesson_1',
    'title': 'Bonjour le Baoulé',
    'description': 'Apprenez les salutations basiques',
    'level': 'beginner',
    'content': 'Gbéhéfié (Bonjour), Akoa (Au revoir)',
    'vocabulary': ['Gbéhéfié', 'Akoa', 'Médja', 'Afia'],
    'durationMinutes': 5,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('lessons').doc('lesson_2').set({
    'id': 'lesson_2',
    'title': 'Les nombres',
    'description': 'Compter de 1 à 10 en baoulé',
    'level': 'beginner',
    'content': 'Yue (1), Ue (2), Yie (3), Ine (4), Onan (5), Nian (6), Kple (7), Sie (8), Kua (9), Kpleu (10)',
    'vocabulary': ['Yue', 'Ue', 'Yie', 'Ine', 'Onan', 'Nian', 'Kple', 'Sie', 'Kua', 'Kpleu'],
    'durationMinutes': 5,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('lessons').doc('lesson_3').set({
    'id': 'lesson_3',
    'title': 'La famille',
    'description': 'Apprenez les mots de la famille',
    'level': 'beginner',
    'content': 'Papa (père), Mama (mère), Wô (enfant), Niangban (frère), Niangba (sœur)',
    'vocabulary': ['Papa', 'Mama', 'Wô', 'Niangban', 'Niangba', 'Gô', 'Tô'],
    'durationMinutes': 7,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('lessons').doc('lesson_4').set({
    'id': 'lesson_4',
    'title': 'Les couleurs',
    'description': 'Découvrez les couleurs en baoulé',
    'level': 'beginner',
    'content': 'Fîn (blanc), Djo (noir), Kô (rouge), Kôkô (bleu), Wê (vert)',
    'vocabulary': ['Fîn', 'Djo', 'Kô', 'Kôkô', 'Wê', 'Saki', 'Kôkôdjo'],
    'durationMinutes': 6,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('lessons').doc('lesson_5').set({
    'id': 'lesson_5',
    'title': 'Les animaux',
    'description': 'Les animaux de la savane',
    'level': 'intermediate',
    'content': 'Kpan (éléphant), Wôkô (lion), Kôkô (singe), Gbê (serpent), Kô (oiseau)',
    'vocabulary': ['Kpan', 'Wôkô', 'Kôkô', 'Gbê', 'Kô', 'Gbêkô', 'Wôgbê'],
    'durationMinutes': 8,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('lessons').doc('lesson_6').set({
    'id': 'lesson_6',
    'title': 'La nourriture',
    'description': 'Les aliments traditionnels',
    'level': 'intermediate',
    'content': 'Gbô (riz), Kô (igname), Gbê (viande), Kôkô (huile), Wê (eau)',
    'vocabulary': ['Gbô', 'Kô', 'Gbê', 'Kôkô', 'Wê', 'Gbêkô', 'Kôgbê'],
    'durationMinutes': 10,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('lessons').doc('lesson_7').set({
    'id': 'lesson_7',
    'title': 'Les verbes d\'action',
    'description': 'Les actions courantes',
    'level': 'intermediate',
    'content': 'Kô (aller), Gbê (venir), Kôkô (manger), Wê (boire), Gbô (dormir)',
    'vocabulary': ['Kô', 'Gbê', 'Kôkô', 'Wê', 'Gbô', 'Kôgbê', 'Wêkô'],
    'durationMinutes': 12,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('lessons').doc('lesson_8').set({
    'id': 'lesson_8',
    'title': 'Expressions idiomatiques',
    'description': 'Expressions courantes avancées',
    'level': 'advanced',
    'content': 'Kô gbê wê (Aller et venir), Gbô kôkô (Dormir et manger), Wê gbê kô (Boire et venir)',
    'vocabulary': ['Kô gbê wê', 'Gbô kôkô', 'Wê gbê kô', 'Kôkô gbê', 'Gbê wê kô'],
    'durationMinutes': 15,
    'createdAt': FieldValue.serverTimestamp(),
  });

  // Ajouter des catégories de quiz
  await firestore.collection('quiz_categories').doc('vocab').set({
    'id': 'vocab',
    'name': 'Vocabulaire',
    'description': 'Testez votre vocabulaire baoulé',
    'icon': 'book',
    'color': 'blue',
    'questionCount': 15,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('quiz_categories').doc('grammar').set({
    'id': 'grammar',
    'name': 'Grammaire',
    'description': 'Exercices de grammaire',
    'icon': 'pencil',
    'color': 'green',
    'questionCount': 12,
    'createdAt': FieldValue.serverTimestamp(),
  });

  // Ajouter des questions de quiz
  await firestore.collection('quiz_questions').doc('q1').set({
    'id': 'q1',
    'category': 'vocab',
    'question': 'Quel est le Baoulé pour "Bonjour"?',
    'options': ['Gbéhéfié', 'Médja', 'Akoa', 'Ahôh'],
    'correctAnswer': 'Gbéhéfié',
    'explanation': 'Gbéhéfié est la salutation standard baoulé',
    'points': 10,
  });

  await firestore.collection('quiz_questions').doc('q2').set({
    'id': 'q2',
    'category': 'vocab',
    'question': 'Comment dire "Merci" en Baoulé?',
    'options': ['Médja', 'Akoa', 'Gbéhéné', 'Ahôh'],
    'correctAnswer': 'Médja',
    'explanation': 'Médja signifie merci',
    'points': 10,
  });

  await firestore.collection('quiz_questions').doc('q3').set({
    'id': 'q3',
    'category': 'vocab',
    'question': 'Quel mot signifie "Au revoir"?',
    'options': ['Gbéhéfié', 'Akoa', 'Médja', 'Afia'],
    'correctAnswer': 'Akoa',
    'explanation': 'Akoa est la façon de dire au revoir',
    'points': 10,
  });

  await firestore.collection('quiz_questions').doc('q4').set({
    'id': 'q4',
    'category': 'vocab',
    'question': 'Comment compter "1" en Baoulé?',
    'options': ['Yue', 'Ue', 'Yie', 'Ine'],
    'correctAnswer': 'Yue',
    'explanation': 'Yue signifie 1 en baoulé',
    'points': 10,
  });

  await firestore.collection('quiz_questions').doc('q5').set({
    'id': 'q5',
    'category': 'vocab',
    'question': 'Quel mot désigne le père?',
    'options': ['Mama', 'Papa', 'Wô', 'Niangban'],
    'correctAnswer': 'Papa',
    'explanation': 'Papa signifie père en baoulé',
    'points': 10,
  });

  await firestore.collection('quiz_questions').doc('q6').set({
    'id': 'q6',
    'category': 'vocab',
    'question': 'Quelle couleur est "Kô"?',
    'options': ['Blanc', 'Rouge', 'Bleu', 'Vert'],
    'correctAnswer': 'Rouge',
    'explanation': 'Kô signifie rouge en baoulé',
    'points': 10,
  });

  await firestore.collection('quiz_questions').doc('q7').set({
    'id': 'q7',
    'category': 'vocab',
    'question': 'Comment dire "éléphant"?',
    'options': ['Wôkô', 'Kpan', 'Kôkô', 'Gbê'],
    'correctAnswer': 'Kpan',
    'explanation': 'Kpan signifie éléphant en baoulé',
    'points': 15,
  });

  await firestore.collection('quiz_questions').doc('q8').set({
    'id': 'q8',
    'category': 'vocab',
    'question': 'Quel aliment est "Gbô"?',
    'options': ['Viande', 'Riz', 'Huile', 'Eau'],
    'correctAnswer': 'Riz',
    'explanation': 'Gbô signifie riz en baoulé',
    'points': 15,
  });

  await firestore.collection('quiz_questions').doc('q9').set({
    'id': 'q9',
    'category': 'grammar',
    'question': 'Quelle est la structure correcte pour "Je vais"?',
    'options': ['M\' kô', 'Kô m\'', 'M kô', 'Kô m'],
    'correctAnswer': 'M\' kô',
    'explanation': 'En baoulé, "Je vais" se dit "M\' kô"',
    'points': 20,
  });

  await firestore.collection('quiz_questions').doc('q10').set({
    'id': 'q10',
    'category': 'grammar',
    'question': 'Comment former le pluriel de "wô" (enfant)?',
    'options': ['Wôô', 'Wôwô', 'Wôlê', 'Wôba'],
    'correctAnswer': 'Wôô',
    'explanation': 'Le pluriel de wô (enfant) est wôô',
    'points': 20,
  });

  // Ajouter des défis quotidiens
  await firestore.collection('daily_challenges').doc('challenge_1').set({
    'id': 'challenge_1',
    'title': 'Maître du vocabulaire',
    'description': 'Complétez 10 exercices de vocabulaire',
    'points': 50,
    'icon': 'trophy',
    'progress': 0.7,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('daily_challenges').doc('challenge_2').set({
    'id': 'challenge_2',
    'title': 'Conversation parfaite',
    'description': 'Atteignez 90% de précision',
    'points': 75,
    'icon': 'comments',
    'progress': 0.0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('daily_challenges').doc('challenge_3').set({
    'id': 'challenge_3',
    'title': 'Apprenti du jour',
    'description': 'Complétez 3 leçons aujourd\'hui',
    'points': 30,
    'icon': 'book',
    'progress': 0.0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('daily_challenges').doc('challenge_4').set({
    'id': 'challenge_4',
    'title': 'Maître des nombres',
    'description': 'Apprenez à compter jusqu\'à 20',
    'points': 40,
    'icon': 'calculator',
    'progress': 0.0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('daily_challenges').doc('challenge_5').set({
    'id': 'challenge_5',
    'title': 'Famille unie',
    'description': 'Apprenez tous les mots de la famille',
    'points': 35,
    'icon': 'users',
    'progress': 0.0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('daily_challenges').doc('challenge_6').set({
    'id': 'challenge_6',
    'title': 'Arc-en-ciel',
    'description': 'Maîtrisez toutes les couleurs',
    'points': 45,
    'icon': 'palette',
    'progress': 0.0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('daily_challenges').doc('challenge_7').set({
    'id': 'challenge_7',
    'title': 'Safari virtuel',
    'description': 'Découvrez 5 animaux différents',
    'points': 50,
    'icon': 'paw',
    'progress': 0.0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  await firestore.collection('daily_challenges').doc('challenge_8').set({
    'id': 'challenge_8',
    'title': 'Gourmet baoulé',
    'description': 'Apprenez 7 mots liés à la nourriture',
    'points': 55,
    'icon': 'utensils',
    'progress': 0.0,
    'createdAt': FieldValue.serverTimestamp(),
  });

  // Ajouter des posts communautaires
  await firestore.collection('community').doc('post_1').set({
    'id': 'post_1',
    'authorId': 'user_demo',
    'authorName': 'Jean Apprenti',
    'content': 'J\'ai appris 10 nouveaux mots aujourd\'hui! 🎉 Gbéhéfié, Médja, Akoa...',
    'timestamp': FieldValue.serverTimestamp(),
    'likes': 5,
    'comments': [],
  });

  await firestore.collection('community').doc('post_2').set({
    'id': 'post_2',
    'authorId': 'user_demo_2',
    'authorName': 'Marie Expert',
    'content': 'Mon streak est de 15 jours! 🔥 Continuez vos efforts !',
    'timestamp': FieldValue.serverTimestamp(),
    'likes': 12,
    'comments': [],
  });

  // Créer un utilisateur demo
  await firestore.collection('users').doc('user_demo').set({
    'id': 'user_demo',
    'username': 'jean_apprenti',
    'name': 'Jean Apprenti',
    'email': 'jean@example.com',
    'level': 3,
    'totalPoints': 250,
    'streakDays': 5,
    'isOnline': true,
    'lastLoginAt': FieldValue.serverTimestamp(),
    'createdAt': FieldValue.serverTimestamp(),
    'friends': ['user_demo_2', 'user_demo_3'],
    'stats': {
      'friendsCount': 2,
      'lessonsCompleted': 5,
      'quizzesCompleted': 3,
      'totalPoints': 250,
      'currentStreak': 5,
      'averageLessonScore': 85.0,
      'totalLessonScore': 425,
    },
  });

  await firestore.collection('users').doc('user_demo_2').set({
    'id': 'user_demo_2',
    'username': 'marie_expert',
    'name': 'Marie Expert',
    'email': 'marie@example.com',
    'level': 8,
    'totalPoints': 850,
    'streakDays': 15,
    'isOnline': false,
    'lastLoginAt': FieldValue.serverTimestamp(),
    'createdAt': FieldValue.serverTimestamp(),
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
  });

  await firestore.collection('users').doc('user_demo_3').set({
    'id': 'user_demo_3',
    'username': 'pierre_novice',
    'name': 'Pierre Novice',
    'email': 'pierre@example.com',
    'level': 1,
    'totalPoints': 50,
    'streakDays': 2,
    'isOnline': true,
    'lastLoginAt': FieldValue.serverTimestamp(),
    'createdAt': FieldValue.serverTimestamp(),
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
  });

  print('✅ Données test ajoutées avec succès!');
  print('📱 Rafraîchissez votre app pour voir les changements');
  print('🔗 https://suan-16f16.web.app');
}
