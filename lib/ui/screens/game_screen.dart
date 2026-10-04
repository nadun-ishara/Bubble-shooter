import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../game/bubble_shooter_game.dart';
import '../../game/overlays/game_dialogs.dart';
import '../../game/overlays/hud_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BubbleShooterGame _game;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _game = BubbleShooterGame();
  }

  void _handlePause() {
    setState(() {
      _isPaused = true;
      _game.togglePause();
    });
  }

  void _handleResume() {
    setState(() {
      _isPaused = false;
      _game.togglePause();
    });
  }

  void _handleRestart() {
    setState(() {
      _isPaused = false;
    });
    _game.restartLevel();
  }

  void _handleExit() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191310),
      body: Stack(
        children: [
          // 1. The Flame Game Canvas with Touch & Aim Controls
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _game.handleTapDown(
                Vector2(details.localPosition.dx, details.localPosition.dy),
              ),
              onTapUp: (details) => _game.handleTapUp(
                Vector2(details.localPosition.dx, details.localPosition.dy),
              ),
              onPanStart: (details) => _game.handleDragStart(
                Vector2(details.localPosition.dx, details.localPosition.dy),
              ),
              onPanUpdate: (details) => _game.handleDragUpdate(
                Vector2(details.localPosition.dx, details.localPosition.dy),
              ),
              onPanEnd: (details) => _game.handleDragEnd(),
              onPanCancel: () => _game.handleDragEnd(),
              child: GameWidget(game: _game),
            ),
          ),

          // 2. The Steampunk HUD Header Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HudOverlay(
              game: _game,
              onPause: _handlePause,
              onRestart: _handleRestart,
              onExitToHome: _handleExit,
            ),
          ),

          // 3. Pause Modal Overlay
          if (_isPaused)
            Container(
              color: Colors.black.withValues(alpha: 0.65),
              child: SteampunkDialog(
                title: 'EXPEDITION PAUSED',
                subtitle: 'The steam pressure is holding.',
                content: const Icon(
                  Icons.settings_suggest,
                  color: Color(0xFFFFD54F),
                  size: 48,
                ),
                actions: [
                  SteampunkButton(
                    label: 'RESUME',
                    icon: Icons.play_arrow,
                    onPressed: _handleResume,
                  ),
                  SteampunkButton(
                    label: 'RESTART LEVEL',
                    icon: Icons.refresh,
                    onPressed: _handleRestart,
                    isPrimary: false,
                  ),
                  SteampunkButton(
                    label: 'MAIN MENU',
                    icon: Icons.home,
                    onPressed: _handleExit,
                    isPrimary: false,
                  ),
                ],
              ),
            ),

          // 4. Game Over Modal Overlay
          ValueListenableBuilder<bool>(
            valueListenable: _game.isGameOverNotifier,
            builder: (context, isGameOver, _) {
              if (!isGameOver) return const SizedBox.shrink();
              return Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: SteampunkDialog(
                  title: 'BOILER OVERHEAT!',
                  subtitle: 'The bubbles overwhelmed the defense line.',
                  content: Column(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFEF5350),
                        size: 50,
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<int>(
                        valueListenable: _game.scoreNotifier,
                        builder: (context, score, _) {
                          return Text(
                            'Final Score: $score',
                            style: const TextStyle(
                              color: Color(0xFFFFE082),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  actions: [
                    SteampunkButton(
                      label: 'RETRY EXPEDITION',
                      icon: Icons.replay,
                      onPressed: _handleRestart,
                    ),
                    SteampunkButton(
                      label: 'MAIN MENU',
                      icon: Icons.home,
                      onPressed: _handleExit,
                      isPrimary: false,
                    ),
                  ],
                ),
              );
            },
          ),

          // 5. Victory Modal Overlay
          ValueListenableBuilder<bool>(
            valueListenable: _game.isVictoryNotifier,
            builder: (context, isVictory, _) {
              if (!isVictory) return const SizedBox.shrink();
              return Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: SteampunkDialog(
                  title: 'SECTOR CLEARED!',
                  subtitle: 'Flawless marksmanship, Commander!',
                  content: Column(
                    children: [
                      const Icon(
                        Icons.military_tech,
                        color: Color(0xFFFFD700),
                        size: 54,
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<int>(
                        valueListenable: _game.scoreNotifier,
                        builder: (context, score, _) {
                          return Text(
                            'Score: $score',
                            style: const TextStyle(
                              color: Color(0xFFFFE082),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  actions: [
                    SteampunkButton(
                      label: 'PLAY AGAIN',
                      icon: Icons.play_arrow,
                      onPressed: _handleRestart,
                    ),
                    SteampunkButton(
                      label: 'MAIN MENU',
                      icon: Icons.home,
                      onPressed: _handleExit,
                      isPrimary: false,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
