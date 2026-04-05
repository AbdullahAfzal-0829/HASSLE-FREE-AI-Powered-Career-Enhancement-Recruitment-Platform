import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('App starting...');
  runApp(const MyApp());
  
  // Initialize Google Sign-In in the background to prevent blocking UI start
  _initGoogleSignIn();
}

Future<void> _initGoogleSignIn() async {
  try {
    debugPrint('Initializing Google Sign-In...');
    // Only await if you absolutely need it before the first screen, 
    // but here it's safer to not block the main function.
    await GoogleSignIn.instance.initialize();
    debugPrint('Google Sign-In initialization completed.');
  } catch (e) {
    debugPrint('Google Sign-In initialization failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HASSLE-FREE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter', // Inter is a standard system font or fallbacks naturally
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
