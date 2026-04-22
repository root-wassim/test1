class AppDateUtils {
  static String twoDigits(int value) => value.toString().padLeft(2, '0');

  static String minutesToHourMinuteLabel(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${twoDigits(m)}m';
  }
}
