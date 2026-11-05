import 'package:flutter/widgets.dart';

/// Corner radii: 8 inputs/chips, 12 buttons, 16 cards, 24 sheets.
abstract final class AppRadius {
  /// Radius value for inputs and chips.
  static const double input = 8;

  /// Radius value for buttons.
  static const double button = 12;

  /// Radius value for cards.
  static const double card = 16;

  /// Radius value for bottom sheets and header bottoms.
  static const double sheet = 24;

  /// Border radius for inputs and chips.
  static const BorderRadius inputAll = BorderRadius.all(Radius.circular(input));

  /// Border radius for buttons.
  static const BorderRadius buttonAll = BorderRadius.all(
    Radius.circular(button),
  );

  /// Border radius for cards.
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));

  /// Border radius for the top corners of bottom sheets.
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );

  /// Border radius for the bottom corners of navy headers.
  static const BorderRadius headerBottom = BorderRadius.vertical(
    bottom: Radius.circular(sheet),
  );

  /// Fully rounded (pill) radius.
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}
