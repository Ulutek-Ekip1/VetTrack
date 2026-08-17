class AppBreakpoints {
  const AppBreakpoints._();

  static const double compact = 720;
  static const double expandedNavigation = 1100;

  static bool isCompact(double width) => width < compact;

  static bool usesExpandedNavigation(double width) =>
      width >= expandedNavigation;
}
