import 'package:flutter/material.dart';

extension ExpandedRowExt on Widget {
  Widget inExpandedRow({
    MainAxisSize mainAxisSize = MainAxisSize.min,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  }) {
    return Row(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: [Expanded(child: this)],
    );
  }
}

extension ExpandedColumnExt on Widget {
  Widget inExpandedColumn({
    MainAxisSize mainAxisSize = MainAxisSize.min,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  }) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: [Expanded(child: this)],
    );
  }
}

extension PaddingExt on Widget {
  /// Adds padding to all sides
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Adds symmetric horizontal and vertical padding
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  /// Adds padding to specific sides
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    ),
    child: this,
  );
}

extension ResponsiveContext on BuildContext {
  /// The full screen width (swaps automatically on rotation)
  double get width => MediaQuery.sizeOf(this).width;

  /// The full screen height (swaps automatically on rotation)
  double get height => MediaQuery.sizeOf(this).height;

  /// The width MINUS the safe area (notches, etc.)
  /// Useful for ensuring content doesn't get cut off in landscape
  double get safeWidth => width - MediaQuery.paddingOf(this).horizontal;

  /// The height MINUS the safe area (status bar, home indicator)
  double get safeHeight => height - MediaQuery.paddingOf(this).vertical;

  /// Quick check for landscape orientation
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;
}
