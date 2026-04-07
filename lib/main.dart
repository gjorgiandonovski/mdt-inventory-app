import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'services/local_api_service.dart' as api;
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

const _mdtPurple = Color(0xFF702673);
const _mdtSurface = Color(0xFFF7F5F7);
const _mdtText = Color(0xFF1C1C1E);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _mdtPurple,
      brightness: Brightness.light,
      surface: Colors.white,
      primary: _mdtPurple,
      onPrimary: Colors.white,
      onSurface: _mdtText,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(),
        ),
        ProxyProvider<AuthProvider, api.ApiService>(
          update: (_, auth, __) => api.ApiService(auth),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: _mdtSurface,
          fontFamily: 'SF Pro Display',
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: _mdtText,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0.5,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          listTileTheme: const ListTileThemeData(
            iconColor: _mdtPurple,
            textColor: _mdtText,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _mdtPurple.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _mdtPurple.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _mdtPurple, width: 1.5),
            ),
            labelStyle: const TextStyle(color: _mdtText),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: _mdtPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: _mdtPurple,
              side: BorderSide(color: _mdtPurple.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: _mdtPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          chipTheme: ChipThemeData(
            side: BorderSide(color: _mdtPurple.withValues(alpha: 0.15)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: const TextStyle(color: _mdtText),
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        home: Root(),
      ),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return auth.user == null
        ? const LoginScreen()
        : const HomeScreen();
  }
}
