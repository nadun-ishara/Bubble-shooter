import 'dart:math' as math;

class GameConfig {
  // Virtual resolution
  static const double gameWidth = 420.0;
  static const double gameHeight = 750.0;

  // Playfield boundaries
  static const double wallMarginLeft = 16.0;
  static const double wallMarginRight = gameWidth - 16.0;
  static const double ceilingY = 55.0; // below HUD
  static const double dangerY = 570.0; // if bubbles reach here, game over!

  // Hexagonal Bubble Grid metrics
  static const double bubbleRadius = 23.5;
  static const double bubbleDiameter = bubbleRadius * 2;
  static const double rowHeight = bubbleRadius * 1.7320508; // R * sqrt(3)
  static const int columnsEven = 8;
  static const int columnsOdd = 7;
  static const int initialRows = 5;
  static const int maxVisibleRows = 12;

  // Cannon / Shooter position
  static const double cannonX = gameWidth / 2;
  static const double cannonY = 675.0;
  static const double projectileSpeed = 1000.0;

  // Aim constraints (degrees clamped between 15° and 165° pointing up)
  static const double minAimAngle = 15.0 * (math.pi / 180.0);
  static const double maxAimAngle = 165.0 * (math.pi / 180.0);

  // Miss / Foul threshold before ceiling drops
  static const int missesBeforeCeilingDrop = 5;

  // Scoring
  static const int pointsPerBubblePop = 20;
  static const int pointsPerOrphanDrop = 50;
  static const int pointsComboBonus = 15;
}
