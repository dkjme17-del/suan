class Lesson {
  final String id;
  final String title;
  final String description;
  final String level; // beginner, intermediate, advanced
  final String content;
  final List<String> vocabulary;
  final String? audioUrl;
  final int durationMinutes;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.content,
    required this.vocabulary,
    this.audioUrl,
    required this.durationMinutes,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? 'beginner',
      content: json['content'] ?? '',
      vocabulary: List<String>.from(json['vocabulary'] ?? []),
      audioUrl: json['audioUrl'],
      durationMinutes: json['durationMinutes'] ?? 5,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'content': content,
      'vocabulary': vocabulary,
      'audioUrl': audioUrl,
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
    };
  }
}


