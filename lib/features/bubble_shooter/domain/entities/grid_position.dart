import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/game_constants.dart';

@immutable
class GridPosition extends Equatable {
  final int row;
  final int col;

  const GridPosition(this.row, this.col);

  bool get isEvenRow => row % 2 == 0;
  int get maxCols => isEvenRow ? GameConstants.columnsEven : GameConstants.columnsOdd;

  bool isValid([int maxRow = GameConstants.maxVisibleRows]) {
    if (row < 0 || row >= maxRow) return false;
    if (col < 0 || col >= maxCols) return false;
    return true;
  }

  /// Calculates center (x, y) coordinates in virtual resolution space
  (double x, double y) toWorldCoordinates([double gridOffsetY = 0.0]) {
    const playWidth = GameConstants.wallMarginRight - GameConstants.wallMarginLeft;
    const r = GameConstants.bubbleRadius;
    const d = GameConstants.bubbleDiameter;

    const evenTotalWidth = GameConstants.columnsEven * d;
    const evenStartX = GameConstants.wallMarginLeft + (playWidth - evenTotalWidth) / 2 + r;

    final double x = isEvenRow ? (evenStartX + col * d) : (evenStartX + r + col * d);
    final double y = GameConstants.ceilingBaseY + gridOffsetY + r + row * GameConstants.rowHeight;

    return (x, y);
  }

  /// Returns 6 hexagonal neighbors
  List<GridPosition> getNeighbors() {
    final neighbors = <GridPosition>[];

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
  List<Object?> get props => [row, col];

  @override
  String toString() => 'GridPosition(row: $row, col: $col)';
}
