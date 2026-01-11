import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/score_store.dart';
import '../models/game.dart';
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
    final games = ref.watch(scoreProvider);
    Game? gameNullable;
    try {
      gameNullable = games.firstWhere((g) => g.id == widget.gameId);
    } catch (e) {
      gameNullable = null;
    }

    if (gameNullable == null) {
      return const CupertinoPageScaffold(
        child: Center(child: Text('Game not found')),
      );
    }

    final Game game = gameNullable;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(game.name),
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
            // Floating Action Button
            Positioned(
              right: 24,
              bottom: isLandscape ? 32 : 110,
              child: GestureDetector(
                onTap: () => _showAddRoundSheet(context, game),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : CupertinoColors.activeBlue)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.add,
                    color: CupertinoColors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(Game game) {
    const double columnWidth = 100.0;
    const double timeColumnWidth = 70.0;
    final totalScores = game.totalScores;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildHeader(game, totalScores, timeColumnWidth, columnWidth),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: timeColumnWidth + (game.players.length * columnWidth),
              child: _buildRoundsList(game, timeColumnWidth, columnWidth),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(Game game) {
    const double columnWidth = 110.0;
    const double timeColumnWidth = 70.0;
    final totalScores = game.totalScores;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    // Calculate ranks
    final sortedUniqueScores = totalScores.values.toSet().toList()..sort((a, b) => b.compareTo(a));

    return Row(
      children: [
        // Sidebar: Scoreboard
        Container(
          width: 240,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.secondarySystemGroupedBackground,
            border: Border(right: BorderSide(color: isDark ? CupertinoColors.white.withValues(alpha: 0.1) : CupertinoColors.separator)),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('总分榜', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey)),
              const SizedBox(height: 16),
              ...game.players.map((p) {
                final score = totalScores[p.id] ?? 0;
                final rankIcon = _getRankIcon(score, sortedUniqueScores, game.rounds.isNotEmpty);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            Text(
                              '$score',
                              style: TextStyle(
                                fontSize: 26, 
                                fontWeight: FontWeight.bold,
                                color: score >= 0 ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (rankIcon != null) rankIcon,
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        // Main: Rounds Table
        Expanded(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildHeader(game, null, timeColumnWidth, columnWidth),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: timeColumnWidth + (game.players.length * columnWidth),
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

  Widget _buildHeader(Game game, Map<String, int>? totalScores, double timeColumnWidth, double columnWidth) {
    List<int> sortedUniqueScores = [];
    if (totalScores != null) {
      sortedUniqueScores = totalScores.values.toSet().toList()..sort((a, b) => b.compareTo(a));
    }
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      width: timeColumnWidth + (game.players.length * columnWidth),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.secondarySystemGroupedBackground,
        border: Border(bottom: BorderSide(color: isDark ? CupertinoColors.white.withValues(alpha: 0.1) : CupertinoColors.separator)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: timeColumnWidth,
            child: const Center(
              child: Icon(CupertinoIcons.time, size: 18, color: CupertinoColors.systemGrey),
            ),
          ),
          ...game.players.map((p) {
            final score = totalScores?[p.id];
            Widget? rankIcon;
            if (score != null) {
              rankIcon = _getRankIcon(score, sortedUniqueScores, game.rounds.isNotEmpty);
            }

            return SizedBox(
              width: columnWidth,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (rankIcon != null) ...[
                        const SizedBox(width: 4),
                        rankIcon,
                      ]
                    ],
                  ),
                  if (score != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: score >= 0
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.destructiveRed,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }


  Widget? _getRankIcon(int score, List<int> sortedUniqueScores, bool hasRounds) {
    if (!hasRounds || sortedUniqueScores.isEmpty) return null;
    
    final rank = sortedUniqueScores.indexOf(score);
    String medal = '';
    if (rank == 0) {
      medal = '🥇';
    } else if (rank == 1) {
      medal = '🥈';
    } else if (rank == 2) {
      medal = '🥉';
    } else {
      return null;
    }
    
    return Text(medal, style: const TextStyle(fontSize: 18));
  }

  Widget _buildRoundsList(Game game, double timeColumnWidth, double columnWidth) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    if (game.rounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 80),
            Icon(
              CupertinoIcons.doc_text_search,
              size: 56,
              color: CupertinoColors.systemGrey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              '暂无局数记录',
              style: TextStyle(
                color: CupertinoColors.systemGrey.withValues(alpha: 0.5),
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: game.rounds.length,
      itemBuilder: (context, index) {
        final round = game.rounds[game.rounds.length - 1 - index];
        final isEven = index % 2 == 0;

        return GestureDetector(
          onTap: () => _showAddRoundSheet(context, game, round: round),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: isEven
                  ? (isDark ? const Color(0xFF1C1C1E).withValues(alpha: 0.5) : CupertinoColors.systemBackground)
                  : (isDark ? const Color(0xFF2C2C2E).withValues(alpha: 0.5) : CupertinoColors.secondarySystemGroupedBackground),
              border: Border(bottom: BorderSide(color: isDark ? CupertinoColors.white.withValues(alpha: 0.05) : CupertinoColors.separator.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: timeColumnWidth,
                  child: Center(
                    child: Text(
                      DateFormat('HH:mm').format(round.timestamp),
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                ...game.players.map((p) {
                  final score = round.scores[p.id] ?? 0;
                  return SizedBox(
                    width: columnWidth,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: score == 0 
                              ? Colors.transparent 
                              : (score > 0 ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          score > 0 ? '+$score' : '$score',
                          style: TextStyle(
                            color: score == 0
                                ? CupertinoColors.systemGrey
                                : (score > 0
                                    ? CupertinoColors.activeGreen
                                    : CupertinoColors.destructiveRed),
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
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
  late Map<String, TextEditingController> _controllers;
  late TextEditingController _baseScoreController;

  @override
  void initState() {
    super.initState();
    _currentScores = widget.initialRound != null
        ? Map<String, int>.from(widget.initialRound!.scores)
        : {for (var p in widget.game.players) p.id: 0};
        
    _controllers = {
      for (var p in widget.game.players)
        p.id: TextEditingController(
            text: _currentScores[p.id]! > 0
                ? '+${_currentScores[p.id]}'
                : '${_currentScores[p.id]}')
    };
    
    final baseScores = ref.read(baseScoresProvider);
    final int baseScore = baseScores[widget.game.id] ?? 1;
    _baseScoreController = TextEditingController(text: '$baseScore');
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    _baseScoreController.dispose();
    super.dispose();
  }

  void _updateController(String playerId, int score) {
    final controller = _controllers[playerId];
    if (controller != null) {
      final text = score > 0 ? '+$score' : '$score';
      controller.text = text;
    }
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
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final bool isEditing = widget.initialRound != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemGroupedBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.systemBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: isDark ? CupertinoColors.white.withValues(alpha: 0.1) : CupertinoColors.separator)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('取消'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(isEditing ? '修改记录' : '记录本局', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? CupertinoColors.white : CupertinoColors.black)),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _saveRound,
                  child: Text(isEditing ? '更新' : '完成', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('基础分 (倍率)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          _CircleButton(
                            icon: CupertinoIcons.minus,
                            color: isDark ? CupertinoColors.systemGrey.withValues(alpha: 0.2) : CupertinoColors.systemGrey6,
                            iconColor: isDark ? CupertinoColors.white : CupertinoColors.black,
                            onTap: () {
                              ref.read(baseScoresProvider.notifier).decrement(widget.game.id);
                              final newBase = (baseScores[widget.game.id] ?? 1) - 1;
                              if (newBase >= 1) {
                                _baseScoreController.text = '$newBase';
                              }
                            },
                          ),
                          SizedBox(
                            width: 60,
                            child: CupertinoTextField(
                              controller: _baseScoreController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: null,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                              onChanged: (value) {
                                final val = int.tryParse(value);
                                if (val != null && val > 0) {
                                  ref.read(baseScoresProvider.notifier).setScore(widget.game.id, val);
                                }
                              },
                            ),
                          ),
                          _CircleButton(
                            icon: CupertinoIcons.add,
                            color: CupertinoColors.activeBlue,
                            iconColor: CupertinoColors.white,
                            onTap: () {
                              ref.read(baseScoresProvider.notifier).increment(widget.game.id);
                              final newBase = (baseScores[widget.game.id] ?? 1) + 1;
                              _baseScoreController.text = '$newBase';
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ...widget.game.players.map((p) {
                  final score = _currentScores[p.id] ?? 0;
                  final controller = _controllers[p.id]!;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.systemBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                             _CircleButton(
                              icon: CupertinoIcons.minus,
                              color: CupertinoColors.destructiveRed.withValues(alpha: 0.1),
                              iconColor: CupertinoColors.destructiveRed,
                              onTap: () {
                                setState(() {
                                  final current = _currentScores[p.id] ?? 0;
                                  final newScore = current - baseScore;
                                  _currentScores[p.id] = newScore;
                                  _updateController(p.id, newScore);
                                });
                              },
                            ),
                            SizedBox(
                              width: 80,
                              child: CupertinoTextField(
                                controller: controller,
                                textAlign: TextAlign.center,
                                keyboardType: const TextInputType.numberWithOptions(signed: true),
                                decoration: null,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: score == 0
                                      ? CupertinoColors.systemGrey
                                      : (score > 0 ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed),
                                ),
                                onChanged: (value) {
                                  // Remove '+' if user typed it or handle signed numbers
                                  final sanitized = value.replaceAll('+', '');
                                  final val = int.tryParse(sanitized) ?? 0;
                                  setState(() {
                                    _currentScores[p.id] = val;
                                  });
                                },
                              ),
                            ),
                            _CircleButton(
                              icon: CupertinoIcons.add,
                              color: CupertinoColors.activeGreen.withValues(alpha: 0.1),
                              iconColor: CupertinoColors.activeGreen,
                              onTap: () {
                                setState(() {
                                  final current = _currentScores[p.id] ?? 0;
                                  final newScore = current + baseScore;
                                  _currentScores[p.id] = newScore;
                                  _updateController(p.id, newScore);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}
