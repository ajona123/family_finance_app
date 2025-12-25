class AppConstants {
  // 📱 APP INFO
  static const String appName = 'Family Finance';
  static const String appVersion = '1.0.0';

  // 🎨 SPACING
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // 📐 BORDER RADIUS
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 999.0;

  // 🎯 CATEGORIES
  static const List<String> categories = [
    'Daging Lokal',
    'Daging Import',
    'Jajan',
    'Sekolah',
    'Tabungan',
    'Arisan',
    'Lainnya',
  ];

  static const Map<String, String> categoryIcons = {
    'Daging Lokal': '🥩',
    'Daging Import': '🥩',
    'Jajan': '🍜',
    'Sekolah': '🎓',
    'Tabungan': '💰',
    'Arisan': '🤝',
    'Lainnya': '📦',
  };

  // 🥩 MEAT CUTS (Potongan daging)
  static const List<String> meatCuts = [
    'Has Dalam',
    'Has Luar',
    'Sirloin',
    'Tenderloin',
    'Rib Eye',
    'T-Bone',
    'Cube Roll',
    'Striploin',
    'Sengkel',
    'Sandung Lamur',
    'Iga',
    'Sampil',
    'Daging Giling',
    'Lainnya',
  ];

  // 👨‍👩‍👧‍👦 DEFAULT MEMBERS
  static const List<String> defaultMembers = [
    'Ayah',
    'Ibu',
    'Anak 1',
    'Anak 2',
  ];

  // 💾 STORAGE KEYS
  static const String keyMembers = 'members';
  static const String keyTransactions = 'transactions';
  static const String keySettings = 'settings';
  static const String keyOnboarding = 'onboarding_completed';

  // 🔢 LIMITS
  static const int maxTransactionsPerPage = 20;
  static const int maxMeatItems = 10;
  static const double maxTransactionAmount = 999999999;
}