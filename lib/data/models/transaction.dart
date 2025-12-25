import 'category.dart';
import 'meat_item.dart';

enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String id;
  final String memberId;
  final TransactionType type;
  final CategoryType category;
  final double amount;
  final String? note;
  final List<MeatItem>? meatItems; // Khusus untuk kategori daging
  final String? customerId; // Untuk kategori Pelanggan RDFF
  final String? supplierId; // Untuk kategori Supplier (pembelian daging)
  final String? arisanId; // Untuk kategori Arisan (pelunasan arisan)
  final String? paymentStatus; // 'lunas' atau 'unpaid'
  final double? remainingAmount; // Jumlah sisa jika belum lunas
  final DateTime createdAt;

  Transaction({
    String? id,
    required this.memberId,
    required this.type,
    required this.category,
    required this.amount,
    this.note,
    this.meatItems,
    this.customerId,
    this.supplierId,
    this.arisanId,
    this.paymentStatus,
    this.remainingAmount,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  // Check if transaction has meat items
  bool get hasMeatItems => meatItems != null && meatItems!.isNotEmpty;

  // Get total from meat items
  double get meatItemsTotal {
    if (!hasMeatItems) return 0;
    return meatItems!.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'type': type.name,
      'category': category.name,
      'amount': amount,
      'note': note,
      'meatItems': meatItems?.map((item) => item.toJson()).toList(),
      'customerId': customerId,
      'supplierId': supplierId,
      'arisanId': arisanId,
      'paymentStatus': paymentStatus,
      'remainingAmount': remainingAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      memberId: json['memberId'],
      type: TransactionType.values.firstWhere(
            (e) => e.name == json['type'],
      ),
      category: CategoryType.values.firstWhere(
            (e) => e.name == json['category'],
      ),
      amount: (json['amount'] as num).toDouble(),
      note: json['note'],
      meatItems: json['meatItems'] != null
          ? (json['meatItems'] as List)
          .map((item) => MeatItem.fromJson(item))
          .toList()
          : null,
      customerId: json['customerId'],
      supplierId: json['supplierId'],
      arisanId: json['arisanId'],
      paymentStatus: json['paymentStatus'],
      remainingAmount: json['remainingAmount'] != null
          ? (json['remainingAmount'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Copy with
  Transaction copyWith({
    String? id,
    String? memberId,
    TransactionType? type,
    CategoryType? category,
    double? amount,
    String? note,
    List<MeatItem>? meatItems,
    String? customerId,
    String? supplierId,
    String? arisanId,
    String? paymentStatus,
    double? remainingAmount,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      meatItems: meatItems ?? this.meatItems,
      customerId: customerId ?? this.customerId,
      supplierId: supplierId ?? this.supplierId,
      arisanId: arisanId ?? this.arisanId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get category info
  Category get categoryInfo => Category.getByType(category);

  // Check if income or expense
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  // Get signed amount (negative for expense)
  double get signedAmount => isExpense ? -amount : amount;
}