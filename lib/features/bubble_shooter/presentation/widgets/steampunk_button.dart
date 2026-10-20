import 'package:flutter/material.dart';
import '../../../../core/theme/steampunk_theme.dart';
import '../../../../core/utils/audio_helper.dart';

class SteampunkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double height;

  const SteampunkButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      height: height,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? SteampunkTheme.brassButtonGradient
            : SteampunkTheme.brassDarkButtonGradient,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPrimary ? const Color(0xFFFFF8E1) : SteampunkTheme.polishedBrass,
          width: 1.6,
        ),
        boxShadow: isPrimary
            ? SteampunkTheme.brassGlowShadow
            : const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AudioHelper.playSwap();
            onPressed();
          },
          borderRadius: BorderRadius.circular(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? const Color(0xFF2B1D15) : SteampunkTheme.brightGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? const Color(0xFF2B1D15) : SteampunkTheme.lightAmber,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
