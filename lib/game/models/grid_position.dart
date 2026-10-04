import 'package:flame/extensions.dart';
import '../game_config.dart';

class GridPosition {
  final int row;
  final int col;

  const GridPosition(this.row, this.col);

  bool get isEvenRow => row % 2 == 0;
  int get maxCols => isEvenRow ? GameConfig.columnsEven : GameConfig.columnsOdd;

  /// Check if this grid position is within valid boundary bounds
  bool isValid([int maxRow = GameConfig.maxVisibleRows]) {
    if (row < 0 || row >= maxRow) return false;
    if (col < 0 || col >= maxCols) return false;
    return true;
  }

  /// Calculates the center Vector2 position in world space
  Vector2 toWorldPosition([double gridOffsetY = 0.0]) {
    final double playWidth = GameConfig.wallMarginRight - GameConfig.wallMarginLeft;
    final double r = GameConfig.bubbleRadius;
    final double d = GameConfig.bubbleDiameter;

    // Centering calculations
    final double evenTotalWidth = GameConfig.columnsEven * d;
    final double evenStartX = GameConfig.wallMarginLeft + (playWidth - evenTotalWidth) / 2 + r;

    final double x = isEvenRow
        ? evenStartX + col * d
        : evenStartX + r + col * d; // Offset by one radius for odd row

    final double y = GameConfig.ceilingY + gridOffsetY + r + row * GameConfig.rowHeight;

    return Vector2(x, y);
  }

  /// Returns the 6 adjacent hexagonal neighbor coordinates
  List<GridPosition> getNeighbors() {
    final List<GridPosition> neighbors = [];

    // Left and Right
    neighbors.add(GridPosition(row, col - 1));
    neighbors.add(GridPosition(row, col + 1));

    if (isEvenRow) {
      // Top neighbors for even row
      neighbors.add(GridPosition(row - 1, col - 1));
      neighbors.add(GridPosition(row - 1, col));
      // Bottom neighbors for even row
      neighbors.add(GridPosition(row + 1, col - 1));
      neighbors.add(GridPosition(row + 1, col));
    } else {
      // Top neighbors for odd row
      neighbors.add(GridPosition(row - 1, col));
      neighbors.add(GridPosition(row - 1, col + 1));
      // Bottom neighbors for odd row
      neighbors.add(GridPosition(row + 1, col));
      neighbors.add(GridPosition(row + 1, col + 1));
    }

    return neighbors;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'GridPosition(row: $row, col: $col)';
}
