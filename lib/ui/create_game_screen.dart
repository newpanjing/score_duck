import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/score_store.dart';
import '../models/game.dart';
import '../models/player.dart';

class CreateGameScreen extends ConsumerStatefulWidget {
  const CreateGameScreen({super.key});

  @override
  ConsumerState<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends ConsumerState<CreateGameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _playerControllers = [];
  double _playerCount = 3.0;

  @override
  void initState() {
    super.initState();
    // Default 3 players
    for (int i = 0; i < 3; i++) {
      _playerControllers.add(TextEditingController(text: '玩家 ${i + 1}'));
    }
    _nameController.text = '新比赛';
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var c in _playerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _updatePlayerCount(int newCount) {
    if (newCount < 2) return;

    if (newCount > _playerControllers.length) {
      int diff = newCount - _playerControllers.length;
      for (int i = 0; i < diff; i++) {
        _playerControllers.add(
          TextEditingController(text: '玩家 ${_playerControllers.length + 1}'),
        );
      }
    } else if (newCount < _playerControllers.length) {
      int diff = _playerControllers.length - newCount;
      for (int i = 0; i < diff; i++) {
        _playerControllers.last.dispose();
        _playerControllers.removeLast();
      }
    }
  }

  void _saveGame() {
    if (_nameController.text.isEmpty) return;

    final players = _playerControllers
        .map((c) => Player(name: c.text.isEmpty ? 'Unknown' : c.text))
        .toList();

    final game = Game(
      name: _nameController.text,
      type: GameType.generic,
      players: players,
    );

    ref.read(scoreProvider.notifier).addGame(game);
    Navigator.of(context).pop();
    context.go('/game/${game.id}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemGroupedBackground,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemGroupedBackground,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 44,
                    child: const Text('取消', style: TextStyle(fontSize: 17)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text('创建比赛', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 44,
                    onPressed: _saveGame,
                    child: const Text('开始', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.activeBlue)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  CupertinoListSection.insetGrouped(
                    header: const Text('基本信息'),
                    children: [
                      CupertinoListTile(
                        title: const Text('名称'),
                        trailing: SizedBox(
                          width: 200,
                          child: CupertinoTextField(
                            controller: _nameController,
                            textAlign: TextAlign.end,
                            placeholder: '比赛名称',
                            decoration: null,
                          ),
                        ),
                      ),
                      CupertinoListTile(
                        title: const Text('玩家人数'),
                        trailing: Text('${_playerCount.toInt()}人'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoSlider(
                            value: _playerCount,
                            min: 2,
                            max: 12,
                            divisions: 10,
                            onChanged: (value) {
                              setState(() {
                                _playerCount = value;
                                _updatePlayerCount(value.toInt());
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  CupertinoListSection.insetGrouped(
                    header: const Text('玩家列表'),
                    children: [
                      for (int i = 0; i < _playerControllers.length; i++)
                        CupertinoListTile(
                          title: CupertinoTextField(
                            controller: _playerControllers[i],
                            placeholder: '玩家名字',
                            decoration: null,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}