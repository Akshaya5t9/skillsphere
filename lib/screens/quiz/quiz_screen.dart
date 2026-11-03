import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/constants/app_colors.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  void _showTopicPicker(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final topics = [
      'Flutter & Mobile Architecture',
      'Generative AI & LLMs',
      'State Management & Provider',
      'Dart 3 Asynchronous Streams',
      'UI/UX Design Systems',
      'Cloud DevOps & Microservices',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Adaptive Quiz Topic',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...topics.map((t) => ListTile(
                  leading: const Icon(Icons.bolt, color: AppColors.primaryLight),
                  title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {
                    Navigator.pop(ctx);
                    quizProvider.startNewQuiz(topic: t, difficulty: 'Intermediate');
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quiz = quizProvider.activeQuiz;
    final question = quizProvider.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart AI Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Change Topic',
            onPressed: () => _showTopicPicker(context),
          ),
        ],
      ),
      body: quizProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating personalized quiz questions with Gemini...'),
                ],
              ),
            )
          : quiz == null
              ? const Center(child: Text('No quiz active.'))
              : quizProvider.isSubmitted && !quizProvider.isReviewMode
                  ? _buildResultView(context, quizProvider, userProvider, isDark)
                  : _buildActiveQuizView(context, quizProvider, question, isDark),
    );
  }

  Widget _buildActiveQuizView(
    BuildContext context,
    QuizProvider quizProvider,
    dynamic question,
    bool isDark,
  ) {
    if (question == null) return const SizedBox.shrink();

    final total = quizProvider.activeQuiz!.questions.length;
    final current = quizProvider.currentQuestionIndex + 1;
    final secondsLeft = quizProvider.remainingSeconds;

    Color timerColor = AppColors.accent;
    if (secondsLeft <= 10 && secondsLeft > 5) {
      timerColor = AppColors.warning;
    } else if (secondsLeft <= 5) {
      timerColor = AppColors.danger;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info & Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  quizProvider.activeQuiz!.topic,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!quizProvider.isReviewMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: timerColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: timerColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, color: timerColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${secondsLeft}s',
                        style: TextStyle(
                          color: timerColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Review Mode', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current of $total',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              Text(
                'Domain: ${question.skillDomain}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: current / total,
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 18),

          // Question Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: AppColors.glassShadow(isDark),
            ),
            child: Text(
              question.question,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Options List
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (ctx, optIndex) {
                final isSelected = question.userSelectedIndex == optIndex;
                final isAnswered = question.isAnswered || quizProvider.isReviewMode;
                final isCorrect = optIndex == question.correctOptionIndex;

                Color borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
                Color bgColor = isDark ? AppColors.surfaceDark : Colors.white;

                if (isAnswered) {
                  if (isSelected && isCorrect) {
                    borderColor = AppColors.accent;
                    bgColor = AppColors.accent.withValues(alpha: 0.12);
                  } else if (isSelected && !isCorrect) {
                    borderColor = AppColors.danger;
                    bgColor = AppColors.danger.withValues(alpha: 0.12);
                  } else if (isCorrect) {
                    borderColor = AppColors.accent;
                    bgColor = AppColors.accent.withValues(alpha: 0.08);
                  }
                } else if (isSelected) {
                  borderColor = AppColors.primary;
                  bgColor = AppColors.primary.withValues(alpha: 0.1);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderColor, width: 1.5),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onTap: isAnswered ? null : () => quizProvider.selectOption(optIndex),
                      leading: CircleAvatar(
                        radius: 15,
                        backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
                        child: Text(
                          String.fromCharCode(65 + optIndex),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                      title: Text(
                        question.options[optIndex],
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                      ),
                      trailing: isAnswered && isCorrect
                          ? const Icon(Icons.check_circle, color: AppColors.accent)
                          : (isAnswered && isSelected && !isCorrect
                              ? const Icon(Icons.cancel, color: AppColors.danger)
                              : null),
                    ),
                  ),
                );
              },
            ),
          ),

          // AI Explanation Card if Answered
          if (question.isAnswered || quizProvider.isReviewMode)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (question.isCorrect ? AppColors.accent : AppColors.warning).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (question.isCorrect ? AppColors.accent : AppColors.warning).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    question.isCorrect ? Icons.lightbulb : Icons.info_outline,
                    color: question.isCorrect ? AppColors.accent : AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.isCorrect ? 'Correct! AI Key Insight:' : 'Review AI Explanation:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: question.isCorrect ? AppColors.accent : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.explanation,
                          style: const TextStyle(fontSize: 12.5, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Next / Submit Button
          Row(
            children: [
              if (quizProvider.isReviewMode)
                OutlinedButton(
                  onPressed: quizProvider.exitReviewMode,
                  child: const Text('Back to Scorecard'),
                ),
              if (quizProvider.isReviewMode) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: question.isAnswered || quizProvider.isReviewMode
                      ? () => quizProvider.nextQuestion()
                      : null,
                  child: Text(
                    quizProvider.isReviewMode
                        ? (current == total ? 'Finished Review' : 'Next Question')
                        : (current == total ? 'Submit Quiz' : 'Next Question'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(
    BuildContext context,
    QuizProvider quizProvider,
    UserProvider userProvider,
    bool isDark,
  ) {
    final quiz = quizProvider.activeQuiz!;
    final score = quiz.score;
    final total = quiz.questions.length;
    final percentage = quiz.percentage.toInt();
    final domainMap = quizProvider.getDomainBreakdown();

    // Reward XP once submitted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider.incrementQuizzes();
    });

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  gradient: AppColors.aiGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 18),
              const Text(
                'Quiz Completed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'You scored $score out of $total questions correctly ($percentage%)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: AppColors.accent, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '+50 XP Earned • Streak Preserved 🔥',
                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Domain Mastery Breakdown Card
        const Text(
          'Competency & Domain Breakdown',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: domainMap.entries.map((entry) {
              final pct = entry.value / 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('${entry.value.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          pct >= 0.7 ? AppColors.accent : (pct >= 0.4 ? AppColors.warning : AppColors.danger),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Review Questions button & New Quiz
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: quizProvider.enterReviewMode,
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Review Answers'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showTopicPicker(context),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('New Quiz Topic'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
