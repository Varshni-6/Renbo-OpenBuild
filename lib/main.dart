import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'utils/theme.dart';
import 'providers/mood_provider.dart';
import 'providers/capsule_provider.dart'; // From friend's code
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_page.dart';
import 'screens/home_screen.dart';

// Import these to ensure the init methods exist if needed for legacy data
import 'services/journal_storage.dart';
import 'services/gratitude_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  // 2. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Keep Hive initialized for transition or local settings
  await Hive.initFlutter();

  // Only keep these if you are still running the migration script
  // to move old data to Firestore.
  await JournalStorage.init();
  await GratitudeStorage.init();

  runApp(
    // 4. Use MultiProvider to include your friend's CapsuleProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MoodProvider()),
        ChangeNotifierProvider(create: (context) => CapsuleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renbo',
      // This uses AppTheme.lightTheme which ensures your friend's
      // Coffee + Sage color scheme is applied
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/auth_check': (context) => const AuthCheck(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const AuthPage(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // If logged in, navigate to Home
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // Otherwise, go to Login/Auth Page
        return const AuthPage();
      },
    );
  }
}
