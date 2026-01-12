import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:get/get.dart';
import '../../models/game.dart';

class StandingsBoard extends StatelessWidget {
  final Game game;

  const StandingsBoard({super.key, required this.game});

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
                  Text(
                    'game_detail_current_score'.tr,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemGrey),
                  ),
                  Text(
                    intl.DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now()),
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
                    'game_detail_round_count'.trParams({'count': game.rounds.length.toString()}),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.activeBlue),
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
                      RankBadge(rank: rank, show: isTop),
                      const SizedBox(height: 4),
                      Text(
                        '$prefix${player.name}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
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
        ],
      ),
    );
  }
}

class RankBadge extends StatelessWidget {
  final int rank;
  final bool show;

  const RankBadge({super.key, required this.rank, required this.show});

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox(height: 16);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'game_detail_leading'.tr,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB8860B)),
      ),
    );
  }
}
