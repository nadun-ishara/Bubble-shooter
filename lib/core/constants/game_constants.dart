import 'dart:math' as math;

class GameConstants {
  // Virtual game dimensions (9:16 aspect ratio standard for arcade shooter)
  static const double virtualWidth = 420.0;
  static const double virtualHeight = 780.0;

  // Playfield boundaries
  static const double wallMarginLeft = 14.0;
  static const double wallMarginRight = virtualWidth - 14.0;
  static const double ceilingBaseY = 70.0; // below HUD
  static const double dangerLineY = 610.0; // danger threshold

  // Hexagonal Bubble Grid metrics
  static const double bubbleRadius = 23.5;
  static const double bubbleDiameter = bubbleRadius * 2;
  static const double rowHeight = bubbleRadius * 1.7320508; // R * sqrt(3)
  static const int columnsEven = 8;
  static const int columnsOdd = 7;
  static const int initialRows = 5;
  static const int maxVisibleRows = 13;

  // Cannon & Projectile
  static const double cannonX = virtualWidth / 2;
  static const double cannonY = 705.0;
  static const double projectileSpeed = 1200.0; // smooth and fast

  // Aim constraints (aiming upward only: between -165° and -15°)
  static const double minAimAngle = -165.0 * (math.pi / 180.0);
  static const double maxAimAngle = -15.0 * (math.pi / 180.0);

  // Pressure mechanic
  static const int maxFoulsBeforeDrop = 5;

  // Scoring
  static const int pointsPerBubblePop = 25;
  static const int pointsPerOrphanDrop = 60;
  static const int comboMultiplierBonus = 10;
}
