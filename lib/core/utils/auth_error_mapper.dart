import 'package:firebase_auth/firebase_auth.dart';

String mapAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Adresse e-mail invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Identifiants invalides. Vérifiez votre e-mail et mot de passe.';
      case 'email-already-in-use':
        return 'Cette adresse e-mail est déjà utilisée.';
      case 'weak-password':
        return 'Mot de passe trop faible. Utilisez au moins 6 caractères.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez dans quelques minutes.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion internet.';
      case 'sign_in_canceled':
      case 'web-context-cancelled':
      case 'web-context-canceled':
        return 'Connexion annulée.';
      case 'account-exists-with-different-credential':
        return 'Ce compte existe déjà avec une autre méthode de connexion.';
      default:
        // Catch certificate hash and SHA errors specifically
        final msg = (error.message ?? '').toLowerCase();
        if (msg.contains('certificate') || msg.contains('sha') || msg.contains('hash')) {
          return 'Configuration Google incomplète. L\'empreinte SHA-1 de votre application doit être ajoutée dans les paramètres du projet Firebase.';
        }
        return 'Erreur d\'authentification. Veuillez réessayer.';
    }
  }
  // Catch google sign-in and general errors
  final raw = error.toString().toLowerCase();
  if (raw.contains('sign_in_canceled') || raw.contains('cancelled')) {
    return 'Connexion Google annulée.';
  }
  if (raw.contains('certificate') || raw.contains('sha') || raw.contains('hash')) {
    return 'Configuration Google incomplète. L\'empreinte SHA-1 de votre application doit être ajoutée dans les paramètres du projet Firebase.';
  }
  return 'Une erreur est survenue. Veuillez réessayer.';
}
