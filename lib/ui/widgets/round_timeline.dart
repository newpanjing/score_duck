import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:get/get.dart';
import '../../models/game.dart';
import '../../models/player.dart';
import '../../models/round.dart';

class RoundTimeline extends StatelessWidget {
  final Game game;
  final Function(Round) onEditRound;
  final bool isLandscape;

  const RoundTimeline({
    super.key,
    required this.game,
    required this.onEditRound,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    if (game.rounds.isEmpty) return const EmptyState();

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
                          'game_detail_round_n'.trParams({'count': roundNumber.toString()}),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: CupertinoColors.systemGrey.withValues(alpha: 0.8),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          intl.DateFormat('HH:mm').format(round.timestamp),
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
            TimelineItem(
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

class TimelineItem extends StatelessWidget {
  final Round round;
  final List<Player> players;
  final VoidCallback onTap;

  const TimelineItem({
    super.key,
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
                            : (score > 0
                                ? CupertinoColors.systemRed
                                : CupertinoColors.systemGreen),
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

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

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
            Text('game_detail_no_rounds'.tr,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('game_detail_start_scoring'.tr, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
