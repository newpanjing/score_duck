import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/score_store.dart';
import '../models/game.dart';
import 'create_game_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showCreateGameSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const CreateGameScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(scoreProvider);

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('记分鸭'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add),
              onPressed: () => _showCreateGameSheet(context),
            ),
          ),
          if (games.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.game_controller,
                      size: 64,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '还没有比赛',
                      style: TextStyle(
                        fontSize: 20,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CupertinoButton.filled(
                      child: const Text('开始新比赛'),
                      onPressed: () => _showCreateGameSheet(context),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final game = games[index];
                  return _GameListItem(game: game);
                },
                childCount: games.length,
              ),
            ),
          // Add some padding at the bottom
           const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }
}

class _GameListItem extends ConsumerWidget {
  final Game game;

  const _GameListItem({required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MM-dd HH:mm');
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: Key(game.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: CupertinoColors.destructiveRed,
            child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
          ),
          onDismissed: (_) {
            ref.read(scoreProvider.notifier).deleteGame(game.id);
          },
          child: GestureDetector(
            onTap: () => context.go('/game/${game.id}'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C1C1E)
                    : CupertinoColors.secondarySystemGroupedBackground,
                border: Border.all(
                  color: isDark ? CupertinoColors.white.withValues(alpha: 0.1) : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          game.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          game.type.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.activeBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.person_2, size: 16, color: CupertinoColors.systemGrey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          game.players.map((p) => p.name).join(", "),
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(CupertinoIcons.time, size: 14, color: CupertinoColors.systemGrey2),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(game.createdAt),
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey2,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${game.rounds.length} 局记录',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey2,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

