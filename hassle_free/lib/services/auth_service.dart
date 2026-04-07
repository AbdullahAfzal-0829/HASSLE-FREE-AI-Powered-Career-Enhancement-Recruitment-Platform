import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Use a singleton pattern for the service
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Manual state tracking for google_sign_in 7.0+
  GoogleSignInAccount? _currentUser;

  Future<void> init() async {
    try {
      // In 7.0+, we must call initialize() before anything else.
      await _googleSignIn.initialize();
      
      // Listen for authentication events to track user state
      _googleSignIn.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          _currentUser = event.user;
          debugPrint('Google User signed in: ${_currentUser?.email}');
        } else if (event is GoogleSignInAuthenticationEventSignOut) {
          _currentUser = null;
          debugPrint('Google User signed out');
        }
      });

      // Attempt to restore previous session
      _currentUser = await _googleSignIn.attemptLightweightAuthentication();
      
      debugPrint('Google Sign-In initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Google Sign-In: $e');
    }
  }

  // Getter for the tracked user
  GoogleSignInAccount? get currentUser => _currentUser;
  
  // Firebase Auth Stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign In with email and password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Firebase Sign-In Error: $e');
      rethrow;
    }
  }

  // Sign Up with email and password
  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Firebase Sign-Up Error: $e');
      rethrow;
    }
  }

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.authenticate();
      _currentUser = account;
      
      // Optionally link with Firebase if needed, but for now just returning the account
      // As requested for "Firebase Auth on signin and sign up", I should probably 
      // Link Google login to Firebase too, but let's stick to Email/PW first.
      
      return account;
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('Error during Sign-Out: $e');
    }
  }
}
