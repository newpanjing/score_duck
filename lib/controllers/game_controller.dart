import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';
import '../models/round.dart';

class GameController extends GetxController {
  static const _fileName = 'games.json';
  static const _baseScoresKey = 'base_scores';
  static const _privacyPolicyKey = 'has_seen_privacy_policy';
  static GameController get to => Get.find();

  final RxList<Game> _games = <Game>[].obs;
  List<Game> get games => _games.toList();

  final RxMap<String, int> _baseScores = <String, int>{}.obs;
  Map<String, int> get baseScores => Map<String, int>.from(_baseScores);

  @override
  void onInit() {
    super.onInit();
    _loadGames();
    _loadBaseScores();
  }

  Future<bool> shouldShowPrivacyPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_privacyPolicyKey) ?? false);
  }

  Future<void> markPrivacyPolicyAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyPolicyKey, true);
  }

  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> _loadGames() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isEmpty) {
          _games.clear();
          return;
        }
        final List<dynamic> jsonList = json.decode(content);
        _games.assignAll(jsonList.map((e) => Game.fromJson(e as Map<String, dynamic>)).toList());
      }
    } catch (e) {
      debugPrint('Error loading games: $e');
    }
  }

  Future<void> _saveGames() async {
    try {
      final file = await _file;
      final jsonList = _games.map((g) => g.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving games: $e');
    }
  }

  Future<void> addGame(Game game) async {
    _games.insert(0, game);
    await _saveGames();
  }

  Future<void> deleteGame(String id) async {
    _games.removeWhere((g) => g.id == id);
    await _saveGames();
  }

  Future<void> addRoundToGame(String gameId, Round round) async {
    final updatedGames = _games.map((game) {
      if (game.id == gameId) {
        return Game(
          id: game.id,
          name: game.name,
          createdAt: game.createdAt,
          players: game.players,
          rounds: [...game.rounds, round],
        );
      }
      return game;
    }).toList();
    _games.assignAll(updatedGames);
    await _saveGames();
  }

  Future<void> updateRoundInGame(String gameId, Round updatedRound) async {
    final updatedGames = _games.map((game) {
      if (game.id == gameId) {
        return Game(
          id: game.id,
          name: game.name,
          createdAt: game.createdAt,
          players: game.players,
          rounds: [
            for (final round in game.rounds)
              if (round.id == updatedRound.id) updatedRound else round
          ],
        );
      }
      return game;
    }).toList();
    _games.assignAll(updatedGames);
    await _saveGames();
  }

  Future<void> clearAll() async {
    _games.clear();
    await _saveGames();
  }

  Future<void> _loadBaseScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_baseScoresKey);
      if (encoded != null) {
        final Map<String, dynamic> decoded = json.decode(encoded);
        _baseScores.assignAll(decoded.map((key, value) => MapEntry(key, value as int)));
      }
    } catch (e) {
      debugPrint('Error loading base scores: $e');
    }
  }

  Future<void> _saveBaseScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_baseScoresKey, json.encode(_baseScores));
    } catch (e) {
      debugPrint('Error saving base scores: $e');
    }
  }

  void setBaseScore(String gameId, int score) {
    _baseScores[gameId] = score;
    _saveBaseScores();
  }

  void incrementBaseScore(String gameId) {
    final current = _baseScores[gameId] ?? 1;
    _baseScores[gameId] = current + 1;
    _saveBaseScores();
  }

  void decrementBaseScore(String gameId) {
    final current = _baseScores[gameId] ?? 1;
    if (current > 1) {
      _baseScores[gameId] = current - 1;
      _saveBaseScores();
    }
  }
}