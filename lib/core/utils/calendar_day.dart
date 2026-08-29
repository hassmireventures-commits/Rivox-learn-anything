/// Local calendar day key for daily quiz / daily pack rollover.
String calendarDayKey([DateTime? dt]) {
  final d = dt ?? DateTime.now();
  return '${d.year}-${d.month}-${d.day}';
}
