class SurahModel {
  SurahModel({
    required this.id,
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.type,
    required this.ayatCount,
  });

  final int id;
  final int number;
  final String nameAr;
  final String nameEn;
  final String type; // "Meccan" or "Medinan"
  final int ayatCount;

  bool get isMeccan => type == 'Meccan';

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      number: int.tryParse('${json['number'] ?? 0}') ?? 0,
      nameAr: (json['name_ar'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      type: (json['type'] ?? 'Meccan').toString(),
      ayatCount: int.tryParse('${json['ayat_count'] ?? 0}') ?? 0,
    );
  }
}
