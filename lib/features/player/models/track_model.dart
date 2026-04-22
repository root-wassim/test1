class TrackModel {
  TrackModel({
    required this.title,
    required this.audioUrl,
    this.surahNumber = 0,
  });

  final String title;
  final String audioUrl;
  final int surahNumber;

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      title: (json['name'] ?? json['surah_name_ar'] ?? json['surah_name'] ?? 'Track').toString(),
      audioUrl: (json['url'] ?? json['audio_url'] ?? '').toString(),
      surahNumber: int.tryParse('${json['surah_number'] ?? json['surah_id'] ?? 0}') ?? 0,
    );
  }
}
