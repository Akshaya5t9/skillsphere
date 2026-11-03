import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseProvider extends ChangeNotifier {
  List<Course> _courses = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  CourseProvider() {
    _initCourses();
  }

  List<Course> get courses => _courses;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<String> get categories => ['All', 'AI & ML', 'Mobile', 'Frontend', 'Cloud', 'Data'];

  List<Course> get filteredCourses {
    return _courses.where((course) {
      final matchesCategory = _selectedCategory == 'All' || course.category == _selectedCategory;
      final matchesQuery = course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.skillsCovered.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesQuery;
    }).toList();
  }

  List<Course> get inProgressCourses {
    return _courses.where((c) => c.completedLessons > 0 && c.completedLessons < c.totalLessons).toList();
  }

  Course? get featuredCourse {
    return _courses.isNotEmpty ? _courses.first : null;
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleLessonCompletion(String courseId, String lessonId) {
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex == -1) return;

    final course = _courses[courseIndex];
    final updatedLessons = course.lessons.map((lesson) {
      if (lesson.id == lessonId) {
        return lesson.copyWith(isCompleted: !lesson.isCompleted);
      }
      return lesson;
    }).toList();

    final completedCount = updatedLessons.where((l) => l.isCompleted).length;

    _courses[courseIndex] = course.copyWith(
      completedLessons: completedCount,
      lessons: updatedLessons,
    );
    notifyListeners();
  }

  void markLessonCompleted(String courseId, String lessonId) {
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex == -1) return;

    final course = _courses[courseIndex];
    final updatedLessons = course.lessons.map((lesson) {
      if (lesson.id == lessonId) {
        return lesson.copyWith(isCompleted: true);
      }
      return lesson;
    }).toList();

    final completedCount = updatedLessons.where((l) => l.isCompleted).length;

    _courses[courseIndex] = course.copyWith(
      completedLessons: completedCount,
      lessons: updatedLessons,
    );
    notifyListeners();
  }

  void _initCourses() {
    _courses = [
      Course(
        id: 'c1',
        title: 'Flutter & Dart: Zero to Hero',
        category: 'Mobile',
        level: 'Beginner',
        rating: 4.9,
        instructor: 'Alex Rivera • Senior Flutter Architect',
        totalLessons: 6,
        completedLessons: 3,
        description: 'Master cross-platform mobile development with Flutter, Dart 3, state management, and modern UI architectures.',
        iconName: 'flutter',
        skillsCovered: ['Dart 3', 'Flutter', 'Provider', 'Widgets', 'Material 3'],
        lessons: [
          Lesson(
            id: 'l1',
            title: 'Introduction to Dart & Flutter SDK',
            duration: '15 min',
            summary: 'Understand the Flutter rendering engine, Skia/Impeller, and Dart JIT vs AOT compilation.',
            keyTakeaways: [
              'Flutter compiles natively to ARM machine code using Dart AOT.',
              'The widget tree is rebuilt cheaply; only updated RenderObjects are repainted.',
              'Dart 3 introduces sealed classes, pattern matching, and records.',
            ],
            codeSnippet: '''void main() {
  final greeting = getWelcomeMessage(user: 'Developer', isNew: true);
  print(greeting);
}

String getWelcomeMessage({required String user, bool isNew = false}) =>
  switch (isNew) {
    true  => 'Welcome aboard, \$user! Let\\'s build with Flutter.',
    false => 'Welcome back, \$user! Ready to code?',
  };''',
            contentMarkdown: '''### What is Flutter?

Flutter is Google’s open-source portable UI toolkit designed to craft natively compiled applications for mobile, web, and desktop from a single codebase.

#### Key Architectural Layers:
1. **Dart Framework**: High-level widgets, animations, gestures, and material/cupertino styling.
2. **Flutter Engine (C++)**: Text layout (HarfBuzz), rendering pipeline (Impeller / Skia), and Dart runtime.
3. **Embedder**: Platform-specific entry point (Android Java/Kotlin, iOS Obj-C/Swift, Web JS/Wasm).
''',
            isCompleted: true,
          ),
          Lesson(
            id: 'l2',
            title: 'Widgets, Layouts, and Responsive Design',
            duration: '25 min',
            summary: 'Learn composition, LayoutBuilder, MediaQuery, Flex layouts, and constraints.',
            keyTakeaways: [
              'Constraints go down. Sizes go up. Parent sets position.',
              'Use Flexible and Expanded to distribute space dynamically.',
              'MediaQuery provides screen dimensions and safe area insets.',
            ],
            codeSnippet: '''class ResponsiveCard extends StatelessWidget {
  const ResponsiveCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: const [
            Expanded(child: Text('Left Column')),
            Expanded(child: Text('Right Column')),
          ],
        );
      },
    );
  }
}''',
            contentMarkdown: '''### The Golden Rule of Flutter Layouts

> **"Constraints go down. Sizes go up. Parent sets position."**

- **Parent widget** passes constraints (min/max width and height) to its child.
- **Child widget** decides its own size within those constraints.
- **Parent widget** positions the child accordingly.

Always use `LayoutBuilder` when you need widgets to adapt to their parent container rather than the entire device screen!
''',
            isCompleted: true,
          ),
          Lesson(
            id: 'l3',
            title: 'State Management with Provider & ChangeNotifier',
            duration: '30 min',
            summary: 'Decouple business logic from UI widgets with clean reactive state management.',
            keyTakeaways: [
              'ChangeNotifier triggers rebuilds only on listening consumers.',
              'Context.watch() triggers rebuilds; context.read() is for one-time method calls.',
              'Keep business logic testable outside the widget tree.',
            ],
            codeSnippet: '''class CounterProvider extends ChangeNotifier {
  int _counter = 0;
  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }
}

// In your Widget:
// Read without rebuilding:
ElevatedButton(
  onPressed: () => context.read<CounterProvider>().increment(),
  child: const Text('Add'),
);''',
            contentMarkdown: '''### Modern State Architecture

Separating UI presentation from application state is essential for maintainable, production-grade Flutter apps.

#### Why Provider?
- **Lightweight**: Built on top of `InheritedWidget`.
- **Testable**: Your `ChangeNotifier` classes can be unit tested without pumping Flutter widgets.
- **Granular Rebuilds**: Using `Consumer<T>` prevents unnecessary rebuilds of parent widgets.
''',
            isCompleted: true,
          ),
          Lesson(
            id: 'l4',
            title: 'REST API Integration and JSON Parsing',
            duration: '35 min',
            summary: 'Handle network requests, timeouts, error status codes, and type-safe JSON serialization.',
            keyTakeaways: [
              'Use http package with custom timeouts and error handlers.',
              'Parse JSON into strongly-typed model classes.',
              'Always handle offline states gracefully.',
            ],
            codeSnippet: '''Future<List<User>> fetchUsers() async {
  final response = await http.get(
    Uri.parse('https://api.example.com/users'),
    headers: {'Accept': 'application/json'},
  ).timeout(const Duration(seconds: 10));

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => User.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load users: \${response.statusCode}');
  }
}''',
            contentMarkdown: '''### Production Networking Best Practices

1. **Timeout Safety**: Always attach `.timeout()` to avoid hanging network connections on poor networks.
2. **DTO Separation**: Map API JSON directly to Data Transfer Objects (DTOs) before updating state.
3. **Offline Caching**: Store results locally with `SharedPreferences` or `Hive` to ensure instant load times.
''',
            isCompleted: false,
          ),
          Lesson(
            id: 'l5',
            title: 'Connecting Google Gemini AI in Flutter',
            duration: '40 min',
            summary: 'Integrate Gemini 1.5 Flash REST endpoints, handle structured outputs, and stream responses.',
            keyTakeaways: [
              'Gemini 1.5 Flash provides sub-second latency for interactive mobile chatbots.',
              'Enforce structured JSON output using system instructions.',
              'Implement local fallback handlers when device is offline.',
            ],
            codeSnippet: '''final url = Uri.parse(
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\$apiKey'
);

final response = await http.post(
  url,
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'contents': [
      {'role': 'user', 'parts': [{'text': userPrompt}]}
    ]
  }),
);''',
            contentMarkdown: '''### Bringing AI to Mobile Apps

Adding Generative AI transforms standard apps into intelligent co-pilots.
With Gemini 1.5 Flash, mobile clients can:
- Generate instant study flashcards and roadmaps.
- Offer personalized tutor feedback.
- Summarize documents and articles on device.
''',
            isCompleted: false,
          ),
          Lesson(
            id: 'l6',
            title: 'Publishing & CI/CD Deployment',
            duration: '45 min',
            summary: 'App signing, automated GitHub Actions, Play Console, and App Store Connect.',
            keyTakeaways: [
              'Generate keystore for Android release builds.',
              'Use Fastlane or GitHub Actions for continuous delivery.',
              'Configure app icons and splash screens natively.',
            ],
            codeSnippet: '''# Build an optimized release bundle:
flutter build appbundle --release --obfuscate --split-debug-info=./debug_symbols

# Build for Web:
flutter build web --release --wasm''',
            contentMarkdown: '''### Production Release Checklist

Before submitting to app stores:
1. Enable code obfuscation (`--obfuscate`) to protect proprietary Dart logic.
2. Ensure network security configurations allow only HTTPS.
3. Verify accessibility with screen readers (`Semantics` widget).
''',
            isCompleted: false,
          ),
        ],
      ),
      Course(
        id: 'c2',
        title: 'Generative AI & LLM Engineering',
        category: 'AI & ML',
        level: 'Intermediate',
        rating: 4.95,
        instructor: 'Dr. Sarah Chen • AI Research Director',
        totalLessons: 5,
        completedLessons: 2,
        description: 'Harness the power of Google Gemini, prompt engineering, embeddings, and multimodal models inside real-world apps.',
        iconName: 'psychology',
        skillsCovered: ['Gemini API', 'Prompt Design', 'Embeddings', 'RAG', 'Multimodal'],
        lessons: [
          Lesson(
            id: 'l21',
            title: 'Foundations of Modern LLMs & Attention',
            duration: '20 min',
            summary: 'Self-attention, transformers, context windows, and token prediction mechanics.',
            keyTakeaways: [
              'Transformers process sequence tokens in parallel via attention matrices.',
              'Temperature controls entropy: lower = deterministic, higher = creative.',
            ],
            codeSnippet: '''// Token estimation rule of thumb:
// 1 token ≈ 4 characters or 0.75 words in English.
int estimateTokens(String text) => (text.length / 4).ceil();''',
            contentMarkdown: '''### The Transformer Revolution

Understanding how tokens are converted into vector embeddings and processed through multi-head attention is the cornerstone of LLM development.
''',
            isCompleted: true,
          ),
          Lesson(
            id: 'l22',
            title: 'Mastering System Prompts & Few-Shot Templates',
            duration: '25 min',
            summary: 'Craft reliable system constraints, zero-shot, few-shot examples, and chain-of-thought.',
            keyTakeaways: [
              'System instructions define the AI persona, output constraints, and tone.',
              'Few-shot examples drastically reduce hallucinations.',
            ],
            codeSnippet: '''const systemInstruction = """
You are a senior code reviewer. 
Review the user's code for:
1. Performance bottlenecks
2. Security vulnerabilities
3. Style consistency
Always provide concrete refactored snippets.
""";''',
            contentMarkdown: '''### Effective Prompt Engineering

Prompt engineering is not guesswork; it is specification design. When instructing models like Gemini 1.5, explicit constraints produce dramatically higher reliability.
''',
            isCompleted: true,
          ),
          Lesson(
            id: 'l23',
            title: 'Calling Gemini REST APIs in Flutter',
            duration: '35 min',
            summary: 'Connect endpoints, parse candidate parts, handle rate limits, and stream tokens.',
            keyTakeaways: [
              'Use the v1beta generateContent endpoint with your API key.',
              'Parse content parts safely.',
            ],
            codeSnippet: '''// Clean parsing of candidate response:
final candidate = json['candidates']?[0];
final text = candidate?['content']?['parts']?[0]?['text'] ?? '';''',
            contentMarkdown: '''### Real-time API Integration

Learn how to communicate with Gemini endpoints directly without heavy SDK overhead.
''',
            isCompleted: false,
          ),
          Lesson(
            id: 'l24',
            title: 'Structured JSON Outputs and Function Calling',
            duration: '30 min',
            summary: 'Force the model to return valid typed JSON schemas for direct parsing into Dart models.',
            keyTakeaways: [
              'Instruct the LLM to output pure JSON matching a target schema.',
              'Sanitize markdown fences before running jsonDecode.',
            ],
            codeSnippet: '''String sanitizeJson(String raw) {
  return raw
      .replaceAll('```json', '')
      .replaceAll('```', '')
      .trim();
}''',
            contentMarkdown: '''### Reliability with Structured Output

Build resilient mobile UIs powered by LLMs by enforcing strict JSON output schemas.
''',
            isCompleted: false,
          ),
          Lesson(
            id: 'l25',
            title: 'Retrieval Augmented Generation (RAG)',
            duration: '45 min',
            summary: 'Vector databases, text embeddings, and injecting custom knowledge into prompts.',
            keyTakeaways: [
              'RAG eliminates hallucinations by grounding answers in factual source documents.',
              'Embeddings represent semantic similarity as geometric proximity.',
            ],
            codeSnippet: '''// Cosine similarity computation:
double cosineSimilarity(List<double> v1, List<double> v2) {
  double dot = 0.0, normA = 0.0, normB = 0.0;
  for (int i = 0; i < v1.length; i++) {
    dot += v1[i] * v2[i];
    normA += v1[i] * v1[i];
    normB += v2[i] * v2[i];
  }
  return dot / (sqrt(normA) * sqrt(normB));
}''',
            contentMarkdown: '''### Vector Grounding & RAG

RAG allows your app to answer queries using private user documents or proprietary domain manuals.
''',
            isCompleted: false,
          ),
        ],
      ),
      Course(
        id: 'c3',
        title: 'Modern UI/UX Design for Mobile Apps',
        category: 'Frontend',
        level: 'Beginner',
        rating: 4.8,
        instructor: 'Elena Rostova • Design Systems Lead',
        totalLessons: 4,
        completedLessons: 0,
        description: 'Learn wireframing, color theory, typography, micro-interactions, and design systems for mobile experiences.',
        iconName: 'palette',
        skillsCovered: ['Figma', 'Design Systems', 'Micro-interactions', 'Accessibility'],
        lessons: [
          Lesson(
            id: 'l31',
            title: 'Principles of Modern Visual Hierarchy',
            duration: '20 min',
            summary: 'Size, contrast, spacing, and focal points.',
            keyTakeaways: ['Whitespace is a core design element, not empty space.'],
            contentMarkdown: 'Master visual balance and screen hierarchy.',
          ),
          Lesson(
            id: 'l32',
            title: 'Color Theory & Glassmorphic Shadows',
            duration: '25 min',
            summary: 'Creating high-contrast palettes that look gorgeous in dark mode.',
            keyTakeaways: ['Use 60-30-10 color ratio for visual stability.'],
            contentMarkdown: 'Color science for modern screens.',
          ),
          Lesson(
            id: 'l33',
            title: 'Micro-interactions & Tactile Feedback',
            duration: '25 min',
            summary: 'Delightful button springs, animated cards, and haptic cues.',
            keyTakeaways: ['Micro-interactions communicate status and reward user actions.'],
            contentMarkdown: 'Elevate ordinary interfaces with motion physics.',
          ),
          Lesson(
            id: 'l34',
            title: 'Translating Figma Tokens into Flutter Code',
            duration: '30 min',
            summary: 'Export styles, font scales, and spacing directly into Flutter ThemeData.',
            keyTakeaways: ['Centralize design tokens to enable rapid global theme updates.'],
            contentMarkdown: 'Bridging design and production code.',
          ),
        ],
      ),
      Course(
        id: 'c4',
        title: 'Cloud Architecture & Microservices',
        category: 'Cloud',
        level: 'Advanced',
        rating: 4.85,
        instructor: 'Marcus Vance • Cloud Solutions Architect',
        totalLessons: 4,
        completedLessons: 0,
        description: 'Architect resilient backend services with Docker, Kubernetes, Serverless functions, and distributed databases.',
        iconName: 'cloud',
        skillsCovered: ['Docker', 'Kubernetes', 'Cloud Functions', 'PostgreSQL'],
        lessons: [
          Lesson(
            id: 'l41',
            title: 'Containerization Fundamentals with Docker',
            duration: '30 min',
            summary: 'Write production Dockerfiles, multi-stage builds, and lean images.',
            keyTakeaways: ['Multi-stage builds reduce image footprints by over 80%.'],
            contentMarkdown: 'Containers from dev to prod.',
          ),
          Lesson(
            id: 'l42',
            title: 'Microservice Communication: REST vs gRPC',
            duration: '35 min',
            summary: 'Protocol buffers, streaming RPCs, and low-latency payload serialization.',
            keyTakeaways: ['gRPC is up to 7x faster than JSON REST for internal service calls.'],
            contentMarkdown: 'Optimizing inter-service pipelines.',
          ),
          Lesson(
            id: 'l43',
            title: 'Deploying on Google Cloud Run',
            duration: '40 min',
            summary: 'Serverless container deployment with auto-scaling to zero.',
            keyTakeaways: ['Scale to zero minimizes idle cloud costs.'],
            contentMarkdown: 'Serverless cloud hosting.',
          ),
          Lesson(
            id: 'l44',
            title: 'Event-Driven Architectures with Pub/Sub',
            duration: '45 min',
            summary: 'Decoupled asynchronous processing and guaranteed message delivery.',
            keyTakeaways: ['Event-driven systems prevent cascading service failures.'],
            contentMarkdown: 'Building resilient asynchronous event streams.',
          ),
        ],
      ),
    ];
  }
}
