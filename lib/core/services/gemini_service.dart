import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/chat_message.dart';
import '../../models/roadmap.dart';
import '../../models/quiz.dart';
import '../../models/interview_session.dart';
import 'storage_service.dart';

class GeminiService {
  final StorageService _storageService = StorageService();
  static const String _defaultModel = 'gemini-1.5-flash';

  Future<String?> _getApiKey() async {
    return await _storageService.getApiKey();
  }

  // 1. AI Tutor Chat
  Future<ChatMessage> askAiTutor({
    required String prompt,
    required List<ChatMessage> history,
  }) async {
    final apiKey = await _getApiKey();

    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_defaultModel:generateContent?key=$apiKey',
        );

        final contents = <Map<String, dynamic>>[];
        
        // System instruction context
        contents.add({
          'role': 'user',
          'parts': [
            {'text': 'System Context: You are SkillSphere AI, an expert, enthusiastic AI learning mentor. Explain concepts clearly with concise formatting, bullet points, and practical code snippets where helpful. End with an encouraging check question.'}
          ]
        });
        contents.add({
          'role': 'model',
          'parts': [
            {'text': 'Understood! I am ready to guide and empower the student as SkillSphere AI.'}
          ]
        });

        // Add recent history (up to last 6 messages)
        final recentHistory = history.length > 6 ? history.sublist(history.length - 6) : history;
        for (final msg in recentHistory) {
          contents.add({
            'role': msg.isUser ? 'user' : 'model',
            'parts': [{'text': msg.text}]
          });
        }

        // Add current user prompt
        contents.add({
          'role': 'user',
          'parts': [{'text': prompt}]
        });

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'contents': contents}),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final candidate = data['candidates']?[0];
          final text = candidate?['content']?['parts']?[0]?['text'] ?? '';
          if (text.isNotEmpty) {
            return ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: text,
              isUser: false,
              timestamp: DateTime.now(),
              isOfflineFallback: false,
              suggestedFollowUps: _generateFollowUpSuggestions(prompt),
            );
          }
        }
      } catch (e) {
        // Fallback gracefully on any API error or timeout
      }
    }

    // Smart Offline Fallback
    return _generateOfflineTutorResponse(prompt);
  }

  // 2. AI Personalized Roadmap Generator
  Future<Roadmap> generateRoadmap({
    required String targetGoal,
    required String experienceLevel,
    required String weeklyHours,
  }) async {
    final apiKey = await _getApiKey();

    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_defaultModel:generateContent?key=$apiKey',
        );

        final promptText = '''
Create a step-by-step learning roadmap for a student whose goal is: "$targetGoal".
Their current experience level: "$experienceLevel".
Committed time: "$weeklyHours".
Return ONLY valid JSON matching this schema:
{
  "aiRationale": "A motivating 2-sentence rationale for this path",
  "steps": [
    {
      "id": "step_1",
      "title": "Title of stage",
      "description": "What to learn and build",
      "estimatedTime": "e.g. 2 weeks"
    }
  ]
}
Provide exactly 5 logical, sequential steps. Do NOT wrap in markdown fences if possible, or use standard json.
''';

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'role': 'user',
                'parts': [{'text': promptText}]
              }
            ]
          }),
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          var text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
          text = text.replaceAll('```json', '').replaceAll('```', '').trim();
          final parsed = jsonDecode(text);

          final steps = (parsed['steps'] as List).map((s) => RoadmapStep(
            id: s['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            title: s['title'] ?? 'Milestone',
            description: s['description'] ?? '',
            estimatedTime: s['estimatedTime'] ?? '2 weeks',
          )).toList();

          return Roadmap(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            targetGoal: targetGoal,
            experienceLevel: experienceLevel,
            weeklyHours: weeklyHours,
            aiRationale: parsed['aiRationale'] ?? 'Personalized roadmap designed to match your weekly schedule.',
            steps: steps,
          );
        }
      } catch (e) {
        // Fallback on error
      }
    }

    return _generateOfflineRoadmap(targetGoal, experienceLevel, weeklyHours);
  }

  // 3. AI Quiz Generator
  Future<Quiz> generateQuiz({
    required String topic,
    required String difficulty,
  }) async {
    final apiKey = await _getApiKey();

    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_defaultModel:generateContent?key=$apiKey',
        );

        final promptText = '''
Generate a 4-question multiple choice quiz on the topic: "$topic" at "$difficulty" level.
Return ONLY valid JSON in this format:
[
  {
    "id": "q1",
    "question": "Question text here",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctOptionIndex": 0,
    "explanation": "Clear explanation why this option is correct."
  }
]
Do NOT include markdown fences, return clean JSON.
''';

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'role': 'user',
                'parts': [{'text': promptText}]
              }
            ]
          }),
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          var text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
          text = text.replaceAll('```json', '').replaceAll('```', '').trim();
          final parsedList = jsonDecode(text) as List;

          final questions = parsedList.map((item) => QuizQuestion(
            id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            question: item['question'] ?? '',
            options: List<String>.from(item['options'] ?? []),
            correctOptionIndex: item['correctOptionIndex'] ?? 0,
            explanation: item['explanation'] ?? '',
          )).toList();

          if (questions.isNotEmpty) {
            return Quiz(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              topic: topic,
              difficulty: difficulty,
              questions: questions,
            );
          }
        }
      } catch (e) {
        // Fallback on error
      }
    }

    return _generateOfflineQuiz(topic, difficulty);
  }

  // Offline Intelligence & Fallbacks
  ChatMessage _generateOfflineTutorResponse(String prompt) {
    final lower = prompt.toLowerCase();
    String responseText;
    List<String> suggestions = [
      'Show me a practical Flutter example',
      'What are the key best practices?',
      'Generate a quick quiz on this',
    ];

    if (lower.contains('state') || lower.contains('provider') || lower.contains('riverpod')) {
      responseText = '''
### Understanding State Management in Flutter 🚀

In Flutter, **state** is any data that changes over time and affects your UI.

1. **Ephemeral (Local) State**: Managed inside a single widget using `StatefulWidget` and `setState()`. Best for checkboxes, animation toggles, or tab indexes.
2. **App (Global) State**: Shared across multiple screens and widgets. For this, reactive solutions like **Provider**, **Riverpod**, or **Bloc** are industry standards.

```dart
// Example using Provider:
class CounterModel extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // Rebuilds listening widgets!
  }
}
```

💡 **Pro Tip**: Use `Consumer<T>` to only rebuild the exact sub-tree that depends on the data!
''';
    } else if (lower.contains('widget') || lower.contains('stateless') || lower.contains('stateful')) {
      responseText = '''
### Flutter Widget Hierarchy & Architecture 📱

In Flutter, **everything is a widget**! Flutter builds its UI through composition rather than inheritance.

- **StatelessWidget**: Immutable. It never changes its internal state once built (e.g. `Text`, `Icon`, `Container`).
- **StatefulWidget**: Mutable. It maintains an associated `State` object that survives rebuilds and triggers updates via `setState()`.

```dart
class WelcomeBanner extends StatelessWidget {
  final String userName;
  const WelcomeBanner({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Text('Welcome back, \$userName!', 
      style: Theme.of(context).textTheme.headlineSmall);
  }
}
```

Would you like to build an interactive component together?
''';
    } else if (lower.contains('roadmap') || lower.contains('career') || lower.contains('job')) {
      responseText = '''
### AI Career Strategy for Modern Developers 🎯

To become a high-demand engineer, focus on the **T-shaped skill curve**:
- **Core Foundation**: Dart language mastery, asynchronous streams (`Future`/`Stream`), and clean architecture.
- **Modern Layer**: LLM API integration (Gemini, Claude), offline caching, and responsive design.
- **Polish**: Animations (`Hero`, `AnimatedContainer`), CI/CD publishing, and unit/widget testing.

You can visit the **Roadmaps tab** in this app to generate your custom milestone path anytime!
''';
    } else {
      responseText = '''
### SkillSphere AI Assistant 💡

That's a fantastic topic to explore! Here is how we break it down:

1. **Foundational Concept**: Master the core principles first before adding complexity.
2. **Hands-On Practice**: Code small experiments right away rather than just reading.
3. **Iterative Feedback**: Test yourself with flash quizzes and interactive challenges.

> *"Continuous learning isn't about memorizing every API; it's about building a robust mental model."*

Feel free to ask me to write sample code, review concepts, or generate a customized quiz!
''';
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
      isOfflineFallback: true,
      suggestedFollowUps: suggestions,
    );
  }

  Roadmap _generateOfflineRoadmap(String targetGoal, String level, String hours) {
    return Roadmap(
      id: 'roadmap_offline_${DateTime.now().millisecondsSinceEpoch}',
      targetGoal: targetGoal,
      experienceLevel: level,
      weeklyHours: hours,
      aiRationale: 'Custom learning trajectory calibrated for $hours commitment per week at $level level.',
      steps: [
        RoadmapStep(
          id: 'step_1',
          title: 'Core Fundamentals & Architecture',
          description: 'Master language syntax, OOP principles, asynchronous programming, and clean modular structures.',
          estimatedTime: '2 weeks',
          isCompleted: true,
        ),
        RoadmapStep(
          id: 'step_2',
          title: 'UI Design Systems & Responsive Layouts',
          description: 'Implement modern component patterns, adaptive layouts, theme engines, and accessibility guidelines.',
          estimatedTime: '2 weeks',
        ),
        RoadmapStep(
          id: 'step_3',
          title: 'State Architecture & Persistence',
          description: 'Structure scalable state flows with Provider/Riverpod, local SQLite/SharedPreferences caching.',
          estimatedTime: '3 weeks',
        ),
        RoadmapStep(
          id: 'step_4',
          title: 'AI Services & Cloud Integrations',
          description: 'Connect REST endpoints, streaming LLM completions, prompt engineering, and offline resilience.',
          estimatedTime: '2 weeks',
        ),
        RoadmapStep(
          id: 'step_5',
          title: 'Capstone Project & Portfolio Launch',
          description: 'Build an end-to-end production application, write unit tests, and prepare documentation for resume review.',
          estimatedTime: '3 weeks',
        ),
      ],
    );
  }

  Quiz _generateOfflineQuiz(String topic, String difficulty) {
    return Quiz(
      id: 'quiz_offline_${DateTime.now().millisecondsSinceEpoch}',
      topic: topic,
      difficulty: difficulty,
      questions: [
        QuizQuestion(
          id: 'q1',
          question: 'What is the primary role of the "BuildContext" in Flutter?',
          options: [
            'It stores global app databases',
            'It handles device hardware permissions directly',
            'It represents a handle to the location of a widget in the widget tree',
            'It compiles Dart code into native ARM machine code'
          ],
          correctOptionIndex: 2,
          explanation: 'BuildContext provides contextual access to the widget tree, allowing widgets to look up themes, media queries, and ancestor providers.',
        ),
        QuizQuestion(
          id: 'q2',
          question: 'Which widget should be used to make a child scrollable when content overflows?',
          options: [
            'SingleChildScrollView',
            'Expanded',
            'SizedBox',
            'Align'
          ],
          correctOptionIndex: 0,
          explanation: 'SingleChildScrollView wraps a single box and allows it to scroll when its content exceeds the screen bounds.',
        ),
        QuizQuestion(
          id: 'q3',
          question: 'What method is called to trigger a widget rebuild in a StatefulWidget?',
          options: [
            'updateWidget()',
            'setState()',
            'notifyListeners()',
            'render()'
          ],
          correctOptionIndex: 1,
          explanation: 'setState() notifies the Flutter framework that the internal state has changed, scheduling a rebuild of the widget subtree.',
        ),
        QuizQuestion(
          id: 'q4',
          question: 'How does Gemini API streaming or REST responses enhance mobile app UX?',
          options: [
            'By replacing the mobile operating system',
            'By enabling dynamic, personalized learning content and real-time guidance',
            'By increasing APK file size',
            'By disabling network encryption'
          ],
          correctOptionIndex: 1,
          explanation: 'Integrating LLMs like Gemini enables personalized student feedback, adaptive quiz generation, and natural language explanations.',
        ),
      ],
    );
  }

  List<String> _generateFollowUpSuggestions(String userPrompt) {
    return [
      'Can you explain this with a diagram or code?',
      'What are common pitfalls to avoid?',
      'How does this relate to real-world projects?',
    ];
  }

  // 4. Mock Interview Answer Evaluation
  Future<InterviewEvaluation> evaluateInterviewAnswer({
    required InterviewQuestion question,
    required String candidateAnswer,
  }) async {
    final apiKey = await _getApiKey();

    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_defaultModel:generateContent?key=$apiKey',
        );

        final promptText = '''
You are a Senior Engineering Hiring Manager at a top tech company interviewing a candidate for a mobile developer role.
Interview Question: "${question.question}"
Candidate's Answer: "$candidateAnswer"

Evaluate the candidate's response. Return ONLY valid JSON in this exact structure:
{
  "technicalScore": 8, // Integer 1-10
  "clarityScore": 7, // Integer 1-10
  "hiringDecision": "Hire", // "Strong Hire", "Hire", "Lean Hire", or "No Hire"
  "strengths": "What the candidate answered correctly",
  "weaknesses": "What concepts were missed or poorly articulated",
  "improvedAnswer": "A concise model answer the candidate should give in a real interview"
}
Do NOT wrap in markdown fences. Return pure JSON.
''';

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'role': 'user',
                'parts': [{'text': promptText}]
              }
            ]
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          var text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
          text = text.replaceAll('```json', '').replaceAll('```', '').trim();
          final parsed = jsonDecode(text);

          return InterviewEvaluation(
            technicalScore: (parsed['technicalScore'] as num?)?.toInt() ?? 7,
            clarityScore: (parsed['clarityScore'] as num?)?.toInt() ?? 7,
            hiringDecision: parsed['hiringDecision'] ?? 'Hire',
            strengths: parsed['strengths'] ?? 'Demonstrated good basic familiarity with the topic.',
            weaknesses: parsed['weaknesses'] ?? 'Could provide more concrete architectural details.',
            improvedAnswer: parsed['improvedAnswer'] ?? question.idealAnswerSummary,
          );
        }
      } catch (e) {
        // Fallback to offline evaluation engine
      }
    }

    return _generateOfflineInterviewEvaluation(question, candidateAnswer);
  }

  InterviewEvaluation _generateOfflineInterviewEvaluation(InterviewQuestion question, String answer) {
    final wordCount = answer.trim().split(RegExp(r'\s+')).length;
    final lower = answer.toLowerCase();

    // Check how many key talking points are mentioned
    int hits = 0;
    for (final point in question.keyTalkingPoints) {
      if (lower.contains(point.toLowerCase())) {
        hits++;
      }
    }

    int techScore = 6;
    int clarityScore = 6;
    String decision = 'Lean Hire';

    if (wordCount > 30 && hits >= 2) {
      techScore = 9;
      clarityScore = 9;
      decision = 'Strong Hire';
    } else if (wordCount > 15 || hits >= 1) {
      techScore = 7;
      clarityScore = 8;
      decision = 'Hire';
    } else {
      techScore = 5;
      clarityScore = 5;
      decision = 'Needs Work';
    }

    return InterviewEvaluation(
      technicalScore: techScore,
      clarityScore: clarityScore,
      hiringDecision: decision,
      strengths: hits > 0
          ? 'Addressed fundamental concepts including key terminology.'
          : 'Attempted the question with clear intent.',
      weaknesses: hits < question.keyTalkingPoints.length
          ? 'Missed mentioning crucial industry points like: ${question.keyTalkingPoints.join(", ")}.'
          : 'Could structure the response using the STAR (Situation, Task, Action, Result) method.',
      improvedAnswer: question.idealAnswerSummary,
    );
  }
}

