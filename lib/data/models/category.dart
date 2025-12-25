import 'package:flutter/material.dart';
import 'transaction.dart';

enum CategoryType {
  meatLocal,
  meatImport,
  pelangganRdff,
  supplierDebt,
  groceries,
  utilities,
  dining,
  transport,
  entertainment,
  healthcare,
  education,
  savings,
  arisan,
  debtPayment,
  supplierPayment,
  other,
}

class Category {
  final CategoryType type;
  final String name;
  final String emoji;
  final Color color;
  final bool requiresMeatDetails;

  const Category({
    required this.type,
    required this.name,
    required this.emoji,
    required this.color,
    this.requiresMeatDetails = false,
  });

  // Get category by type
  static Category getByType(CategoryType type) {
    try {
      return all.firstWhere((cat) => cat.type == type);
    } catch (e) {
      // Fallback to 'other' category if not found
      return all.firstWhere((cat) => cat.type == CategoryType.other);
    }
  }

  // Determine if category is income or expense
  static TransactionType getDefaultType(CategoryType category) {
    const incomeCategories = {
      CategoryType.pelangganRdff,
      CategoryType.debtPayment,
      CategoryType.arisan,
    };
    
    return incomeCategories.contains(category) 
        ? TransactionType.income 
        : TransactionType.expense;
  }

  // All available categories
  static const List<Category> all = [
    Category(
      type: CategoryType.meatLocal,
      name: 'Daging Lokal',
      emoji: '🥩',
      color: Color(0xFFFF6B6B),
      requiresMeatDetails: true,
    ),
    Category(
      type: CategoryType.meatImport,
      name: 'Daging Import',
      emoji: '🥩',
      color: Color(0xFFFF5252),
      requiresMeatDetails: true,
    ),
    Category(
      type: CategoryType.pelangganRdff,
      name: 'Pelanggan RDFF',
      emoji: '👥',
      color: Color(0xFF42A5F5),
    ),
    Category(
      type: CategoryType.supplierDebt,
      name: 'Supplier Daging',
      emoji: '🏪',
      color: Color(0xFFEF5350),
    ),
    Category(
      type: CategoryType.utilities,
      name: 'Listrik & Air',
      emoji: '💡',
      color: Color(0xFFFFD54F),
    ),
    Category(
      type: CategoryType.dining,
      name: 'Makan & Minum',
      emoji: '🍽️',
      color: Color(0xFFEF5350),
    ),
    Category(
      type: CategoryType.transport,
      name: 'Transportasi',
      emoji: '🚗',
      color: Color(0xFF42A5F5),
    ),
    Category(
      type: CategoryType.entertainment,
      name: 'Hiburan',
      emoji: '🎬',
      color: Color(0xFF7E57C2),
    ),
    Category(
      type: CategoryType.healthcare,
      name: 'Kesehatan',
      emoji: '⚕️',
      color: Color(0xFF26A69A),
    ),
    Category(
      type: CategoryType.education,
      name: 'Pendidikan',
      emoji: '📚',
      color: Color(0xFF5C6BC0),
    ),
    Category(
      type: CategoryType.savings,
      name: 'Menabung',
      emoji: '💰',
      color: Color(0xFF66BB6A),
    ),
    Category(
      type: CategoryType.arisan,
      name: 'Arisan',
      emoji: '🤝',
      color: Color(0xFFAB47BC),
    ),
    Category(
      type: CategoryType.debtPayment,
      name: 'Pembayaran Hutang',
      emoji: '💳',
      color: Color(0xFF29B6F6),
    ),
    Category(
      type: CategoryType.supplierPayment,
      name: 'Pembayaran Supplier',
      emoji: '💳',
      color: Color(0xFF26A69A),
    ),
    Category(
      type: CategoryType.other,
      name: 'Lainnya',
      emoji: '📌',
      color: Color(0xFF78909C),
    ),
  ];
}
