import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../core/services/gemini_service.dart';

class QuizProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  Quiz? _activeQuiz;
  bool _isLoading = false;
  int _currentQuestionIndex = 0;
  bool _isSubmitted = false;
  bool _isReviewMode = false;

  int _remainingSeconds = 30;
  Timer? _timer;

  Quiz? get activeQuiz => _activeQuiz;
  bool get isLoading => _isLoading;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isSubmitted => _isSubmitted;
  bool get isReviewMode => _isReviewMode;
  int get remainingSeconds => _remainingSeconds;

  QuizQuestion? get currentQuestion {
    if (_activeQuiz == null || _activeQuiz!.questions.isEmpty) return null;
    if (_currentQuestionIndex >= _activeQuiz!.questions.length) return null;
    return _activeQuiz!.questions[_currentQuestionIndex];
  }

  QuizProvider() {
    startNewQuiz(topic: 'Flutter & Mobile Architecture', difficulty: 'Intermediate');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        // Time expired, auto advance or submit
        nextQuestion();
      }
    });
  }

  Future<void> startNewQuiz({required String topic, required String difficulty}) async {
    _isLoading = true;
    _isSubmitted = false;
    _isReviewMode = false;
    _currentQuestionIndex = 0;
    _timer?.cancel();
    notifyListeners();

    try {
      _activeQuiz = await _geminiService.generateQuiz(topic: topic, difficulty: difficulty);
      _startTimer();
    } catch (e) {
      // Handled in gemini_service
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectOption(int optionIndex) {
    if (_activeQuiz == null || _isSubmitted) return;
    final question = currentQuestion;
    if (question == null) return;

    question.userSelectedIndex = optionIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (_activeQuiz == null) return;
    if (_currentQuestionIndex < _activeQuiz!.questions.length - 1) {
      _currentQuestionIndex++;
      _startTimer();
      notifyListeners();
    } else {
      _timer?.cancel();
      _isSubmitted = true;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void enterReviewMode() {
    _isReviewMode = true;
    _currentQuestionIndex = 0;
    notifyListeners();
  }

  void exitReviewMode() {
    _isReviewMode = false;
    notifyListeners();
  }

  void resetQuiz() {
    if (_activeQuiz == null) return;
    for (final q in _activeQuiz!.questions) {
      q.userSelectedIndex = null;
    }
    _currentQuestionIndex = 0;
    _isSubmitted = false;
    _isReviewMode = false;
    _startTimer();
    notifyListeners();
  }

  Map<String, double> getDomainBreakdown() {
    if (_activeQuiz == null) return {};
    final domains = <String, List<bool>>{};
    for (final q in _activeQuiz!.questions) {
      domains.putIfAbsent(q.skillDomain, () => []).add(q.isCorrect);
    }

    final result = <String, double>{};
    domains.forEach((domain, results) {
      final correct = results.where((r) => r).length;
      result[domain] = (correct / results.length) * 100;
    });
    return result;
  }
}
