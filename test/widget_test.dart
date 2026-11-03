import 'package:flutter_test/flutter_test.dart';
import 'package:skillsphere_ai/main.dart';

void main() {
  testWidgets('SkillSphere app launches and renders main nav smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SkillSphereApp());
    // Verify floating dock nav labels appear
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Tree'), findsOneWidget);
    expect(find.text('Quizzes'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
