import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/steampunk_theme.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/clockwork_gears_bg.dart';
import '../widgets/showcase_cannon.dart';
import '../widgets/steampunk_button.dart';
import '../widgets/steampunk_dialog.dart';
import 'game_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final gameBloc = context.read<GameBloc>();
    final high = await gameBloc.getHighScoreUseCase.repository.getHighScore();
    if (mounted) {
      setState(() => _highScore = high);
    }
  }

  void _startGame() {
    context.read<GameBloc>().add(const StartGameEvent(level: 1));
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GamePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      _loadHighScore();
    });
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
              icon: Icons.swap_horiz,
              title: 'Swap Ammo',
              description: 'Tap the reserve chamber on the left of the cannon to swap orbs.',
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
              title: 'Boiler Pressure',
              description: 'Misses lower the brass ceiling. Stop bubbles crossing the danger line!',
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
            border: Border.all(color: SteampunkTheme.polishedBrass, width: 1.0),
          ),
          child: Icon(icon, color: SteampunkTheme.brightGold, size: 18),
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
      builder: (context) => BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return SteampunkDialog(
            title: 'MECHANICAL SETTINGS',
            subtitle: 'Configure Workshop Parameters',
            content: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Sound Effects',
                    style: TextStyle(color: SteampunkTheme.lightAmber, fontSize: 15),
                  ),
                  activeThumbColor: SteampunkTheme.brightGold,
                  activeTrackColor: const Color(0xFFB8860B),
                  value: state.soundEnabled,
                  onChanged: (val) {
                    context.read<GameBloc>().add(const ToggleSoundEvent());
                  },
                ),
                SwitchListTile(
                  title: const Text(
                    'Aim Trajectory Guide',
                    style: TextStyle(color: SteampunkTheme.lightAmber, fontSize: 15),
                  ),
                  activeThumbColor: SteampunkTheme.brightGold,
                  activeTrackColor: const Color(0xFFB8860B),
                  value: state.aimLineEnabled,
                  onChanged: (val) {
                    context.read<GameBloc>().add(const ToggleAimLineEvent());
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
      backgroundColor: SteampunkTheme.darkBrassBg,
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
            child: ClockworkGearsBg(),
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
                        gradient: SteampunkTheme.plaqueGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SteampunkTheme.polishedBrass, width: 2.5),
                        boxShadow: SteampunkTheme.darkDepthsShadow,
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

                    const SizedBox(height: 16),

                    // High Score Record Plaque
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: SteampunkTheme.antiqueDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFB8860B), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFFFFD54F), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'BEST SCORE: $_highScore',
                            style: const TextStyle(
                              color: SteampunkTheme.lightAmber,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Centerpiece: Steampunk Cannon & Gem Bubbles Showcase
                    const ShowcaseCannon(),

                    const SizedBox(height: 26),

                    // Primary Play Button: START EXPEDITION
                    SteampunkButton(
                      label: 'START EXPEDITION',
                      icon: Icons.play_circle_fill,
                      isPrimary: true,
                      height: 60,
                      onPressed: _startGame,
                    ),

                    const SizedBox(height: 12),

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

                    const SizedBox(height: 16),

                    // Footer / Viva Architecture Credits
                    const Text(
                      'CLEAN ARCHITECTURE • BLOC STATE MANAGEMENT',
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
}
