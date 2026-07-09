class Reservation {
  const Reservation({
    required this.title,
    required this.timeLabel,
    required this.location,
    required this.category,
    required this.note,
  });

  final String title;
  final String timeLabel;
  final String location;
  final String category;
  final String note;
}
