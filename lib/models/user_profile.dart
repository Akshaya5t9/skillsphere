class UserProfile {
  final String name;
  final String title;
  final int streakDays;
  final int xp;
  final int level;
  final int completedCourses;
  final int quizzesTaken;
  final List<String> badges;

  UserProfile({
    required this.name,
    required this.title,
    required this.streakDays,
    required this.xp,
    required this.level,
    required this.completedCourses,
    required this.quizzesTaken,
    required this.badges,
  });

  UserProfile copyWith({
    String? name,
    String? title,
    int? streakDays,
    int? xp,
    int? level,
    int? completedCourses,
    int? quizzesTaken,
    List<String>? badges,
  }) {
    return UserProfile(
      name: name ?? this.name,
      title: title ?? this.title,
      streakDays: streakDays ?? this.streakDays,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      completedCourses: completedCourses ?? this.completedCourses,
      quizzesTaken: quizzesTaken ?? this.quizzesTaken,
      badges: badges ?? this.badges,
    );
  }
}
