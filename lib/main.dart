import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/pet_intro_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  final loggedIn = await storage.isLoggedIn();
  final hasPet = await storage.loadPet() != null;
  final isDark = await storage.loadIsDarkTheme();
  themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  final Widget start = !loggedIn
      ? const LoginScreen()
      : hasPet
      ? const HomeScreen()
      : const PetIntroScreen();

  runApp(PetCareApp(home: start));
}

class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) => MaterialApp(
        title: 'Pet Care',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        home: home,
      ),
    );
  }
}
