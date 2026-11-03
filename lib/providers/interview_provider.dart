import 'package:flutter/material.dart';
import '../models/interview_session.dart';
import '../core/services/gemini_service.dart';

class InterviewProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  InterviewSession? _activeSession;
  int _currentQuestionIndex = 0;
  bool _isEvaluating = false;
  InterviewEvaluation? _latestEvaluation;

  InterviewSession? get activeSession => _activeSession;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isEvaluating => _isEvaluating;
  InterviewEvaluation? get latestEvaluation => _latestEvaluation;

  InterviewQuestion? get currentQuestion {
    if (_activeSession == null || _activeSession!.questions.isEmpty) return null;
    if (_currentQuestionIndex >= _activeSession!.questions.length) return null;
    return _activeSession!.questions[_currentQuestionIndex];
  }

  bool get isLastQuestion {
    if (_activeSession == null) return false;
    return _currentQuestionIndex == _activeSession!.questions.length - 1;
  }

  InterviewProvider() {
    startNewSession(role: 'Junior Full-Stack Flutter Developer');
  }

  void startNewSession({required String role}) {
    _currentQuestionIndex = 0;
    _isEvaluating = false;
    _latestEvaluation = null;

    final questions = [
      InterviewQuestion(
        id: 'q1',
        question: 'Explain Flutter’s three-tree architecture: Widget Tree, Element Tree, and RenderObject Tree. Why does this design make Flutter fast?',
        category: 'Flutter & UI',
        difficulty: 'Junior',
        keyTalkingPoints: ['Widget is configuration/blueprint', 'Element is lifecycle/identity', 'RenderObject handles layout and painting', 'cheap rebuilds'],
        idealAnswerSummary: 'Widgets are lightweight, immutable configuration objects recreated frequently. The Element tree manages lifecycle and state, retaining identity across builds. The RenderObject tree handles expensive layout calculations and painting, only updating dirty nodes rather than rebuilding the whole screen.',
      ),
      InterviewQuestion(
        id: 'q2',
        question: 'What is the difference between Ephemeral State and App-Wide State? When would you use setState versus Provider/Riverpod?',
        category: 'Architecture & State',
        difficulty: 'Junior',
        keyTalkingPoints: ['setState for local', 'Provider for shared', 'Maintainability', 'Separation of concerns'],
        idealAnswerSummary: 'Ephemeral state is local to a single widget (like an animation toggle or text field input) and is best managed with setState. App-wide state is shared across multiple screens (like user authentication or a shopping cart) and requires Provider/Riverpod to decouple business logic from the UI and prevent prop-drilling.',
      ),
      InterviewQuestion(
        id: 'q3',
        question: 'How do you detect and prevent memory leaks in Flutter when working with Streams, AnimationControllers, or TextEditingControllers?',
        category: 'Dart Core',
        difficulty: 'Mid-Level',
        keyTalkingPoints: ['dispose() method', 'cancel StreamSubscription', 'leak_tracker or DevTools Memory profiler'],
        idealAnswerSummary: 'Every controller and StreamSubscription allocated in a State object must be disposed or cancelled inside the dispose() lifecycle method. Unclosed subscriptions retain references to callbacks and context, preventing garbage collection. DevTools Memory profiler can be used to track retained instances.',
      ),
      InterviewQuestion(
        id: 'q4',
        question: 'Tell me about a time when an app crashed or faced laggy frame drops (jank). How did you diagnose and resolve the issue?',
        category: 'Behavioral & Troubleshooting',
        difficulty: 'Junior',
        keyTalkingPoints: ['DevTools Performance view', 'avoid expensive work in build()', 'RepaintBoundary', 'STAR method'],
        idealAnswerSummary: 'Using Flutter DevTools Performance overlay, I identified frames taking longer than 16ms (60fps threshold). The root cause was an expensive JSON parsing loop running synchronously inside a widget build method. I offloaded the computation to a background isolate with compute() and wrapped dynamic widgets in RepaintBoundary, restoring smooth 60fps.',
      ),
    ];

    _activeSession = InterviewSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      targetRole: role,
      date: DateTime.now(),
      questions: questions,
    );

    notifyListeners();
  }

  Future<InterviewEvaluation> submitAnswer(String answer) async {
    final question = currentQuestion;
    if (_activeSession == null || question == null) {
      throw Exception('No active question to evaluate');
    }

    _isEvaluating = true;
    _activeSession!.userAnswers[question.id] = answer.trim();
    notifyListeners();

    try {
      final evaluation = await _geminiService.evaluateInterviewAnswer(
        question: question,
        candidateAnswer: answer.trim(),
      );

      _latestEvaluation = evaluation;
      _activeSession!.evaluations[question.id] = evaluation;
      return evaluation;
    } finally {
      _isEvaluating = false;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_activeSession == null) return;
    if (_currentQuestionIndex < _activeSession!.questions.length - 1) {
      _currentQuestionIndex++;
      _latestEvaluation = null;
      notifyListeners();
    } else {
      _activeSession!.isCompleted = true;
      notifyListeners();
    }
  }
}
