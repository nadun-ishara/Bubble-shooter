import 'package:flutter/material.dart';
import '../../game/overlays/game_dialogs.dart';
import '../widgets/clockwork_gears.dart';
import '../widgets/steampunk_showcase.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _soundEnabled = true;
  bool _aimLineEnabled = true;

  void _startGame() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (context) => SteampunkDialog(
        title: 'ENGINEER MANUAL',
        subtitle: 'Tactical Clockwork Field Instructions',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildManualRow(
              icon: Icons.navigation,
              title: 'Aim & Fire',
              description: 'Drag or tap to direct the brass cannon trajectory. Release to launch.',
            ),
            const SizedBox(height: 12),
            _buildManualRow(
              icon: Icons.sync_alt,
              title: 'Wall Reflections',
              description: 'Bank your shots off the brass side plates to reach tight angles.',
            ),
            const SizedBox(height: 12),
            _buildManualRow(
              icon: Icons.bubble_chart,
              title: 'Match 3 Orbs',
              description: 'Connect 3 or more identical gems to trigger explosive steam pops.',
            ),
            const SizedBox(height: 12),
            _buildManualRow(
              icon: Icons.arrow_downward,
              title: 'Drop Orphans',
              description: 'Sever anchor connections to drop hanging clusters for huge bonus points!',
            ),
            const SizedBox(height: 12),
            _buildManualRow(
              icon: Icons.warning_amber,
              title: 'Pressure Ceiling',
              description: 'Consecutive misses lower the overhead ceiling. Prevent boiler overheat!',
            ),
          ],
        ),
        actions: [
          SteampunkButton(
            label: 'UNDERSTOOD',
            icon: Icons.check,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildManualRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF3E2723),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
          ),
          child: Icon(icon, color: const Color(0xFFFFD54F), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFFE082),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFFD7CCC8),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return SteampunkDialog(
            title: 'MECHANICAL SETTINGS',
            subtitle: 'Configure Workshop Parameters',
            content: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Sound Effects',
                    style: TextStyle(color: Color(0xFFFFECB3), fontSize: 15),
                  ),
                  activeThumbColor: const Color(0xFFFFD54F),
                  activeTrackColor: const Color(0xFFB8860B),
                  value: _soundEnabled,
                  onChanged: (val) {
                    setModalState(() => _soundEnabled = val);
                    setState(() => _soundEnabled = val);
                  },
                ),
                SwitchListTile(
                  title: const Text(
                    'Aim Trajectory Guide',
                    style: TextStyle(color: Color(0xFFFFECB3), fontSize: 15),
                  ),
                  activeThumbColor: const Color(0xFFFFD54F),
                  activeTrackColor: const Color(0xFFB8860B),
                  value: _aimLineEnabled,
                  onChanged: (val) {
                    setModalState(() => _aimLineEnabled = val);
                    setState(() => _aimLineEnabled = val);
                  },
                ),
              ],
            ),
            actions: [
              SteampunkButton(
                label: 'APPLY & CLOSE',
                icon: Icons.done,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191310),
      body: Stack(
        children: [
          // 1. Dark Victorian / Steampunk gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.3),
                  radius: 1.2,
                  colors: [
                    Color(0xFF332219),
                    Color(0xFF1E140F),
                    Color(0xFF0F0A07),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // 2. Animated Interlocking Clockwork Gears
          const Positioned.fill(
            child: ClockworkGears(),
          ),

          // 3. Subtle vignette overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 4. Main Foreground Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // Top Decorative Wing / Cog Crest
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 40, height: 2, color: const Color(0xFFB8860B)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.settings, color: Color(0xFFFFD54F), size: 24),
                        ),
                        Container(width: 40, height: 2, color: const Color(0xFFB8860B)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Steampunk Brass Title Plaque
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF4E342E),
                            Color(0xFF2B1D15),
                            Color(0xFF1E140A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Main Title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFFFF9C4),
                                Color(0xFFFFD54F),
                                Color(0xFFDAA520),
                                Color(0xFFB8860B),
                              ],
                              stops: [0.0, 0.35, 0.7, 1.0],
                            ).createShader(bounds),
                            child: const Text(
                              'CHRONO BUBBLE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.2,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Subtitle Banner
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3E2723),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFB8860B), width: 1.0),
                            ),
                            child: const Text(
                              'CLOCKWORK ODYSSEY',
                              style: TextStyle(
                                color: Color(0xFFFFECB3),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Centerpiece: Steampunk Cannon & Gem Bubbles Showcase
                    const SteampunkShowcase(),

                    const SizedBox(height: 28),

                    // Primary Play Button
                    _buildPrimaryPlayButton(),

                    const SizedBox(height: 14),

                    // Secondary Buttons (How to play & Settings)
                    Row(
                      children: [
                        Expanded(
                          child: SteampunkButton(
                            label: 'HOW TO PLAY',
                            icon: Icons.menu_book,
                            isPrimary: false,
                            onPressed: _showHowToPlay,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SteampunkButton(
                            label: 'SETTINGS',
                            icon: Icons.tune,
                            isPrimary: false,
                            onPressed: _showSettings,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Footer / Version
                    const Text(
                      'COMPONENT-BASED ARCHITECTURE • FLAME ENGINE',
                      style: TextStyle(
                        color: Color(0xFF8D6E63),
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryPlayButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFECB3),
            Color(0xFFFFD54F),
            Color(0xFFDAA520),
            Color(0xFFB8860B),
          ],
          stops: [0.0, 0.25, 0.65, 1.0],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFF9C4), width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x60FFD54F),
            blurRadius: 18,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _startGame,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.play_circle_fill,
                color: Color(0xFF271A15),
                size: 32,
              ),
              SizedBox(width: 10),
              Text(
                'START EXPEDITION',
                style: TextStyle(
                  color: Color(0xFF271A15),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
