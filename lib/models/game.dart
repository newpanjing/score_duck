import 'package:uuid/uuid.dart';
import 'player.dart';
import 'round.dart';



class Game {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Player> players;
  final List<Round> rounds;

  Game({
    String? id,
    required this.name,
    DateTime? createdAt,
    required this.players,
    List<Round>? rounds,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        rounds = rounds ?? [];

  // Derived state: Total scores for each player
  Map<String, int> get totalScores {
    final totals = {for (var p in players) p.id: 0};
    for (var round in rounds) {
      for (var entry in round.scores.entries) {
        if (totals.containsKey(entry.key)) {
          totals[entry.key] = totals[entry.key]! + entry.value;
        }
      }
    }
    return totals;
  }

  void addRound(Round round) {
    rounds.add(round);
  }

  // Basic Serialization
   Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'players': players.map((p) => p.toJson()).toList(),
        'rounds': rounds.map((r) => r.toJson()).toList(),
      };

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      name: json['name'] ?? '未命名比赛',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      players: (json['players'] as List? ?? [])
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      rounds: (json['rounds'] as List? ?? [])
          .map((e) => Round.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
