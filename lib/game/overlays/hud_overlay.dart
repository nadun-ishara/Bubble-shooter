import 'package:flutter/material.dart';
import '../bubble_shooter_game.dart';
import '../game_config.dart';

class HudOverlay extends StatelessWidget {
  final BubbleShooterGame game;
  final VoidCallback onPause;
  final VoidCallback onRestart;
  final VoidCallback onExitToHome;

  const HudOverlay({
    super.key,
    required this.game,
    required this.onPause,
    required this.onRestart,
    required this.onExitToHome,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          children: [
            // Top Steampunk Brass HUD Header
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3E2723),
                    Color(0xFF5D4037),
                    Color(0xFF3E2723),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Home Button
                  _buildIconButton(
                    icon: Icons.arrow_back,
                    tooltip: 'Main Menu',
                    onTap: onExitToHome,
                  ),
                  const SizedBox(width: 8),

                  // Score Counter with brass badge
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E140A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFB8860B), width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stars, color: Color(0xFFFFD54F), size: 18),
                          const SizedBox(width: 6),
                          ValueListenableBuilder<int>(
                            valueListenable: game.scoreNotifier,
                            builder: (context, score, _) {
                              return Text(
                                '$score',
                                style: const TextStyle(
                                  color: Color(0xFFFFE082),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontFamily: 'monospace',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Miss / Pressure Indicator (5 orbs/cogs)
                  ValueListenableBuilder<int>(
                    valueListenable: game.missNotifier,
                    builder: (context, misses, _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          GameConfig.missesBeforeCeilingDrop,
                          (index) {
                            final filled = index < misses;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: filled
                                    ? const Color(0xFFEF5350)
                                    : const Color(0xFF3E2723),
                                border: Border.all(
                                  color: filled
                                      ? const Color(0xFFFF8A80)
                                      : const Color(0xFF8D6E63),
                                  width: 1.2,
                                ),
                                boxShadow: filled
                                    ? [
                                        const BoxShadow(
                                          color: Color(0x80EF5350),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 8),

                  // Restart Button
                  _buildIconButton(
                    icon: Icons.refresh,
                    tooltip: 'Restart Level',
                    onTap: onRestart,
                  ),
                  const SizedBox(width: 6),

                  // Pause Button
                  _buildIconButton(
                    icon: Icons.pause,
                    tooltip: 'Pause',
                    onTap: onPause,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2B1D15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
          ),
          child: Icon(icon, color: const Color(0xFFFFD54F), size: 18),
        ),
      ),
    );
  }
}
