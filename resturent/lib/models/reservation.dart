class Reservation {
  final String id;
  final String userId;
  final DateTime date;
  final String time;
  final int numberOfPeople;
  final String specialRequests;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.numberOfPeople,
    this.specialRequests = '',
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'time': time,
        'numberOfPeople': numberOfPeople,
        'specialRequests': specialRequests,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
        id: json['id'],
        userId: json['userId'],
        date: DateTime.parse(json['date']),
        time: json['time'],
        numberOfPeople: json['numberOfPeople'],
        specialRequests: json['specialRequests'] ?? '',
        status: json['status'] ?? 'pending',
        createdAt: DateTime.parse(json['createdAt']),
      );
}
