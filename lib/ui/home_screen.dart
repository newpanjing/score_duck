import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import '../controllers/game_controller.dart';
import '../models/game.dart';
import 'create_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showCreateGameSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const CreateGameScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();

    return Obx(() {
      final games = gameController.games;
      final systemBrightness = MediaQuery.of(context).platformBrightness;
      final isDark = CupertinoTheme.of(context).brightness == Brightness.dark ||
          (CupertinoTheme.of(context).brightness == null && systemBrightness == Brightness.dark);

      return CupertinoPageScaffold(
        backgroundColor: isDark 
            ? const Color(0xFF000000)
            : const Color(0xFFF5F5F7),
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text('home_title'.tr),
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
                      Text(
                        'home_no_games'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CupertinoButton.filled(
                        child: Text('home_create_game'.tr),
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
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      );
    });
  }
}

class _GameListItem extends StatelessWidget {
  final Game game;

  const _GameListItem({required this.game});

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final dateFormat = intl.DateFormat('MM-dd HH:mm');
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Dismissible(
          key: Key(game.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  CupertinoColors.destructiveRed,
                  CupertinoColors.destructiveRed.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white, size: 28),
          ),
          onDismissed: (_) {
            gameController.deleteGame(game.id);
          },
          child: GestureDetector(
            onTap: () => Get.toNamed('/game/${game.id}'),
            child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1C1C1E),
                            const Color(0xFF252527),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFFFFFF),
                            const Color(0xFFF8F8FA),
                          ],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? CupertinoColors.white.withValues(alpha: 0.12) : CupertinoColors.systemGrey.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? CupertinoColors.white : CupertinoColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? CupertinoColors.white.withValues(alpha: 0.05)
                          : CupertinoColors.systemGrey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            CupertinoIcons.person_2_fill,
                            size: 18,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            game.players.map((p) => p.name).join(" · "),
                            style: TextStyle(
                              color: isDark 
                                  ? CupertinoColors.white.withValues(alpha: 0.8)
                                  : CupertinoColors.black.withValues(alpha: 0.7),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? CupertinoColors.white.withValues(alpha: 0.05)
                                  : CupertinoColors.systemGrey.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              CupertinoIcons.time,
                              size: 14,
                              color: isDark 
                                  ? CupertinoColors.white.withValues(alpha: 0.5)
                                  : CupertinoColors.systemGrey.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(game.createdAt),
                            style: TextStyle(
                              color: isDark 
                                  ? CupertinoColors.white.withValues(alpha: 0.5)
                                  : CupertinoColors.systemGrey.withValues(alpha: 0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? CupertinoColors.activeGreen.withValues(alpha: 0.15)
                              : CupertinoColors.activeGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.chart_bar_fill,
                              size: 14,
                              color: CupertinoColors.activeGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'home_game_count'.trParams({'count': game.rounds.length.toString()}),
                              style: const TextStyle(
                                color: CupertinoColors.activeGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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