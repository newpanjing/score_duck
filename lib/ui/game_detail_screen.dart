import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
  final GlobalKey _boundaryKey = GlobalKey();

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

  Future<void> _shareScore() async {
    try {
      final RenderRepaintBoundary boundary = 
          _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/score_share.png').create();
      await file.writeAsBytes(pngBytes);

      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: '这是我们的比赛实时比分！',
      );
      
      if (!mounted) return;
      if (result.status == ShareResultStatus.success) {
        debugPrint('分享成功');
      }
    } catch (e) {
      debugPrint('分享失败: $e');
    }
  }

  void _showAddRoundSheet(BuildContext context, Game game, {Round? round}) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.2),
      builder: (context) => _AddRoundSheet(game: game, initialRound: round),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(scoreProvider);
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

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
            child: Center(child: Text('未找到比赛')),
          );
        }

        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

        return CupertinoPageScaffold(
          backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: isDark ? const Color(0xFF000000).withValues(alpha: 0.8) : const Color(0xFFF2F2F7).withValues(alpha: 0.8),
            border: null,
            middle: Text(game.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _shareScore,
                  child: const Icon(CupertinoIcons.share, size: 20),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _toggleOrientation,
                  child: Icon(
                    isLandscape ? CupertinoIcons.device_phone_portrait : CupertinoIcons.device_phone_landscape,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                if (isLandscape)
                  _LandscapeLayout(
                    game: game,
                    onEditRound: (round) => _showAddRoundSheet(context, game, round: round),
                  )
                else
                  _PortraitLayout(
                    game: game,
                    onEditRound: (round) => _showAddRoundSheet(context, game, round: round),
                    repaintKey: _boundaryKey,
                  ),
                _FloatingActionButton(
                  onPressed: () => _showAddRoundSheet(context, game),
                  isLandscape: isLandscape,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- 核心布局组件 ---

class _PortraitLayout extends StatelessWidget {
  final Game game;
  final Function(Round) onEditRound;
  final GlobalKey repaintKey;

  const _PortraitLayout({
    required this.game, 
    required this.onEditRound,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          key: repaintKey,
          child: _StandingsBoard(game: game),
        ),
        Expanded(
          child: _RoundTimeline(game: game, onEditRound: onEditRound),
        ),
      ],
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  final Game game;
  final Function(Round) onEditRound;

  const _LandscapeLayout({required this.game, required this.onEditRound});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: _LeaderboardSidebar(game: game),
        ),
        Expanded(
          child: _RoundTimeline(game: game, onEditRound: onEditRound, isLandscape: true),
        ),
      ],
    );
  }
}

// --- 1. 计分板 (Standings Board) ---

class _StandingsBoard extends StatelessWidget {
  final Game game;

  const _StandingsBoard({required this.game});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final totalScores = game.totalScores;
    final sortedPlayers = game.players.toList()
      ..sort((a, b) => (totalScores[b.id] ?? 0).compareTo(totalScores[a.id] ?? 0));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '当前比分',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CupertinoColors.systemGrey),
                  ),
                  Text(
                    DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now()),
                    style: const TextStyle(fontSize: 10, color: CupertinoColors.systemGrey2),
                  ),
                ],
              ),
              if (game.rounds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '第 ${game.rounds.length} 局',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: game.players.map((player) {
                final score = totalScores[player.id] ?? 0;
                final rank = sortedPlayers.indexOf(player);
                final isTop = rank == 0 && game.rounds.isNotEmpty;
                
                String prefix = '';
                if (game.rounds.isNotEmpty) {
                  if (rank == 0) {
                    prefix = '🥇 ';
                  } else if (rank == 1) {
                    prefix = '🥈 ';
                  } else if (rank == 2) {
                    prefix = '🥉 ';
                  }
                }

                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      _RankBadge(rank: rank, show: isTop),
                      const SizedBox(height: 4),
                      Text(
                        '$prefix${player.name}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: score == 0
                              ? CupertinoColors.systemGrey
                              : (score > 0 ? CupertinoColors.systemRed : CupertinoColors.systemGreen),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final bool show;

  const _RankBadge({required this.rank, required this.show});

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox(height: 16);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        '领跑',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB8860B)),
      ),
    );
  }
}

// --- 2. 时间线记录列表 (Timeline List) ---

class _RoundTimeline extends StatelessWidget {
  final Game game;
  final Function(Round) onEditRound;
  final bool isLandscape;

  const _RoundTimeline({required this.game, required this.onEditRound, this.isLandscape = false});

  @override
  Widget build(BuildContext context) {
    if (game.rounds.isEmpty) return const _EmptyState();

    final rounds = game.rounds.reversed.toList();

    return ListView.builder(
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
        bottom: isLandscape ? 100 : 120,
      ),
      itemCount: rounds.length,
      itemBuilder: (context, index) {
        final round = rounds[index];
        final roundNumber = game.rounds.length - index;
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Expanded(child: Divider(thickness: 0.5)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '第 $roundNumber 局',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: CupertinoColors.systemGrey.withValues(alpha: 0.8),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('HH:mm').format(round.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.systemGrey.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: Divider(thickness: 0.5)),
                ],
              ),
            ),
            _TimelineItem(
              round: round,
              players: game.players,
              onTap: () => onEditRound(round),
            ),
          ],
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Round round;
  final List<Player> players;
  final VoidCallback onTap;

  const _TimelineItem({
    required this.round,
    required this.players,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: players.map((p) {
              final score = round.scores[p.id] ?? 0;
              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      score > 0 ? '+$score' : '$score',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: score == 0
                            ? CupertinoColors.systemGrey
                            : (score > 0 ? CupertinoColors.systemRed : CupertinoColors.systemGreen),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// --- 3. 横屏侧边栏 (Leaderboard Sidebar) ---

class _LeaderboardSidebar extends StatelessWidget {
  final Game game;

  const _LeaderboardSidebar({required this.game});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final totalScores = game.totalScores;
    final sortedPlayers = game.players.toList()
      ..sort((a, b) => (totalScores[b.id] ?? 0).compareTo(totalScores[a.id] ?? 0));

    return Container(
      color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              '当前排名',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sortedPlayers.length,
              itemBuilder: (context, index) {
                final player = sortedPlayers[index];
                final score = totalScores[player.id] ?? 0;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: index == 0 
                        ? CupertinoColors.activeBlue.withValues(alpha: 0.05)
                        : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F9F9)),
                    borderRadius: BorderRadius.circular(16),
                    border: index == 0 
                        ? Border.all(color: CupertinoColors.activeBlue.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Row(
                    children: [
                      _RankIcon(rank: index),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${index == 0 ? "🥇 " : index == 1 ? "🥈 " : index == 2 ? "🥉 " : ""}${player.name}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: score == 0
                              ? CupertinoColors.systemGrey
                              : (score > 0 ? CupertinoColors.systemRed : CupertinoColors.systemGreen),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RankIcon extends StatelessWidget {
  final int rank;
  const _RankIcon({required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank < 3) {
      final colors = [
        const Color(0xFFFFD700),
        const Color(0xFFC0C0C0),
        const Color(0xFFCD7F32),
      ];
      return Icon(CupertinoIcons.circle_fill, size: 10, color: colors[rank]);
    }
    return const SizedBox(width: 10);
  }
}

// --- 4. 辅助组件 (Floating Action Button) ---

class _FloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLandscape;

  const _FloatingActionButton({required this.onPressed, required this.isLandscape});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: isLandscape ? 32 : 44,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.activeBlue.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(CupertinoIcons.add, color: CupertinoColors.white, size: 32),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.chart_bar, size: 80),
            const SizedBox(height: 16),
            const Text('暂无比赛记录', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('记录你的每一场精彩瞬间', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// --- 记分弹窗 (Add Round Sheet) ---

class _AddRoundSheet extends ConsumerStatefulWidget {
  final Game game;
  final Round? initialRound;

  const _AddRoundSheet({required this.game, this.initialRound});

  @override
  ConsumerState<_AddRoundSheet> createState() => _AddRoundSheetState();
}

class _AddRoundSheetState extends ConsumerState<_AddRoundSheet> {
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
                ...widget.game.players.map((p) =>
                    _buildPlayerInput(p, baseScore, isDark)),
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
            child: const Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            isEditing ? '修改记录' : '新的一局',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          CupertinoButton(
            onPressed: _saveRound,
            child: const Text('完成', style: TextStyle(fontWeight: FontWeight.bold)),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('基础分', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('点击步长', style: TextStyle(fontSize: 11, color: CupertinoColors.systemGrey2)),
            ],
          ),
          _Stepper(
            value: baseScore,
            onChanged: (val) {
              if (val > 0) ref.read(baseScoresProvider.notifier).setScore(widget.game.id, val);
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
          _Stepper(
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

class _Stepper extends StatelessWidget {
  final int value;
  final int step;
  final ValueChanged<int> onChanged;
  final bool isScore;

  const _Stepper({
    required this.value,
    this.step = 1,
    required this.onChanged,
    this.isScore = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final color = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: CupertinoIcons.minus, onTap: () => onChanged(value - step)),
          Container(
            width: isScore ? 70 : 44,
            alignment: Alignment.center,
            child: Text(
              isScore && value > 0 ? '+$value' : '$value',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isScore ? (value >= 0 ? CupertinoColors.activeBlue : CupertinoColors.systemRed) : null,
              ),
            ),
          ),
          _StepBtn(icon: CupertinoIcons.plus, onTap: () => onChanged(value + step)),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3A3A3C) : CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}