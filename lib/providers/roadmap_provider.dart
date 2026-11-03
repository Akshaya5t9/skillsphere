import 'package:flutter/material.dart';
import '../models/roadmap.dart';
import '../core/services/gemini_service.dart';

class RoadmapProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  Roadmap? _currentRoadmap;
  bool _isLoading = false;
  String? _errorMessage;

  RoadmapProvider() {
    _initDefaultRoadmap();
  }

  Roadmap? get currentRoadmap => _currentRoadmap;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initDefaultRoadmap() {
    _currentRoadmap = Roadmap(
      id: 'default_flutter_ai',
      targetGoal: 'Full-Stack Flutter & AI Engineer',
      experienceLevel: 'Intermediate',
      weeklyHours: '8-10 hrs/week',
      salaryRange: '\$125,000 - \$175,000/yr',
      marketDemand: '🔥 Top 5 Mobile Role • 34% YoY Growth',
      aiRationale: 'Targeted pathway bridging modern client application design with generative AI backends and cloud storage.',
      steps: [
        RoadmapStep(
          id: 'step_1',
          title: 'Dart 3 Mastery & Functional Patterns',
          description: 'Records, sealed classes, pattern matching, sound null safety, and async streams.',
          estimatedTime: '1 week',
          categoryTag: 'Foundation',
          isCompleted: true,
        ),
        RoadmapStep(
          id: 'step_2',
          title: 'Flutter UI Composition & Custom Renderers',
          description: 'Slivers, responsive layouts, theme engines, and accessibility guidelines.',
          estimatedTime: '2 weeks',
          categoryTag: 'UI Systems',
          isCompleted: true,
        ),
        RoadmapStep(
          id: 'step_3',
          title: 'Reactive State Architecture & Repositories',
          description: 'Provider/Riverpod clean architecture, dependency injection, and offline persistence.',
          estimatedTime: '2 weeks',
          categoryTag: 'Architecture',
          isCompleted: false,
        ),
        RoadmapStep(
          id: 'step_4',
          title: 'Gemini LLM & Multimodal AI Integration',
          description: 'REST streaming endpoints, system prompts, structured JSON outputs, and offline fallback engines.',
          estimatedTime: '2 weeks',
          categoryTag: 'AI Co-pilot',
          isCompleted: false,
        ),
        RoadmapStep(
          id: 'step_5',
          title: 'Automated CI/CD & App Store Launch',
          description: 'Unit/Widget test suites, GitHub Actions, release obfuscation, and Play Console deployment.',
          estimatedTime: '2 weeks',
          categoryTag: 'Capstone',
          isCompleted: false,
        ),
      ],
    );
  }

  Future<void> generateNewRoadmap({
    required String goal,
    required String level,
    required String hours,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final roadmap = await _geminiService.generateRoadmap(
        targetGoal: goal,
        experienceLevel: level,
        weeklyHours: hours,
      );
      _currentRoadmap = roadmap;
    } catch (e) {
      _errorMessage = 'Failed to generate roadmap: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleStep(String stepId) {
    if (_currentRoadmap == null) return;

    final updatedSteps = _currentRoadmap!.steps.map((step) {
      if (step.id == stepId) {
        return step.copyWith(isCompleted: !step.isCompleted);
      }
      return step;
    }).toList();

    _currentRoadmap = _currentRoadmap!.copyWith(steps: updatedSteps);
    notifyListeners();
  }
}
