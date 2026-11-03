import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../core/services/gemini_service.dart';

class AiTutorProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;

  AiTutorProvider() {
    _initWelcomeMessage();
  }

  List<ChatMessage> get messages => _messages;
  bool get isGenerating => _isGenerating;

  void _initWelcomeMessage() {
    _messages.add(
      ChatMessage(
        id: 'welcome_coach_1',
        text: '''👋 **I am Coach Lumina, your Active Job Readiness & Engineering Mentor.**

I don't just answer questions passively — my mission is to get you hired and interview-ready.

**Choose your active drill for today:**
1. 🎯 **Architecture Drill**: Test your system design instincts.
2. 👔 **Mock Interview Question**: Practice articulating answers out loud.
3. 🐛 **Code Debugging Challenge**: Find the subtle memory leak or widget rebuild bug.

*What would you like to master right now?*''',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedFollowUps: [
          '🎯 Give me a 2-minute Architecture Drill',
          '👔 Ask me a Junior Developer Interview Question',
          '🐛 Give me a broken Flutter code snippet to fix',
          '⚡ Explain Riverpod vs Provider with code',
        ],
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isGenerating) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isGenerating = true;
    notifyListeners();

    try {
      final aiResponse = await _geminiService.askAiTutor(
        prompt: trimmed,
        history: _messages,
      );
      _messages.add(aiResponse);
    } catch (e) {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '⚠️ An unexpected error occurred while processing your request. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _initWelcomeMessage();
    notifyListeners();
  }
}
