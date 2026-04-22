class ListeningSession {
  ListeningSession({
    required this.trackTitle,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
  });

  final String trackTitle;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;

  Map<String, dynamic> toJson() => {
        'trackTitle': trackTitle,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
      };

  factory ListeningSession.fromJson(Map<String, dynamic> json) => ListeningSession(
        trackTitle: json['trackTitle'] as String? ?? '',
        startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ?? DateTime.now(),
        endedAt: DateTime.tryParse(json['endedAt'] as String? ?? '') ?? DateTime.now(),
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      );
}
