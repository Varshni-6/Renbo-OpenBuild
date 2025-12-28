import 'dart:convert';

class TimeCapsule {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime deliveryDate;
  bool isOpened;

  TimeCapsule({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.deliveryDate,
    this.isOpened = false,
  });

  /// A helper to check if the message is ready to be read.
  /// If the current time is after the delivery date, it's "unlocked."
  bool get isReady => DateTime.now().isAfter(deliveryDate);

  /// Calculates the remaining time for the UI countdown.
  Duration get timeRemaining => deliveryDate.difference(DateTime.now());

  /// Converts the object into a Map (useful for local SQLite or NoSQL storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'isOpened': isOpened ? 1 : 0, // SQLite often uses 1/0 for booleans
    };
  }

  /// Creates a TimeCapsule object from a Map (reading from storage)
  factory TimeCapsule.fromMap(Map<String, dynamic> map) {
    return TimeCapsule(
      id: map['id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      deliveryDate: DateTime.parse(map['deliveryDate'] as String),
      isOpened: map['isOpened'] == 1,
    );
  }

  /// Facilitates JSON encoding for SharedPreferences
  String toJson() => json.encode(toMap());

  /// Facilitates JSON decoding
  factory TimeCapsule.fromJson(String source) =>
      TimeCapsule.fromMap(json.decode(source) as Map<String, dynamic>);
}
