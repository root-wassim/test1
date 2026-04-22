class Validators {
  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required / $label est obligatoire';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, 'Email');
    if (required != null) return required;
    final regExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regExp.hasMatch(value!.trim())) {
      return 'Invalid email / E-mail invalide';
    }
    return null;
  }

  static String? password(String? value) {
    final required = requiredField(value, 'Password');
    if (required != null) return required;
    if (value!.length < 6) {
      return 'Minimum 6 characters / Minimum 6 caractères';
    }
    return null;
  }

  static String? minimumAge13(DateTime? birthDate) {
    if (birthDate == null) {
      return 'Date of birth is required / Date de naissance obligatoire';
    }
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hasNotHadBirthday =
        now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day);
    if (hasNotHadBirthday) {
      age--;
    }
    if (age < 13) {
      return 'Age must be 13+ / Âge minimum 13 ans';
    }
    return null;
  }
}
