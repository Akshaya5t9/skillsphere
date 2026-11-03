class RoadmapStep {
  final String id;
  final String title;
  final String description;
  final String estimatedTime;
  final String categoryTag; // Foundation, Architecture, AI, Capstone
  final bool isCompleted;

  RoadmapStep({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedTime,
    this.categoryTag = 'Core',
    this.isCompleted = false,
  });

  RoadmapStep copyWith({bool? isCompleted}) {
    return RoadmapStep(
      id: id,
      title: title,
      description: description,
      estimatedTime: estimatedTime,
      categoryTag: categoryTag,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'estimatedTime': estimatedTime,
    'categoryTag': categoryTag,
    'isCompleted': isCompleted,
  };

  factory RoadmapStep.fromJson(Map<String, dynamic> json) => RoadmapStep(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    estimatedTime: json['estimatedTime'] ?? '1 week',
    categoryTag: json['categoryTag'] ?? 'Core',
    isCompleted: json['isCompleted'] ?? false,
  );
}

class Roadmap {
  final String id;
  final String targetGoal;
  final String experienceLevel;
  final String weeklyHours;
  final String aiRationale;
  final String salaryRange;
  final String marketDemand;
  final List<RoadmapStep> steps;

  Roadmap({
    required this.id,
    required this.targetGoal,
    required this.experienceLevel,
    required this.weeklyHours,
    required this.aiRationale,
    this.salaryRange = '\$115,000 - \$160,000/yr',
    this.marketDemand = 'High Demand • 28% YoY Growth',
    required this.steps,
  });

  int get completedSteps => steps.where((s) => s.isCompleted).length;
  double get progressPercentage => steps.isEmpty ? 0.0 : (completedSteps / steps.length);

  Roadmap copyWith({List<RoadmapStep>? steps}) {
    return Roadmap(
      id: id,
      targetGoal: targetGoal,
      experienceLevel: experienceLevel,
      weeklyHours: weeklyHours,
      aiRationale: aiRationale,
      salaryRange: salaryRange,
      marketDemand: marketDemand,
      steps: steps ?? this.steps,
    );
  }
}
