import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper around Firebase Auth + Google Sign-In for B13 cloud backup
/// (Phase 1: auth + opt-in plumbing only — no backup/restore yet).
///
/// Every method guards on [Firebase.apps.isEmpty] and fails gracefully
/// instead of crashing, mirroring `AnonAnalyticsSync`'s existing style —
/// Firebase init is optional/non-blocking (see `app_bootstrap.dart`), so
/// auth must never assume it is available.
///
/// Targets the current `google_sign_in` major (7.x), which replaced the old
/// synchronous `GoogleSignIn()` constructor + `.signIn()` API with an async
/// `GoogleSignIn.instance.initialize()` singleton followed by `.authenticate()`.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth}) : _authOverride = firebaseAuth;

  final FirebaseAuth? _authOverride;
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  bool _googleSignInInitialized = false;

  Stream<User?> get authStateChanges {
    if (Firebase.apps.isEmpty) return const Stream<User?>.empty();
    return _auth.authStateChanges();
  }

  User? get currentUser {
    if (Firebase.apps.isEmpty) return null;
    return _auth.currentUser;
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleSignInInitialized = true;
  }

  /// Signs in with Google and exchanges the resulting ID token for a Firebase
  /// user. Returns null if Firebase isn't configured or the user cancels the
  /// Google sign-in sheet; rethrows for any other failure so the caller can
  /// show an error.
  Future<User?> signInWithGoogle() async {
    if (Firebase.apps.isEmpty) return null;
    await _ensureGoogleSignInInitialized();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<void> signOut() async {
    if (Firebase.apps.isEmpty) return;
    await _auth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Best-effort; the Firebase sign-out above is authoritative.
    }
  }
}
