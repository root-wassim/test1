import '../models/user_model.dart';

// Mock auth service - no Firebase needed
class AuthService {
  static AppUser? _currentUser;

  static AppUser? get currentUser => _currentUser;

  static Future<AppUser?> getAppUser() async {
    return _currentUser;
  }

  static Future<String?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    final age = DateTime.now().year - birthDate.year;
    if (age < 13) return 'You must be at least 13 years old';
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

  static Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return 'Please fill in all fields';
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

  static Future<String?> resetPassword(String email) async {
    if (email.isEmpty) return 'Please enter your email';
    return null;
  }

  static Future<void> logout() async {
    _currentUser = null;
  }
}
