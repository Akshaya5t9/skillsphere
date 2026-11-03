import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/ai_tutor_provider.dart';
import '../../core/constants/app_colors.dart';

class LessonPlayerScreen extends StatefulWidget {
  final Course course;
  final int initialLessonIndex;

  const LessonPlayerScreen({
    super.key,
    required this.course,
    this.initialLessonIndex = 0,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> with SingleTickerProviderStateMixin {
  late int _currentLessonIndex;
  late TabController _tabController;
  bool _isPlaying = true;
  double _videoProgress = 0.35;

  @override
  void initState() {
    super.initState();
    _currentLessonIndex = widget.initialLessonIndex;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Lesson get currentLesson => widget.course.lessons[_currentLessonIndex];

  void _markCompleted() {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    courseProvider.markLessonCompleted(widget.course.id, currentLesson.id);
    userProvider.addXp(25);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.stars, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Lesson Completed! +25 XP Earned 🔥',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    // If next lesson exists, advance
    if (_currentLessonIndex < widget.course.lessons.length - 1) {
      setState(() {
        _currentLessonIndex++;
        _videoProgress = 0.0;
      });
    } else {
      _showCertificateModal();
    }
  }

  void _showCertificateModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Course Completed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'You have mastered all modules in "${widget.course.title}".',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.gold.withValues(alpha: 0.08),
              ),
              child: Column(
                children: [
                  const Text(
                    'CERTIFICATE OF COMPLETION',
                    style: TextStyle(
                      letterSpacing: 1.5,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.course.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Issued by SkillSphere AI • Verified Credential',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Add to Profile Badges'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _askLuminaAboutLesson() {
    final aiTutor = Provider.of<AiTutorProvider>(context, listen: false);
    aiTutor.sendMessage(
      'Can you explain the key concepts from the lesson "${currentLesson.title}" in simple terms and give a real-world coding tip?',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lumina AI is preparing notes for "${currentLesson.title}"...'),
        action: SnackBarAction(
          label: 'Open AI Tutor',
          textColor: Colors.amber,
          onPressed: () {
            Navigator.pop(context); // Go back and switch tab
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lesson = currentLesson;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course.title,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Lesson',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lesson link copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Simulated Interactive Video Player Mock
          Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Video background gradient & topic watermark
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        lesson.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.course.instructor} • ${lesson.duration}',
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                // Click overlay to toggle play/pause
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _isPlaying = !_isPlaying),
                    ),
                  ),
                ),

                // Bottom player controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            activeTrackColor: AppColors.accent,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: AppColors.accent,
                          ),
                          child: Slider(
                            value: _videoProgress,
                            onChanged: (val) => setState(() => _videoProgress = val),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(_videoProgress * 15).toInt()}:00 / ${lesson.duration}',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.hd_outlined, color: Colors.white70, size: 18),
                                const SizedBox(width: 12),
                                const Icon(Icons.speed, color: Colors.white70, size: 18),
                                const SizedBox(width: 4),
                                const Text('1.0x', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                const SizedBox(width: 12),
                                const Icon(Icons.fullscreen, color: Colors.white70, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs: Content, Code Sandbox, Key Takeaways
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryLight,
              unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.menu_book, size: 18), text: 'Curriculum'),
                Tab(icon: Icon(Icons.code, size: 18), text: 'Code Sandbox'),
                Tab(icon: Icon(Icons.checklist, size: 18), text: 'Takeaways'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Markdown Content Tab
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.auto_awesome, size: 14, color: AppColors.primaryLight),
                          label: const Text('Ask Lumina', style: TextStyle(fontSize: 12, color: AppColors.primaryLight)),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                          onPressed: _askLuminaAboutLesson,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lesson.summary,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    MarkdownBody(
                      data: lesson.contentMarkdown,
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        ThemeData(
                          brightness: isDark ? Brightness.dark : Brightness.light,
                          textTheme: TextTheme(
                            bodyMedium: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),

                // 2. Code Sandbox Tab
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hands-On Code Example',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (lesson.codeSnippet != null)
                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: lesson.codeSnippet!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Snippet copied to clipboard! Paste in your editor.'),
                                  backgroundColor: AppColors.accent,
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 14),
                            label: const Text('Copy Code'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (lesson.codeSnippet != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: SelectableText(
                          lesson.codeSnippet!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Color(0xFF38BDF8),
                            height: 1.45,
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('This lesson focuses on architectural design patterns.'),
                        ),
                      ),
                  ],
                ),

                // 3. Key Takeaways Tab
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Core Competencies & Takeaways',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    ...lesson.keyTakeaways.map(
                      (takeaway) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                takeaway,
                                style: const TextStyle(fontSize: 13.5, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              children: [
                if (_currentLessonIndex > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => _currentLessonIndex--),
                    child: const Text('Previous'),
                  ),
                if (_currentLessonIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _markCompleted,
                    icon: Icon(
                      currentLesson.isCompleted ? Icons.check : Icons.stars,
                      size: 18,
                    ),
                    label: Text(
                      currentLesson.isCompleted ? 'Marked Completed (+25 XP)' : 'Complete & Continue',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentLesson.isCompleted ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
