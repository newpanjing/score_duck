import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/game_controller.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../models/round.dart';
import 'common_widgets.dart';

class AddRoundSheet extends StatefulWidget {
  final Game game;
  final Round? initialRound;

  const AddRoundSheet({super.key, required this.game, this.initialRound});

  @override
  State<AddRoundSheet> createState() => AddRoundSheetState();
}

class AddRoundSheetState extends State<AddRoundSheet> {
  late Map<String, int> _currentScores;
  late Map<String, TextEditingController> _playerControllers;

  @override
  void initState() {
    super.initState();
    _currentScores = widget.initialRound != null
        ? Map<String, int>.from(widget.initialRound!.scores)
        : {for (var p in widget.game.players) p.id: 0};

    _playerControllers = {};
    for (var p in widget.game.players) {
      final score = _currentScores[p.id] ?? 0;
      _playerControllers[p.id] = TextEditingController(
        text: score > 0 ? '+$score' : '$score',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _playerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveRound() {
    final gameController = Get.find<GameController>();
    if (widget.initialRound != null) {
      final updatedRound = Round(
        id: widget.initialRound!.id,
        timestamp: widget.initialRound!.timestamp,
        scores: _currentScores,
      );
      gameController.updateRoundInGame(widget.game.id, updatedRound);
    } else {
      final round = Round(scores: _currentScores);
      gameController.addRoundToGame(widget.game.id, round);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final baseScores = gameController.baseScores;
    final int baseScore = baseScores[widget.game.id] ?? 1;
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark ||
        (CupertinoTheme.of(context).brightness == null && systemBrightness == Brightness.dark);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHeader(widget.initialRound != null),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildBaseScoreSection(baseScore, isDark),
                const SizedBox(height: 24),
                ...widget.game.players.map((p) => _buildPlayerInput(p, baseScore, isDark)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            child: Text('common_cancel'.tr),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            isEditing ? 'game_detail_edit_round'.tr : 'game_detail_add_round'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          CupertinoButton(
            onPressed: _saveRound,
            child: Text('common_done'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseScoreSection(int baseScore, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('game_detail_base_score'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('game_detail_step_size'.tr,
                  style: const TextStyle(fontSize: 11, color: CupertinoColors.systemGrey2)),
            ],
          ),
          ScoreStepper(
            value: baseScore,
            onChanged: (val) {
              if (val > 0) {
                Get.find<GameController>().setBaseScore(widget.game.id, val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInput(Player player, int baseScore, bool isDark) {
    final score = _currentScores[player.id] ?? 0;
    final controller = _playerControllers[player.id]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ScoreStepper(
            value: score,
            step: baseScore,
            isScore: true,
            onChanged: (val) {
              setState(() {
                _currentScores[player.id] = val;
                controller.text = val > 0 ? '+$val' : '$val';
              });
            },
          ),
        ],
      ),
    );
  }
}
