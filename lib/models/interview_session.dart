class InterviewQuestion {
  final String id;
  final String question;
  final String category; // 'Flutter & UI', 'Architecture & State', 'Dart Core', 'Behavioral'
  final String difficulty; // 'Junior', 'Mid-Level', 'Senior'
  final String idealAnswerSummary;
  final List<String> keyTalkingPoints;

  InterviewQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.difficulty,
    required this.idealAnswerSummary,
    required this.keyTalkingPoints,
  });
}

class InterviewEvaluation {
  final int technicalScore; // 1-10
  final int clarityScore; // 1-10
  final String hiringDecision; // 'Strong Hire', 'Hire', 'Lean Hire', 'No Hire'
  final String strengths;
  final String weaknesses;
  final String improvedAnswer;

  InterviewEvaluation({
    required this.technicalScore,
    required this.clarityScore,
    required this.hiringDecision,
    required this.strengths,
    required this.weaknesses,
    required this.improvedAnswer,
  });

  int get overallScore => ((technicalScore + clarityScore) / 20 * 100).round();
}

class InterviewSession {
  final String id;
  final String targetRole; // e.g. 'Junior Flutter Developer'
  final DateTime date;
  final List<InterviewQuestion> questions;
  final Map<String, String> userAnswers;
  final Map<String, InterviewEvaluation> evaluations;
  bool isCompleted;

  InterviewSession({
    required this.id,
    required this.targetRole,
    required this.date,
    required this.questions,
    Map<String, String>? userAnswers,
    Map<String, InterviewEvaluation>? evaluations,
    this.isCompleted = false,
  })  : userAnswers = userAnswers ?? {},
        evaluations = evaluations ?? {};

  double get averageScore {
    if (evaluations.isEmpty) return 0.0;
    final total = evaluations.values.fold<int>(0, (sum, ev) => sum + ev.overallScore);
    return total / evaluations.length;
  }

  String get finalVerdict {
    final avg = averageScore;
    if (avg >= 85) return 'Strong Hire 🏆';
    if (avg >= 70) return 'Hire 👍';
    if (avg >= 55) return 'Lean Hire ⚠️';
    return 'Needs More Practice 📚';
  }
}
