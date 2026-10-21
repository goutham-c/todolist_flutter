import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_in_one_productivity/core/services/storage_service.dart';
import 'package:all_in_one_productivity/core/app_scope.dart';
import 'package:all_in_one_productivity/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OmniFocusApp smoke test renders navigation and dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();

    final controller = AppController(storageService: storageService);

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const OmniFocusApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app title and main navigation tabs render
    expect(find.text('OmniFocus'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('FlipCards'), findsOneWidget);
  });
}
