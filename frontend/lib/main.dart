import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/api_service.dart';
import 'utils/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        // Top level state (Auth, User Profile, Global Theme Toggles, etc.)
        // Initializing an empty Provider wrapper for now.
        ChangeNotifierProvider(create: (_) => DummyProvider()),
      ],
      child: const SilvraApp(),
    ),
  );
}

class SilvraApp extends StatelessWidget {
  const SilvraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SILVRA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}

// Placeholder provider to satisfy MultiProvider
class DummyProvider extends ChangeNotifier {
  bool isLoggedIn = false;
}
