import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/interview_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/ai_badge.dart';
import 'interview_report_screen.dart';

class MockInterviewScreen extends StatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _showHints = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submitAnswer(InterviewProvider provider) async {
    final text = _answerController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please articulate your response before submitting.')),
      );
      return;
    }

    await provider.submitAnswer(text);
    _answerController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final interviewProvider = Provider.of<InterviewProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final session = interviewProvider.activeSession;
    final question = interviewProvider.currentQuestion;
    final evaluation = interviewProvider.latestEvaluation;

    if (session == null || question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mock Technical Interview')),
        body: const Center(child: Text('No active interview session.')),
      );
    }

    if (session.isCompleted) {
      return const InterviewReportScreen();
    }

    final currentNum = interviewProvider.currentQuestionIndex + 1;
    final totalNum = session.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mock Interview Room'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: AppColors.primaryLight),
                const SizedBox(width: 4),
                Text('Q $currentNum of $totalNum', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryLight)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
        children: [
          // Interviewer Persona Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF151D2F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFEEF2FF), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF3730A3) : const Color(0xFFC7D2FE),
              ),
              boxShadow: AppColors.glassShadow(isDark),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    gradient: AppColors.aiGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Marcus Vance • Staff Engineer',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const AiBadge(label: 'Hiring Round'),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Target Role: ${session.targetRole}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        question.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      'Level: ${question.difficulty}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setState(() => _showHints = !_showHints),
                  child: Row(
                    children: [
                      Icon(
                        _showHints ? Icons.lightbulb : Icons.lightbulb_outline,
                        size: 16,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _showHints ? 'Hide Key Talking Points' : 'Reveal Key Talking Points (Hint)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gold),
                      ),
                    ],
                  ),
                ),
                if (_showHints) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: question.keyTalkingPoints.map((point) {
                      return Chip(
                        label: Text(point, style: const TextStyle(fontSize: 11)),
                        backgroundColor: AppColors.gold.withValues(alpha: 0.1),
                        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
                        padding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Evaluation Critique if Answered
          if (evaluation != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: (evaluation.overallScore >= 70 ? AppColors.accent : AppColors.warning).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (evaluation.overallScore >= 70 ? AppColors.accent : AppColors.warning).withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            evaluation.overallScore >= 70 ? Icons.check_circle : Icons.warning_amber_rounded,
                            color: evaluation.overallScore >= 70 ? AppColors.accent : AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Verdict: ${evaluation.hiringDecision}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: evaluation.overallScore >= 70 ? AppColors.accent : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${evaluation.overallScore} / 100',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Technical Strength:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(evaluation.strengths, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 10),
                  const Text('What to Improve:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(evaluation.weaknesses, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.stars, color: AppColors.gold, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Senior Engineer Model Answer:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.gold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          evaluation.improvedAnswer,
                          style: const TextStyle(fontSize: 12.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  userProvider.addXp(35);
                  interviewProvider.nextQuestion();
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(interviewProvider.isLastQuestion ? 'Complete Interview & View Report' : 'Next Interview Question'),
              ),
            ),
          ] else ...[
            // Candidate Input Form
            const Text(
              'Your Answer (Speak or Type as you would in an interview):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _answerController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'e.g., In Flutter, the Widget tree is an immutable configuration blueprint that gets rebuilt frequently, whereas the Element tree maintains identity and manages state...',
                fillColor: isDark ? const Color(0xFF151D2F) : Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: interviewProvider.isEvaluating ? null : () => _submitAnswer(interviewProvider),
                icon: interviewProvider.isEvaluating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  interviewProvider.isEvaluating
                      ? 'Senior Hiring Manager is Evaluating Answer...'
                      : 'Submit Answer for AI Critique',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
