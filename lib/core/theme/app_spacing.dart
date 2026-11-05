/// Spacing scale (4/8/12/16/20/24/32/40) used for padding and gaps.
abstract final class AppSpacing {
  /// 4 px.
  static const double xxs = 4;

  /// 8 px.
  static const double xs = 8;

  /// 12 px.
  static const double sm = 12;

  /// 16 px — default screen gutter.
  static const double md = 16;

  /// 20 px.
  static const double lg = 20;

  /// 24 px.
  static const double xl = 24;

  /// 32 px.
  static const double xxl = 32;

  /// 40 px.
  static const double xxxl = 40;
}

/// Fixed component sizes, layout breakpoints and stroke widths.
abstract final class AppSizes {
  /// Height of inputs and buttons.
  static const double controlHeight = 52;

  /// Minimum touch target for any tappable element.
  static const double minTouchTarget = 48;

  /// Small icon size (inline with labels and chips).
  static const double iconSm = 16;

  /// Default icon size.
  static const double iconMd = 20;

  /// Large icon size (card icons, banners).
  static const double iconLg = 24;

  /// Spinner diameter inside buttons.
  static const double buttonSpinner = 20;

  /// Stroke width of the button spinner.
  static const double spinnerStroke = 2;

  /// Default border width.
  static const double borderThin = 1;

  /// Border width of focused inputs and selected cards.
  static const double borderThick = 2;

  /// Height of the segmented step progress bar.
  static const double progressBarHeight = 4;

  /// Gap between progress bar segments.
  static const double progressSegmentGap = 4;

  /// Width at which Splash and Login centre in a fixed column.
  static const double tabletBreakpoint = 600;

  /// Width at which Onboarding shows the side step rail.
  static const double wideBreakpoint = 900;

  /// Maximum content width for centred single-column screens.
  static const double contentMaxWidth = 440;

  /// Size of the square logo slot in an integration card.
  static const double integrationLogo = 40;

  /// Size of the icon tile in a selectable card.
  static const double cardIconTile = 40;

  /// Height of small in-row buttons (the tap target is padded to 48).
  static const double compactButtonHeight = 36;

  /// Height of the bottom navigation bar.
  static const double navigationBarHeight = 68;

  /// Small logo tile (headers).
  static const double logoSm = 32;

  /// Medium logo tile (default lock-up).
  static const double logoMd = 40;

  /// Large logo tile (splash).
  static const double logoLg = 88;

  /// Diameter of the soft teal glow behind the splash logo.
  static const double splashGlow = 320;

  /// Stroke width of the splash "call ring" ripples.
  static const double splashRingStroke = 2;

  /// Height of the splash progress line.
  static const double splashProgressHeight = 2;

  /// Distance the splash wordmark slides up while fading in.
  static const double splashWordmarkSlide = 12;

  /// Maximum width of onboarding content next to the step rail.
  static const double onboardingContentMaxWidth = 640;

  /// Diameter of the success check circle.
  static const double successCheck = 96;

  /// Stroke width of the success check mark.
  static const double successCheckStroke = 6;

  /// Horizontal slide distance (fraction of width) for step transitions.
  static const double stepSlideFraction = 0.15;
}
