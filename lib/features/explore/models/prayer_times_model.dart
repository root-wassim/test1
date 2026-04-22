class PrayerTimesModel {
  PrayerTimesModel({
    required this.region,
    required this.country,
    required this.times,
    required this.dateEn,
    required this.dateHijri,
    required this.hijriMonth,
    required this.hijriYear,
  });

  final String region;
  final String country;
  final Map<String, String> times; // {Fajr: "04:27", Sunrise: "06:09", ...}
  final String dateEn;
  final String dateHijri;
  final String hijriMonth;
  final String hijriYear;

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final prayerTimes = json['prayer_times'] as Map<String, dynamic>? ?? {};
    final dateData = json['date'] as Map<String, dynamic>? ?? {};
    final hijri = dateData['date_hijri'] as Map<String, dynamic>? ?? {};
    final hijriMonthData = hijri['month'] as Map<String, dynamic>? ?? {};

    return PrayerTimesModel(
      region: (json['region'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      times: prayerTimes.map((k, v) => MapEntry(k, v.toString())),
      dateEn: (dateData['date_en'] ?? '').toString(),
      dateHijri: (hijri['date'] ?? '').toString(),
      hijriMonth: (hijriMonthData['ar'] ?? '').toString(),
      hijriYear: (hijri['year'] ?? '').toString(),
    );
  }
}
