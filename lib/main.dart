import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/app_scope.dart';
import 'features/home/views/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final controller = AppController(storageService: storageService);

  runApp(
    AppScope(
      controller: controller,
      child: const OmniFocusApp(),
    ),
  );
}

class OmniFocusApp extends StatelessWidget {
  const OmniFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'OmniFocus: All-In-One Productivity',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
