class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String skillDomain;
  int? userSelectedIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.skillDomain = 'Core Flutter',
    this.userSelectedIndex,
  });

  bool get isAnswered => userSelectedIndex != null;
  bool get isCorrect => userSelectedIndex == correctOptionIndex;
}

class Quiz {
  final String id;
  final String topic;
  final String difficulty;
  final int timeLimitSeconds;
  final List<QuizQuestion> questions;

  Quiz({
    required this.id,
    required this.topic,
    required this.difficulty,
    this.timeLimitSeconds = 30,
    required this.questions,
  });

  int get score => questions.where((q) => q.isCorrect).length;
  double get percentage => questions.isEmpty ? 0 : (score / questions.length) * 100;
}
