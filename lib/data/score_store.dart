import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';
import '../models/round.dart';

class ScoreNotifier extends AsyncNotifier<List<Game>> {
  static const _fileName = 'games.json';

  @override
  Future<List<Game>> build() async {
    return  _loadGames();
  }

  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<List<Game>> _loadGames() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isEmpty) return [];
        final List<dynamic> jsonList = json.decode(content);
        return jsonList.map((e) => Game.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error loading games: $e');
    }
    return [];
  }

  Future<void> _saveGames() async {
    try {
      final file = await _file;
      final jsonList = state.value?.map((g) => g.toJson()).toList() ?? [];
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving games: $e');
    }
  }

  Future<void> addGame(Game game) async {
    state = AsyncValue.data([game, ...state.value ?? []]);
    await _saveGames();
  }

  Future<void> deleteGame(String id) async {
    state = AsyncValue.data(state.value?.where((g) => g.id != id).toList() ?? []);
    await _saveGames();
  }

  Future<void> addRoundToGame(String gameId, Round round) async {
    final currentGames = state.value ?? [];
    state = AsyncValue.data([
      for (final game in currentGames)
        if (game.id == gameId)
          Game(
            id: game.id,
            name: game.name,
            type: game.type,
            createdAt: game.createdAt,
            players: game.players,
            rounds: [...game.rounds, round],
          )
        else
          game
    ]);
    await _saveGames();
  }

  Future<void> updateRoundInGame(String gameId, Round updatedRound) async {
    final currentGames = state.value ?? [];
    state = AsyncValue.data([
      for (final game in currentGames)
        if (game.id == gameId)
          Game(
            id: game.id,
            name: game.name,
            type: game.type,
            createdAt: game.createdAt,
            players: game.players,
            rounds: [
              for (final round in game.rounds)
                if (round.id == updatedRound.id) updatedRound else round
            ],
          )
        else
          game
    ]);
    await _saveGames();
  }

  Future<void> clearAll() async {
    state = const AsyncValue.data([]);
    await _saveGames();
  }
}

final scoreProvider =
    AsyncNotifierProvider<ScoreNotifier, List<Game>>(ScoreNotifier.new);



// Manage base scores for all games in a Map

class BaseScoresNotifier extends Notifier<Map<String, int>> {
  static const _key = 'base_scores';
  bool _isInitialized = false;

  @override
  Map<String, int> build() {
    if (!_isInitialized) {
      _isInitialized = true;
      _loadBaseScores();
    }
    return {};
  }

  Future<void> _loadBaseScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_key);
      if (encoded != null) {
        final Map<String, dynamic> decoded = json.decode(encoded);
        state = decoded.map((key, value) => MapEntry(key, value as int));
      }
    } catch (e) {
      debugPrint('Error loading base scores: $e');
    }
  }

  Future<void> _saveBaseScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, json.encode(state));
    } catch (e) {
      debugPrint('Error saving base scores: $e');
    }
  }

  void setScore(String gameId, int score) {
    state = {...state, gameId: score};
    _saveBaseScores();
  }

  void increment(String gameId) {
    final current = state[gameId] ?? 1;
    state = {...state, gameId: current + 1};
    _saveBaseScores();
  }

  void decrement(String gameId) {
    final current = state[gameId] ?? 1;
    if (current > 1) {
      state = {...state, gameId: current - 1};
      _saveBaseScores();
    }
  }
}



final baseScoresProvider =

    NotifierProvider<BaseScoresNotifier, Map<String, int>>(BaseScoresNotifier.new);


