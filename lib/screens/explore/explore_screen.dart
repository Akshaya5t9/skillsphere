import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/course_card.dart';
import '../course/lesson_player_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  void _openCoursePlayer(BuildContext context, dynamic course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonPlayerScreen(
          course: course,
          initialLessonIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = courseProvider.filteredCourses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Courses'),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: courseProvider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search skills, topics, courses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: courseProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => courseProvider.setSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),

          // Category Chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: courseProvider.categories.length,
              itemBuilder: (ctx, i) {
                final category = courseProvider.categories[i];
                final isSelected = courseProvider.selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(category),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                    ),
                    onSelected: (_) => courseProvider.setCategory(category),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Course List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 56,
                          color: isDark ? Colors.white38 : Colors.black26,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No courses found matching your search.',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final course = filtered[i];
                      return CourseCard(
                        course: course,
                        onTap: () => _openCoursePlayer(context, course),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
