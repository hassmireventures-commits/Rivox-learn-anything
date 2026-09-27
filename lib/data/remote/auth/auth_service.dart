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

  bool get isReady => Firebase.apps.isNotEmpty;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleSignInInitialized = true;
  }

  /// Returns the Firebase user already stored on this device, or restores the
  /// last Google account without showing the account picker. Returns null
  /// when Firebase is not ready yet, or when nobody has signed in on this
  /// install.
  Future<User?> restoreSession() async {
    if (Firebase.apps.isEmpty) return null;
    final existing = _auth.currentUser;
    if (existing != null) return existing;
    try {
      await _ensureGoogleSignInInitialized();
      final pending = GoogleSignIn.instance.attemptLightweightAuthentication();
      if (pending == null) return null;
      final account = await pending;
      if (account == null) return null;
      return _firebaseUserFor(account);
    } catch (_) {
      return _auth.currentUser;
    }
  }

  /// Signs in with Google and exchanges the resulting ID token for a Firebase
  /// user. Reuses a session already stored on this device before showing the
  /// account picker. Returns null if Firebase isn't configured or the user
  /// cancels the sheet; rethrows for any other failure so the caller can
  /// show an error.
  Future<User?> signInWithGoogle() async {
    if (Firebase.apps.isEmpty) return null;
    final restored = await restoreSession();
    if (restored != null) return restored;
    await _ensureGoogleSignInInitialized();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    return _firebaseUserFor(account);
  }

  Future<User?> _firebaseUserFor(GoogleSignInAccount account) async {
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  /// Signs in with an existing email/password account. Returns null if
  /// Firebase isn't configured; rethrows [FirebaseAuthException] (e.g.
  /// wrong-password, user-not-found) so the caller can show a message.
  Future<User?> signInWithEmail(String email, String password) async {
    if (Firebase.apps.isEmpty) return null;
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  /// Creates a new email/password account. Optionally sets [displayName]
  /// (username) on the Firebase user. Returns null if Firebase isn't
  /// configured; rethrows [FirebaseAuthException] (e.g. email-already-in-use,
  /// weak-password) so the caller can show a message.
  Future<User?> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    if (Firebase.apps.isEmpty) return null;
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    final name = displayName?.trim();
    if (user != null && name != null && name.isNotEmpty) {
      await user.updateDisplayName(name);
      await user.reload();
      return _auth.currentUser ?? user;
    }
    return user;
  }

  /// Sends a password reset email. Silently no-ops if Firebase isn't
  /// configured; rethrows [FirebaseAuthException] (e.g. user-not-found)
  /// so the caller can show a message.
  Future<void> sendPasswordResetEmail(String email) async {
    if (Firebase.apps.isEmpty) return;
    await _auth.sendPasswordResetEmail(email: email.trim());
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
