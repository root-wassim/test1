import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricResult {
  const BiometricResult({required this.ok, this.message});

  final bool ok;
  final String? message;
}

class BiometricService {
  BiometricService(this._localAuth);

  final LocalAuthentication _localAuth;

  String _friendlyMessageFromCode(String code) {
    switch (code) {
      case 'notAvailable':
      case 'NotAvailable':
        return 'Votre téléphone ne supporte pas l’empreinte digitale.';
      case 'notEnrolled':
      case 'NotEnrolled':
        return 'Aucune empreinte n’est enregistrée. Ajoutez une empreinte dans les paramètres.';
      case 'passcodeNotSet':
      case 'PasscodeNotSet':
        return 'Aucun mot de passe configuré sur l\'appareil.';
      case 'lockedOut':
      case 'LockedOut':
        return 'Trop de tentatives. Déverrouillez le téléphone puis réessayez.';
      case 'permanentlyLockedOut':
      case 'PermanentlyLockedOut':
        return 'La vérification biométrique est bloquée de façon permanente. Utilisez votre code.';
      default:
        return 'Impossible d’utiliser l’empreinte maintenant. Réessayez.';
    }
  }

  Future<BiometricResult> authenticate() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      final enrolled = await _localAuth.getAvailableBiometrics();
      if (!canCheck || !supported) {
        return const BiometricResult(
          ok: false,
          message: 'La biométrie n’est pas disponible sur cet appareil.',
        );
      }
      if (enrolled.isEmpty) {
        return const BiometricResult(
          ok: false,
          message: 'Aucune empreinte configurée. Ouvrez les paramètres pour l’ajouter.',
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to continue / Authentifiez-vous pour continuer',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (authenticated) {
        await SystemSound.play(SystemSoundType.click);
      }
      return BiometricResult(
        ok: authenticated,
        message: authenticated ? null : 'Empreinte non reconnue ou action annulée. Réessayez.',
      );
    } on PlatformException catch (e) {
      return BiometricResult(ok: false, message: _friendlyMessageFromCode(e.code));
    } catch (e) {
      return const BiometricResult(
        ok: false,
        message: 'Un problème est survenu. Veuillez réessayer.',
      );
    }
  }
}
