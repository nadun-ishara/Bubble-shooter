import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/steampunk_theme.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/game_canvas_widget.dart';
import '../widgets/steampunk_button.dart';
import '../widgets/steampunk_dialog.dart';
import '../widgets/steampunk_hud.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (_lastTick == Duration.zero) {
        _lastTick = elapsed;
        return;
      }
      final double dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
      _lastTick = elapsed;

      // Clamp dt to prevent physics tunnel spikes
      final clampedDt = dt.clamp(0.001, 0.04);
      if (mounted) {
        context.read<GameBloc>().add(TickEvent(clampedDt));
      }
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleExit() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SteampunkTheme.darkBrassBg,
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {},
        builder: (context, state) {
          final gameBloc = context.read<GameBloc>();

          return Stack(
            children: [
              // 1. Core 60fps Game Canvas with Gesture Handling & Precision Virtual Scaling
              Positioned.fill(
                child: GameCanvasWidget(
                  state: state,
                  onAim: (vx, vy) => gameBloc.add(AimEvent(vx, vy)),
                  onCancelAim: () => gameBloc.add(const CancelAimEvent()),
                  onFire: () => gameBloc.add(const FireEvent()),
                  onSwap: () => gameBloc.add(const SwapBubbleEvent()),
                ),
              ),

              // 2. Steampunk HUD Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SteampunkHud(
                  state: state,
                  onExit: _handleExit,
                  onRestart: () => gameBloc.add(const RestartGameEvent()),
                  onPause: () => gameBloc.add(const PauseGameEvent()),
                  onToggleSound: () => gameBloc.add(const ToggleSoundEvent()),
                ),
              ),

              // 3. Pause Modal Dialog
              if (state.status == GameStatus.paused)
                Container(
                  color: Colors.black.withValues(alpha: 0.70),
                  child: SteampunkDialog(
                    title: 'EXPEDITION PAUSED',
                    subtitle: 'Steam pressure is holding steady.',
                    content: const Icon(
                      Icons.settings_suggest,
                      color: SteampunkTheme.brightGold,
                      size: 48,
                    ),
                    actions: [
                      SteampunkButton(
                        label: 'RESUME',
                        icon: Icons.play_arrow,
                        onPressed: () => gameBloc.add(const ResumeGameEvent()),
                      ),
                      SteampunkButton(
                        label: 'RESTART LEVEL',
                        icon: Icons.refresh,
                        isPrimary: false,
                        onPressed: () => gameBloc.add(const RestartGameEvent()),
                      ),
                      SteampunkButton(
                        label: 'MAIN MENU',
                        icon: Icons.home,
                        isPrimary: false,
                        onPressed: _handleExit,
                      ),
                    ],
                  ),
                ),

              // 4. Game Over Modal Dialog
              if (state.status == GameStatus.gameOver)
                Container(
                  color: Colors.black.withValues(alpha: 0.78),
                  child: SteampunkDialog(
                    title: 'BOILER OVERHEAT!',
                    subtitle: 'The bubbles overwhelmed the defense line.',
                    content: Column(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFEF5350),
                          size: 52,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Final Score: ${state.stats.score}',
                          style: const TextStyle(
                            color: Color(0xFFFFE082),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Best Score: ${state.stats.highScore}',
                          style: const TextStyle(
                            color: Color(0xFFD7CCC8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      SteampunkButton(
                        label: 'RETRY EXPEDITION',
                        icon: Icons.replay,
                        onPressed: () => gameBloc.add(const RestartGameEvent()),
                      ),
                      SteampunkButton(
                        label: 'MAIN MENU',
                        icon: Icons.home,
                        isPrimary: false,
                        onPressed: _handleExit,
                      ),
                    ],
                  ),
                ),

              // 5. Victory Modal Dialog
              if (state.status == GameStatus.victory)
                Container(
                  color: Colors.black.withValues(alpha: 0.78),
                  child: SteampunkDialog(
                    title: 'SECTOR CLEARED!',
                    subtitle: 'Flawless marksmanship, Commander!',
                    content: Column(
                      children: [
                        const Icon(
                          Icons.military_tech,
                          color: Color(0xFFFFD700),
                          size: 56,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Score: ${state.stats.score}',
                          style: const TextStyle(
                            color: Color(0xFFFFE082),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Best: ${state.stats.highScore}',
                          style: const TextStyle(
                            color: Color(0xFFD7CCC8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      SteampunkButton(
                        label: 'PLAY AGAIN',
                        icon: Icons.play_arrow,
                        onPressed: () => gameBloc.add(const RestartGameEvent()),
                      ),
                      SteampunkButton(
                        label: 'MAIN MENU',
                        icon: Icons.home,
                        isPrimary: false,
                        onPressed: _handleExit,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
