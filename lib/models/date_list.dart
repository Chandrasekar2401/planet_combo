class DateItem {
  final String userId;
  final int hid;
  final String requestId;
  final double seq;
  final DateTime date;

  DateItem({
    required this.userId,
    required this.hid,
    required this.requestId,
    required this.seq,
    required this.date,
  });

  factory DateItem.fromJson(Map<String, dynamic> json) {
    return DateItem(
      userId: json['userId'],
      hid: json['hid'],
      requestId: json['requestId'],
      seq: json['seq'],
      date: DateTime.parse(json['date']),
    );
  }
}