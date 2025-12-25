class AnimationDurations {
  // Fast animations (UI feedback)
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration fastPlus = Duration(milliseconds: 200);

  // Medium animations (transitions)
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration mediumPlus = Duration(milliseconds: 400);

  // Slow animations (page transitions, complex animations)
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slowPlus = Duration(milliseconds: 600);

  // Very slow (onboarding, major transitions)
  static const Duration verySlow = Duration(milliseconds: 800);
  static const Duration verySlowPlus = Duration(milliseconds: 1000);

  // Delays
  static const Duration shortDelay = Duration(milliseconds: 100);
  static const Duration mediumDelay = Duration(milliseconds: 200);
  static const Duration longDelay = Duration(milliseconds: 300);

  // Shimmer & Loading
  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration loading = Duration(milliseconds: 2000);
}