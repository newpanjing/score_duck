import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../models/game.dart';

class LeaderboardSidebar extends StatelessWidget {
  final Game game;

  const LeaderboardSidebar({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark ||
        (CupertinoTheme.of(context).brightness == null && systemBrightness == Brightness.dark);
    final totalScores = game.totalScores;
    final sortedPlayers = game.players.toList()
      ..sort((a, b) => (totalScores[b.id] ?? 0).compareTo(totalScores[a.id] ?? 0));

    return Container(
      color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              'game_detail_leaderboard'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
                      RankIcon(rank: index),
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
                              : (score > 0
                                  ? CupertinoColors.systemRed
                                  : CupertinoColors.systemGreen),
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

class RankIcon extends StatelessWidget {
  final int rank;
  const RankIcon({super.key, required this.rank});

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
