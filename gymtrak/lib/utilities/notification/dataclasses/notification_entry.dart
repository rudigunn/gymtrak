class NotificationEntry {
  final int? id;
  final String displayedDate;
  final String message;
  final DateTime timestamp;

  NotificationEntry({
    this.id,
    required this.displayedDate,
    required this.message,
    required this.timestamp,
  });
}
