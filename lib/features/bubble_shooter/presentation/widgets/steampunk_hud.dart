import 'package:flutter/material.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/theme/steampunk_theme.dart';
import '../bloc/game_state.dart';

class SteampunkHud extends StatelessWidget {
  final GameState state;
  final VoidCallback onExit;
  final VoidCallback onRestart;
  final VoidCallback onPause;
  final VoidCallback onToggleSound;

  const SteampunkHud({
    super.key,
    required this.state,
    required this.onExit,
    required this.onRestart,
    required this.onPause,
    required this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF3E2723),
                Color(0xFF5D4037),
                Color(0xFF3E2723),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SteampunkTheme.polishedBrass, width: 1.8),
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
              // Main Menu Button
              _buildIconButton(
                icon: Icons.arrow_back,
                tooltip: 'Main Menu',
                onTap: onExit,
              ),
              const SizedBox(width: 8),

              // Score Counter with Brass Badge
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SteampunkTheme.antiqueDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFB8860B), width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, color: SteampunkTheme.brightGold, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${state.stats.score}',
                        style: const TextStyle(
                          color: SteampunkTheme.lightAmber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Pressure Gauge / Miss indicators (5 orbs)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  GameConstants.maxFoulsBeforeDrop,
                  (index) {
                    final filled = index < state.board.foulCount;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.2),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? const Color(0xFFEF5350) : const Color(0xFF3E2723),
                        border: Border.all(
                          color: filled ? const Color(0xFFFF8A80) : const Color(0xFF8D6E63),
                          width: 1.2,
                        ),
                        boxShadow: filled
                            ? const [
                                BoxShadow(
                                  color: Color(0x80EF5350),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Sound Toggle Button
              _buildIconButton(
                icon: state.soundEnabled ? Icons.volume_up : Icons.volume_off,
                tooltip: 'Sound',
                onTap: onToggleSound,
              ),
              const SizedBox(width: 6),

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
            border: Border.all(color: SteampunkTheme.polishedBrass, width: 1.0),
          ),
          child: Icon(icon, color: SteampunkTheme.brightGold, size: 18),
        ),
      ),
    );
  }
}
