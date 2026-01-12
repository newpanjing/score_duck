import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/game.dart';
import '../models/round.dart';
import 'widgets/layout_widgets.dart';
import 'widgets/common_widgets.dart';
import 'widgets/add_round_sheet.dart';

class GameDetailScreen extends StatefulWidget {
  final String gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
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
      // 触感反馈
      HapticFeedback.mediumImpact();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'game_detail_share_text'.tr,
        ),
      );
    } catch (e) {
      debugPrint('分享失败: $e');
    }
  }

  void _showAddRoundSheet(BuildContext context, Game game, {Round? round}) {
    // 触感反馈
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.2),
      builder: (context) => AddRoundSheet(game: game, initialRound: round),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final games = gameController.games;
      final game = games.cast<Game?>().firstWhere(
            (g) => g?.id == widget.gameId,
            orElse: () => null,
          );

      if (game == null) {
        return CupertinoPageScaffold(
          child: Center(child: Text('game_detail_found_no_game'.tr)),
        );
      }

      final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

      return CupertinoPageScaffold(
          backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: isDark
                ? const Color(0xFF000000).withValues(alpha: 0.8)
                : const Color(0xFFF2F2F7).withValues(alpha: 0.8),
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
                    isLandscape
                        ? CupertinoIcons.device_phone_portrait
                        : CupertinoIcons.device_phone_landscape,
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
                  LandscapeLayout(
                    game: game,
                    onEditRound: (Round round) => _showAddRoundSheet(context, game, round: round),
                  )
                else
                  PortraitLayout(
                    game: game,
                    onEditRound: (Round round) => _showAddRoundSheet(context, game, round: round),
                    repaintKey: _boundaryKey,
                  ),
                ScoreFloatingActionButton(
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
