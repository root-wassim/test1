import '../models/user_model.dart';

// Auth service — mock implementation with Firebase-ready error mapping.
// When wiring real Firebase, replace the mock bodies with:
//   try { await FirebaseAuth.instance.signInWithEmailAndPassword(...); }
//   on FirebaseAuthException catch (e) { return _mapFirebaseError(e.code); }
class AuthService {
  static AppUser? _currentUser;

  static AppUser? get currentUser => _currentUser;

  static Future<AppUser?> getAppUser() async {
    return _currentUser;
  }

  // ─── Firebase error code → human-friendly message ───────────────────────
  static String _mapFirebaseError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in instead.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'requires-recent-login':
        return 'Please log out and log back in to continue.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // ─── Register ────────────────────────────────────────────────────────────
  static Future<String?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    // Local validations (kept from original)
    final age = DateTime.now().year - birthDate.year;
    if (age < 13) return 'You must be at least 13 years old';

    // -- Replace block below with real Firebase call --
    // try {
    //   final cred = await FirebaseAuth.instance
    //       .createUserWithEmailAndPassword(email: email, password: password);
    //   await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({...});
    // } on FirebaseAuthException catch (e) {
    //   return _mapFirebaseError(e.code);
    // }
    _currentUser = AppUser(
      uid: 'mock_uid_123',
      email: email,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      createdAt: DateTime.now(),
    );
    return null;
  }

  // ─── Login ───────────────────────────────────────────────────────────────
  static Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return 'Please fill in all fields';

    // -- Replace block below with real Firebase call --
    // try {
    //   await FirebaseAuth.instance
    //       .signInWithEmailAndPassword(email: email, password: password);
    // } on FirebaseAuthException catch (e) {
    //   return _mapFirebaseError(e.code);
    // }
    _currentUser = AppUser(
      uid: 'mock_uid_123',
      email: email,
      firstName: 'Mohamed',
      lastName: 'User',
      birthDate: DateTime(2000, 1, 1),
      createdAt: DateTime.now(),
    );
    return null;
  }

  // ─── Reset password ──────────────────────────────────────────────────────
  static Future<String?> resetPassword(String email) async {
    if (email.isEmpty) return 'Please enter your email';

    // -- Replace block below with real Firebase call --
    // try {
    //   await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    // } on FirebaseAuthException catch (e) {
    //   return _mapFirebaseError(e.code);
    // }
    return null;
  }

  // ─── Logout ──────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    _currentUser = null;
    // await FirebaseAuth.instance.signOut();
  }
}
