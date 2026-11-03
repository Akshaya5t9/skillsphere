class Lesson {
  final String id;
  final String title;
  final String duration;
  final String summary;
  final String contentMarkdown;
  final String? codeSnippet;
  final List<String> keyTakeaways;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
    this.summary = '',
    this.contentMarkdown = '',
    this.codeSnippet,
    this.keyTakeaways = const [],
    this.isCompleted = false,
  });

  Lesson copyWith({
    bool? isCompleted,
    String? contentMarkdown,
    String? codeSnippet,
    List<String>? keyTakeaways,
  }) {
    return Lesson(
      id: id,
      title: title,
      duration: duration,
      summary: summary,
      contentMarkdown: contentMarkdown ?? this.contentMarkdown,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      keyTakeaways: keyTakeaways ?? this.keyTakeaways,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Course {
  final String id;
  final String title;
  final String category;
  final String level; // Beginner, Intermediate, Advanced
  final double rating;
  final int totalLessons;
  final int completedLessons;
  final String description;
  final String iconName;
  final String instructor;
  final List<String> skillsCovered;
  final List<Lesson> lessons;

  Course({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.rating,
    required this.totalLessons,
    this.completedLessons = 0,
    required this.description,
    required this.iconName,
    this.instructor = 'Lumina AI Faculty',
    required this.skillsCovered,
    required this.lessons,
  });

  double get progress => totalLessons == 0 ? 0 : completedLessons / totalLessons;
  bool get isCompleted => totalLessons > 0 && completedLessons >= totalLessons;

  Course copyWith({
    int? completedLessons,
    List<Lesson>? lessons,
  }) {
    return Course(
      id: id,
      title: title,
      category: category,
      level: level,
      rating: rating,
      totalLessons: totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      description: description,
      iconName: iconName,
      instructor: instructor,
      skillsCovered: skillsCovered,
      lessons: lessons ?? this.lessons,
    );
  }
}
