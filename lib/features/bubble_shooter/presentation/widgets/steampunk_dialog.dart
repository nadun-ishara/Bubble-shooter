import 'package:flutter/material.dart';
import '../../../../core/theme/steampunk_theme.dart';

class SteampunkDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final List<Widget> actions;

  const SteampunkDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 330,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: SteampunkTheme.plaqueGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SteampunkTheme.polishedBrass, width: 2.2),
            boxShadow: SteampunkTheme.darkDepthsShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Brass Ornamental Title Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFB8860B),
                      Color(0xFFFFD54F),
                      Color(0xFFB8860B),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 4),
                  ],
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2B1D15),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: SteampunkTheme.lightAmber,
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 18),
              content,
              const SizedBox(height: 20),

              // Action buttons
              Column(
                children: actions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
