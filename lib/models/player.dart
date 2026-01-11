import 'package:uuid/uuid.dart';

class Player {
  final String id;
  final String name;

  Player({
    String? id,
    required this.name,
  }) : id = id ?? const Uuid().v4();

  // For later serialization if needed
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
    );
  }
}
