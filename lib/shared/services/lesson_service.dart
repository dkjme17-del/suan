import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/logger.dart';
import 'package:suan/features/learning/domain/entities/lesson.dart';

class LessonService {
  static final LessonService _instance = LessonService._internal();
  factory LessonService() => _instance;
  LessonService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Lesson>> streamLessonsByLevel(String level) {
    return _firestore
        .collection('lessons')
        .where('level', isEqualTo: level)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Lesson.fromJson(doc.data()))
              .toList();
        });
  }

  Stream<List<Lesson>> streamAllLessons() {
    return _firestore.collection('lessons').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Lesson.fromJson(doc.data())).toList();
    });
  }

  Stream<Lesson?> streamLessonById(String id) {
    return _firestore.collection('lessons').doc(id).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Lesson.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  List<Lesson> getLessonsByLevel(String level) {
    return [];
  }

  Lesson? getLessonById(String id) {
    return null;
  }

  Future<void> completeLesson(String lessonId, {String? userId}) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).update({
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Logger.error('❌ Erreur complétion leçon', e);
      rethrow;
    }
  }
}
