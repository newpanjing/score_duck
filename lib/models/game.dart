import 'package:uuid/uuid.dart';
import 'player.dart';
import 'round.dart';

enum GameType {
  generic,
  poker,
  mahjong,
}

extension GameTypeExtension on GameType {
  String get label {
    switch (this) {
      case GameType.generic:
        return '通用计分';
      case GameType.poker:
        return '扑克';
      case GameType.mahjong:
        return '麻将';
    }
  }
}

class Game {
  final String id;
  final String name;
  final GameType type;
  final DateTime createdAt;
  final List<Player> players;
  final List<Round> rounds;

  Game({
    String? id,
    required this.name,
    required this.type,
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
        'type': type.index,
        'createdAt': createdAt.toIso8601String(),
        'players': players.map((p) => p.toJson()).toList(),
        'rounds': rounds.map((r) => r.toJson()).toList(),
      };

  factory Game.fromJson(Map<String, dynamic> json) {
    final typeIndex = json['type'] as int? ?? 0;
    return Game(
      id: json['id'],
      name: json['name'] ?? '未命名比赛',
      type: typeIndex < GameType.values.length 
          ? GameType.values[typeIndex] 
          : GameType.generic,
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
