import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/interview_provider.dart';
import '../../core/constants/app_colors.dart';

class InterviewReportScreen extends StatelessWidget {
  const InterviewReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InterviewProvider>(context);
    final session = provider.activeSession;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (session == null) {
      return const Scaffold(body: Center(child: Text('No session data found.')));
    }

    final score = session.averageScore.round();
    final verdict = session.finalVerdict;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Performance Report'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Verdict Hero Card
          Container(
            padding: const EdgeInsets.all(24),
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
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF3730A3) : const Color(0xFFC7D2FE),
              ),
              boxShadow: AppColors.glassShadow(isDark),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: AppColors.aiGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  verdict,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Target Role: ${session.targetRole}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Overall Technical Score: $score / 100',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Question-by-Question Breakdown
          const Text(
            'Question-by-Question Evaluation',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...session.questions.map((q) {
            final ev = session.evaluations[q.id];
            if (ev == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          q.category,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                        ),
                      ),
                      Text(
                        'Score: ${ev.overallScore}% (${ev.hiringDecision})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ev.overallScore >= 70 ? AppColors.accent : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    q.question,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Feedback: ${ev.strengths} ${ev.weaknesses}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                provider.startNewSession(role: 'Junior Full-Stack Flutter Developer');
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Start New Mock Interview Round'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
