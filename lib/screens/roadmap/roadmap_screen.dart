import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/roadmap_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/ai_badge.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final _goalController = TextEditingController(text: 'Full-Stack Flutter & AI Engineer');
  String _selectedLevel = 'Intermediate';
  String _selectedHours = '10-15 hrs/week';

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _showGenerateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 24,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Skill Tree Generator',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    AiBadge(),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Target Role / Career Specialization:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _goalController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Senior Flutter Developer, AI App Engineer...',
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Experience Level:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLevel,
                  items: ['Beginner', 'Intermediate', 'Advanced'].map((lvl) {
                    return DropdownMenuItem(value: lvl, child: Text(lvl));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => _selectedLevel = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text('Weekly Commitment:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedHours,
                  items: ['5-8 hrs/week', '10-15 hrs/week', '20+ hrs/week'].map((hrs) {
                    return DropdownMenuItem(value: hrs, child: Text(hrs));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => _selectedHours = val);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Provider.of<RoadmapProvider>(context, listen: false).generateNewRoadmap(
                        goal: _goalController.text.trim(),
                        level: _selectedLevel,
                        hours: _selectedHours,
                      );
                    },
                    child: const Text('Generate Custom Skill Tree'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roadmapProvider = Provider.of<RoadmapProvider>(context);
    final roadmap = roadmapProvider.currentRoadmap;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Career Skill Trees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart),
            tooltip: 'Generate Custom Path',
            onPressed: () => _showGenerateModal(context),
          ),
        ],
      ),
      body: roadmapProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Architecting your Duolingo-style skill tree with Gemini...'),
                ],
              ),
            )
          : roadmap == null
              ? Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showGenerateModal(context),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Create My First Career Roadmap'),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  children: [
                    // Career Compensation & Market Demand Card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3730A3) : const Color(0xFFC7D2FE),
                        ),
                        boxShadow: AppColors.glassShadow(isDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AiBadge(label: 'Verified Career Pathway'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(roadmap.progressPercentage * 100).toInt()}% Mastered',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            roadmap.targetGoal,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.payments_outlined, size: 16, color: AppColors.gold),
                              const SizedBox(width: 6),
                              Text(
                                roadmap.salaryRange,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gold),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.trending_up, size: 16, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  roadmap.marketDemand,
                                  style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: roadmap.progressPercentage,
                              minHeight: 8,
                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            roadmap.aiRationale,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Skill Tree Nodes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Duolingo-style Connected Nodes
                    ...List.generate(roadmap.steps.length, (index) {
                      final step = roadmap.steps[index];
                      final isLast = index == roadmap.steps.length - 1;
                      final isCurrentActive = !step.isCompleted && (index == 0 || roadmap.steps[index - 1].isCompleted);

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Node Circle & Connecting Line
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => roadmapProvider.toggleStep(step.id),
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: step.isCompleted
                                        ? AppColors.emeraldGradient
                                        : (isCurrentActive ? AppColors.aiGradient : null),
                                    color: step.isCompleted
                                        ? null
                                        : (isDark ? AppColors.surfaceDark : Colors.white),
                                    border: Border.all(
                                      color: step.isCompleted
                                          ? Colors.transparent
                                          : (isCurrentActive ? AppColors.primary : AppColors.borderDark),
                                      width: isCurrentActive ? 3 : 1.5,
                                    ),
                                    boxShadow: isCurrentActive
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.5),
                                              blurRadius: 14,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    step.isCompleted
                                        ? Icons.check_circle
                                        : (isCurrentActive ? Icons.lock_open : Icons.lock_outline),
                                    size: 22,
                                    color: (step.isCompleted || isCurrentActive) ? Colors.white : Colors.grey,
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 3,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    color: step.isCompleted
                                        ? AppColors.accent
                                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Right Node Details
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isCurrentActive
                                      ? AppColors.primaryLight
                                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                  width: isCurrentActive ? 1.5 : 1,
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
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          step.categoryTag.toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.primaryLight,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        step.estimatedTime,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    step.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                                      color: step.isCompleted ? Colors.grey : null,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    step.description,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => roadmapProvider.toggleStep(step.id),
                                        icon: Icon(
                                          step.isCompleted ? Icons.undo : Icons.check,
                                          size: 14,
                                        ),
                                        label: Text(step.isCompleted ? 'Reset' : 'Complete Node'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          textStyle: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
    );
  }
}
