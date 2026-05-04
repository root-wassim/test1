class AppUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        uid: m['uid'] ?? '',
        email: m['email'] ?? '',
        firstName: m['firstName'] ?? '',
        lastName: m['lastName'] ?? '',
        birthDate: DateTime.parse(m['birthDate'] ?? DateTime.now().toIso8601String()),
        createdAt: DateTime.parse(m['createdAt'] ?? DateTime.now().toIso8601String()),
      );
}
