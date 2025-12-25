class AppConstants {
  // Family Members
  static const List<String> familyMembers = [
    'Ayah',
    'Ibu',
    'Kakak',
    'Adik',
    'Paman',
    'Bibi',
  ];

  // Categories
  static const List<Map<String, String>> categories = [
    {'id': 'daging-lokal', 'label': 'Daging Lokal', 'icon': '🥩'},
    {'id': 'daging-import', 'label': 'Daging Import', 'icon': '🥓'},
    {'id': 'jajan', 'label': 'Jajan', 'icon': '🍔'},
    {'id': 'sekolah', 'label': 'Sekolah / Kuliah', 'icon': '📚'},
    {'id': 'tabungan', 'label': 'Tabungan', 'icon': '💰'},
    {'id': 'arisan', 'label': 'Arisan', 'icon': '🎲'},
  ];

  // Meat Types
  static const List<String> meatTypes = [
    'Daging',
    'Babat',
    'Jeroan',
    'Tetelan',
    'Lemak',
    'Tulang',
    'Lainnya',
  ];

  // Quick Amounts
  static const List<int> quickAmounts = [
    10000,
    20000,
    50000,
    100000,
    200000,
  ];

  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration successDuration = Duration(seconds: 2);
}