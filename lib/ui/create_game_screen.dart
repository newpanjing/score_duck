import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/game.dart';
import '../models/player.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _playerControllers = [];
  double _playerCount = 3.0;
  late final GameController _gameController;

  @override
  void initState() {
    super.initState();
    _gameController = Get.find<GameController>();
    _nameController.text = 'create_game_default_game_name'.tr;
    for (int i = 0; i < 3; i++) {
      _playerControllers.add(TextEditingController(
          text: 'create_game_default_player_name'.trParams({'count': '${i + 1}'})));
    }
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
        _playerControllers.add(TextEditingController(
            text: 'create_game_default_player_name'
                .trParams({'count': '${_playerControllers.length + 1}'})));
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
        .map((c) => Player(name: c.text.isEmpty ? 'common_unknown'.tr : c.text))
        .toList();

    final game = Game(
      name: _nameController.text,
      players: players,
    );

    await _gameController.addGame(game);
    if (mounted) {
      Navigator.of(context).pop();
      Get.toNamed('/game/${game.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark ||
        (CupertinoTheme.of(context).brightness == null && systemBrightness == Brightness.dark);
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
            _ScreenHeader(
              onCancel: () => Navigator.of(context).pop(),
              onStart: _saveGame,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 8,
                  bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 40,
                ),
                child: Column(
                  children: [
                    _FormSection(
                      title: 'create_game_basic_info'.tr,
                      children: [
                        _StyledTextField(
                          controller: _nameController,
                          placeholder: 'create_game_game_name_placeholder'.tr,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),
                        _PlayerCountSelector(
                          count: _playerCount,
                          isDark: isDark,
                          onChanged: (value) {
                            setState(() {
                              _playerCount = value;
                              _updatePlayerCount(value.toInt());
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _FormSection(
                      title: 'create_game_player_list'.tr,
                      children: List.generate(_playerControllers.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < _playerControllers.length - 1 ? 16 : 0,
                          ),
                          child: _PlayerInputRow(
                            index: index,
                            controller: _playerControllers[index],
                            isDark: isDark,
                          ),
                        );
                      }),
                    ),
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

class _ScreenHeader extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onStart;

  const _ScreenHeader({required this.onCancel, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark ||
        (CupertinoTheme.of(context).brightness == null && systemBrightness == Brightness.dark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemGroupedBackground,
        border: Border(
          bottom: BorderSide(
            color: isDark ? CupertinoColors.separator : CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: onCancel,
            child: Text('common_cancel'.tr, style: const TextStyle(fontSize: 17)),
          ),
          Text(
            'create_game_title'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: onStart,
            child: Text(
              'create_game_start'.tr,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark ||
        (CupertinoTheme.of(context).brightness == null && systemBrightness == Brightness.dark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool isDark;

  const _StyledTextField({
    required this.controller,
    required this.placeholder,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemGrey6.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? CupertinoColors.systemGrey.withValues(alpha: 0.2) : Colors.transparent,
          width: 1,
        ),
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
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
    );
  }
}

class _PlayerCountSelector extends StatelessWidget {
  final double count;
  final bool isDark;
  final ValueChanged<double> onChanged;

  const _PlayerCountSelector({
    required this.count,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'create_game_player_count'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${count.toInt()}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CupertinoSlider(
            value: count,
            min: 2,
            max: 12,
            divisions: 10,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _PlayerInputRow extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final bool isDark;

  const _PlayerInputRow({
    required this.index,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.activeBlue.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StyledTextField(
            controller: controller,
            placeholder: 'create_game_player_name_placeholder'.tr,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}
