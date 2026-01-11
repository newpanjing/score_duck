import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/score_store.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/round.dart';

class GameDetailScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  ConsumerState<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends ConsumerState<GameDetailScreen> {
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  void _toggleOrientation() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (isPortrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _showAddRoundSheet(BuildContext context, Game game, {Round? round}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _AddRoundSheet(game: game, initialRound: round),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(scoreProvider);

    return gamesAsync.when(
      loading: () => const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (error, stack) => CupertinoPageScaffold(
        child: Center(child: Text('加载失败: $error')),
      ),
      data: (games) {
        final game = games.cast<Game?>().firstWhere(
          (g) => g?.id == widget.gameId,
          orElse: () => null,
        );

        if (game == null) {
          return const CupertinoPageScaffold(
            child: Center(child: Text('Game not found')),
          );
        }

        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              game.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            previousPageTitle: '首页',
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _toggleOrientation,
              child: Icon(
                isLandscape ? CupertinoIcons.device_phone_portrait : CupertinoIcons.device_phone_landscape,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                isLandscape
                    ? _buildLandscapeLayout(game)
                    : _buildPortraitLayout(game),
                Positioned(
                  right: 20,
                  bottom: isLandscape ? 20 : 100,
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(30),
                    onPressed: () => _showAddRoundSheet(context, game),
                    child: const Icon(CupertinoIcons.add, size: 28),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout(Game game) {
    const double columnWidth = 80.0;
    const double timeColumnWidth = 60.0;

    return Column(
      children: [
        _buildHeader(game, columnWidth, timeColumnWidth, showTotal: true),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: timeColumnWidth + (game.players.length * columnWidth) + 32,
              child: _buildRoundsList(game, timeColumnWidth, columnWidth),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(Game game) {
    const double columnWidth = 80.0;
    const double timeColumnWidth = 60.0;

    return Row(
      children: [
        SizedBox(
          width: 220,
          child: _buildLeaderboard(game),
        ),
        Expanded(
          child: Column(
            children: [
              _buildHeader(game, columnWidth, timeColumnWidth, showTotal: false),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: timeColumnWidth + (game.players.length * columnWidth) + 32,
                    child: _buildRoundsList(game, timeColumnWidth, columnWidth),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboard(Game game) {
    final totalScores = game.totalScores;
    final sortedPlayers = game.players.toList()
      ..sort((a, b) => (totalScores[b.id] ?? 0).compareTo(totalScores[a.id] ?? 0));

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '总分榜',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedPlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final score = totalScores[player.id] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.separator.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: index < 3 ? CupertinoColors.activeBlue : CupertinoColors.label,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: score >= 0 ? CupertinoColors.activeBlue : CupertinoColors.systemRed,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(Game game, double columnWidth, double timeColumnWidth, {required bool showTotal}) {
    final totalScores = game.totalScores;
    final sortedPlayers = game.players.toList()
      ..sort((a, b) => (totalScores[b.id] ?? 0).compareTo(totalScores[a.id] ?? 0));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: timeColumnWidth,
              child: const Center(
                child: Icon(
                  CupertinoIcons.time,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ...game.players.map((p) {
              final score = totalScores[p.id] ?? 0;
              final rank = sortedPlayers.indexOf(p);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: columnWidth,
                  child: Column(
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showTotal) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: score >= 0 ? CupertinoColors.activeBlue : CupertinoColors.systemRed,
                          ),
                        ),
                      ],
                      if (rank < 3 && game.rounds.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${rank + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundsList(Game game, double timeColumnWidth, double columnWidth) {
    if (game.rounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 48,
              color: CupertinoColors.systemGrey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无记录',
              style: TextStyle(
                fontSize: 17,
                color: CupertinoColors.systemGrey.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击 + 添加第一局',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: game.rounds.length,
      itemBuilder: (context, index) {
        final round = game.rounds[game.rounds.length - 1 - index];

        return GestureDetector(
          onTap: () => _showAddRoundSheet(context, game, round: round),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: CupertinoColors.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: timeColumnWidth,
                  child: Text(
                    DateFormat('HH:mm').format(round.timestamp),
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                ...game.players.map((p) {
                  final score = round.scores[p.id] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: columnWidth,
                      child: Text(
                        score > 0 ? '+$score' : '$score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: score == 0
                              ? CupertinoColors.systemGrey
                              : (score > 0 ? CupertinoColors.activeBlue : CupertinoColors.systemRed),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddRoundSheet extends ConsumerStatefulWidget {
  final Game game;
  final Round? initialRound;

  const _AddRoundSheet({required this.game, this.initialRound});

  @override
  ConsumerState<_AddRoundSheet> createState() => _AddRoundSheetState();
}

class _AddRoundSheetState extends ConsumerState<_AddRoundSheet> {
  late Map<String, int> _currentScores;
  late TextEditingController _baseScoreController;
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

    final baseScores = ref.read(baseScoresProvider);
    final int baseScore = baseScores[widget.game.id] ?? 1;
    _baseScoreController = TextEditingController(text: '$baseScore');
  }

  @override
  void dispose() {
    _baseScoreController.dispose();
    for (var controller in _playerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveRound() {
    if (widget.initialRound != null) {
      final updatedRound = Round(
        id: widget.initialRound!.id,
        timestamp: widget.initialRound!.timestamp,
        scores: _currentScores,
      );
      ref.read(scoreProvider.notifier).updateRoundInGame(widget.game.id, updatedRound);
    } else {
      final round = Round(scores: _currentScores);
      ref.read(scoreProvider.notifier).addRoundToGame(widget.game.id, round);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final baseScores = ref.watch(baseScoresProvider);
    final int baseScore = baseScores[widget.game.id] ?? 1;
    final bool isEditing = widget.initialRound != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('取消'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  isEditing ? '修改记录' : '记录本局',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CupertinoButton(
                  onPressed: _saveRound,
                  child: const Text('完成'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBaseScoreRow(baseScore),
                const SizedBox(height: 24),
                ...widget.game.players.map((p) =>
                    _buildPlayerScoreRow(p, baseScore)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseScoreRow(int baseScore) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '基础分',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(44, 44),
                onPressed: baseScore > 1
                    ? () {
                        ref.read(baseScoresProvider.notifier).decrement(widget.game.id);
                        _baseScoreController.text = '${baseScore - 1}';
                      }
                    : null,
                child: const Icon(CupertinoIcons.minus_circle, size: 28),
              ),
              SizedBox(
                width: 50,
                child: CupertinoTextField(
                  controller: _baseScoreController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  onChanged: (value) {
                    final val = int.tryParse(value);
                    if (val != null && val > 0) {
                      ref.read(baseScoresProvider.notifier).setScore(widget.game.id, val);
                    }
                  },
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(44, 44),
                onPressed: () {
                  ref.read(baseScoresProvider.notifier).increment(widget.game.id);
                  _baseScoreController.text = '${baseScore + 1}';
                },
                child: const Icon(CupertinoIcons.add_circled, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScoreRow(Player player, int baseScore) {
    final score = _currentScores[player.id] ?? 0;
    final controller = _playerControllers[player.id]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(44, 44),
            onPressed: () {
              setState(() {
                final newScore = score - baseScore;
                _currentScores[player.id] = newScore;
                controller.text = newScore > 0 ? '+$newScore' : '$newScore';
              });
            },
            child: const Icon(CupertinoIcons.minus_circle, size: 28),
          ),
          SizedBox(
            width: 70,
            child: CupertinoTextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: score >= 0 ? CupertinoColors.activeBlue : CupertinoColors.systemRed,
              ),
              onChanged: (value) {
                final sanitized = value.replaceAll('+', '');
                final val = int.tryParse(sanitized) ?? 0;
                setState(() {
                  _currentScores[player.id] = val;
                });
              },
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(44, 44),
            onPressed: () {
              setState(() {
                final newScore = score + baseScore;
                _currentScores[player.id] = newScore;
                controller.text = newScore > 0 ? '+$newScore' : '$newScore';
              });
            },
            child: const Icon(CupertinoIcons.add_circled, size: 28),
          ),
        ],
      ),
    );
  }
}
