import 'meat_item.dart';

class Transaction {
  final String id;
  final String member;
  final String type; // 'pemasukan' or 'pengeluaran'
  final String category;
  final double amount;
  final List<MeatItem>? meatItems;
  final String notes;
  final DateTime date;

  Transaction({
    required this.id,
    required this.member,
    required this.type,
    required this.category,
    required this.amount,
    this.meatItems,
    this.notes = '',
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member': member,
      'type': type,
      'category': category,
      'amount': amount,
      'meatItems': meatItems?.map((item) => {
        'type': item.type,
        'customType': item.customType,
        'weight': item.weight,
        'pricePerKg': item.pricePerKg,
      }).toList(),
      'notes': notes,
      'date': date.toIso8601String(),
    };
  }
}