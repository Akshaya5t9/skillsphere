import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../core/services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  UserProfile _user = UserProfile(
    name: 'Alex Johnson',
    title: 'Aspiring AI & Mobile Developer',
    streakDays: 5,
    xp: 1420,
    level: 4,
    completedCourses: 2,
    quizzesTaken: 8,
    badges: ['🚀 Quick Starter', '🎯 Quiz Master', '🤖 Prompt Prodigy', '📱 Flutter Fanatic'],
  );

  bool _isDarkMode = true;
  String? _apiKey;

  UserProfile get user => _user;
  bool get isDarkMode => _isDarkMode;
  String? get apiKey => _apiKey;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  UserProvider() {
    _loadInitialSettings();
  }

  Future<void> _loadInitialSettings() async {
    _isDarkMode = await _storageService.getThemeMode();
    _apiKey = await _storageService.getApiKey();
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    if (key.trim().isEmpty) {
      await _storageService.removeApiKey();
      _apiKey = null;
    } else {
      await _storageService.saveApiKey(key);
      _apiKey = key.trim();
    }
    notifyListeners();
  }

  void addXp(int amount) {
    final newXp = _user.xp + amount;
    final newLevel = (newXp / 500).floor() + 1;
    _user = _user.copyWith(xp: newXp, level: newLevel);
    notifyListeners();
  }

  void incrementQuizzes() {
    _user = _user.copyWith(quizzesTaken: _user.quizzesTaken + 1);
    addXp(50);
  }
}
