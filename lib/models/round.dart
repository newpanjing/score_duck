import 'package:uuid/uuid.dart';

class Round {
  final String id;
  final DateTime timestamp;
  final Map<String, int> scores; // playerId -> score change

  Round({
    String? id,
    DateTime? timestamp,
    required this.scores,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'scores': scores,
      };

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      scores: Map<String, int>.from(json['scores']),
    );
  }
}
