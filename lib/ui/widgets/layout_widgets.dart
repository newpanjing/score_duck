import 'package:flutter/cupertino.dart';
import '../../models/game.dart';
import '../../models/round.dart';
import 'standings_board.dart';
import 'round_timeline.dart';
import 'leaderboard_sidebar.dart';

class PortraitLayout extends StatelessWidget {
  final Game game;
  final Function(Round) onEditRound;
  final GlobalKey repaintKey;

  const PortraitLayout({
    super.key,
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
          child: StandingsBoard(game: game),
        ),
        Expanded(
          child: RoundTimeline(game: game, onEditRound: onEditRound),
        ),
      ],
    );
  }
}

class LandscapeLayout extends StatelessWidget {
  final Game game;
  final Function(Round) onEditRound;

  const LandscapeLayout({super.key, required this.game, required this.onEditRound});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: LeaderboardSidebar(game: game),
        ),
        Expanded(
          child: RoundTimeline(game: game, onEditRound: onEditRound, isLandscape: true),
        ),
      ],
    );
  }
}
