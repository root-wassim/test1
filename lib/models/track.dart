class Track {
  final String id;
  final String title;       // English name e.g. "Al-Fatiha"
  final String arabicTitle; // Arabic name e.g. "الفاتحة"
  final String category;    // e.g. "Quran"
  final String reciter;     // e.g. "Mishary Rashid Alafasy"
  final String audioUrl;
  final String? imageUrl;
  final int? duration;
  final int? surahNumber;

  const Track({
    required this.id,
    required this.title,
    this.arabicTitle = '',
    required this.category,
    this.reciter = 'Mishary Rashid Alafasy',
    required this.audioUrl,
    this.imageUrl,
    this.duration,
    this.surahNumber,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'arabicTitle': arabicTitle,
    'category': category,
    'reciter': reciter,
    'audioUrl': audioUrl,
    'imageUrl': imageUrl,
    'duration': duration,
    'surahNumber': surahNumber,
  };

  factory Track.fromMap(Map<String, dynamic> m) => Track(
    id: m['id'] ?? '',
    title: m['title'] ?? '',
    arabicTitle: m['arabicTitle'] ?? '',
    category: m['category'] ?? '',
    reciter: m['reciter'] ?? 'Mishary Rashid Alafasy',
    audioUrl: m['audioUrl'] ?? '',
    imageUrl: m['imageUrl'],
    duration: m['duration'],
    surahNumber: m['surahNumber'],
  );

  @override
  bool operator ==(Object other) => other is Track && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class Category {
  final String id;
  final String name;
  final String? imageUrl;
  final List<Track> tracks;

  const Category({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.tracks,
  });
}