import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'providers/user_provider.dart';
import 'providers/course_provider.dart';
import 'providers/roadmap_provider.dart';
import 'providers/ai_tutor_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/interview_provider.dart';
import 'screens/main_nav_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkillSphereApp());
}

class SkillSphereApp extends StatelessWidget {
  const SkillSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => RoadmapProvider()),
        ChangeNotifierProvider(create: (_) => AiTutorProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => InterviewProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            title: 'SkillSphere AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: userProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainNavScreen(),
          );
        },
      ),
    );
  }
}
