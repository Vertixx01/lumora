import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'store/settings_provider.dart';
import 'store/session_provider.dart';
import 'store/config_provider.dart';
import 'components/branded_loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/webview_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
      ],
      child: const LumoraApp(),
    ),
  );
}

class LumoraApp extends StatelessWidget {
  const LumoraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumora',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (!settings.isInitialized) {
            return const BrandedLoadingScreen(
              message: 'Setting up your calm space',
            );
          }
          return settings.hasCompletedOnboarding
              ? const HomeScreen()
              : const OnboardingScreen();
        },
      ),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/instagram': (context) => const WebViewScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
