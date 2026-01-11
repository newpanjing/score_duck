import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  Future<void> _saveGame() async {
    if (_nameController.text.isEmpty) return;

    final players = _playerControllers
        .map((c) => Player(name: c.text.isEmpty ? 'Unknown' : c.text))
        .toList();

    final game = Game(
      name: _nameController.text,
      type: GameType.generic,
      players: players,
    );

    await ref.read(scoreProvider.notifier).addGame(game);
    Navigator.of(context).pop();
    context.go('/game/${game.id}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

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
                    minimumSize: const Size(44, 44),
                    child: const Text('取消', style: TextStyle(fontSize: 17)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text('创建比赛', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(44, 44),
                    onPressed: _saveGame,
                    child: const Text('开始', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.activeBlue)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 8,
                  bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 20,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '基本信息',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.systemGrey,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark 
                                  ? CupertinoColors.white.withValues(alpha: 0.1)
                                  : CupertinoColors.systemGrey4,
                                width: 1.5,
                              ),
                              boxShadow: [
                                if (!isDark)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: CupertinoTextField(
                              controller: _nameController,
                              placeholder: '请输入比赛名称',
                              placeholderStyle: TextStyle(
                                color: CupertinoColors.systemGrey.withValues(alpha: 0.6),
                                fontSize: 17,
                              ),
                              decoration: null,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: isDark ? CupertinoColors.white : CupertinoColors.black,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '玩家人数',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? CupertinoColors.white : CupertinoColors.black,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_playerCount.toInt()}人',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: CupertinoColors.activeBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CupertinoSlider(
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '玩家列表',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.systemGrey,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(_playerControllers.length, (index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: index < _playerControllers.length - 1 ? 12 : 0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          CupertinoColors.activeBlue,
                                          CupertinoColors.activeBlue.withValues(alpha: 0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: CupertinoColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemBackground,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark 
                                            ? CupertinoColors.white.withValues(alpha: 0.1)
                                            : CupertinoColors.systemGrey4,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          if (!isDark)
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.03),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                        ],
                                      ),
                                      child: CupertinoTextField(
                                        controller: _playerControllers[index],
                                        placeholder: '请输入玩家名字',
                                        placeholderStyle: TextStyle(
                                          color: CupertinoColors.systemGrey.withValues(alpha: 0.6),
                                          fontSize: 16,
                                        ),
                                        decoration: null,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? CupertinoColors.white : CupertinoColors.black,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
