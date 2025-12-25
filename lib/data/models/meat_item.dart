class MeatItem {
  final String id;
  final String cutName; // Nama potongan (Has Dalam, Sirloin, dll)
  final double weight; // Berat dalam kg
  final double pricePerKg; // Harga per kg
  final String? supplier; // Supplier: Ucup, Bewok, Miki (lokal) atau Nasruloh, Alan (impor)

  MeatItem({
    String? id,
    required this.cutName,
    required this.weight,
    required this.pricePerKg,
    this.supplier,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Calculate total price
  double get totalPrice => weight * pricePerKg;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cutName': cutName,
      'weight': weight,
      'pricePerKg': pricePerKg,
      'supplier': supplier,
    };
  }

  // Create from JSON
  factory MeatItem.fromJson(Map<String, dynamic> json) {
    return MeatItem(
      id: json['id'],
      cutName: json['cutName'],
      weight: (json['weight'] as num).toDouble(),
      pricePerKg: (json['pricePerKg'] as num).toDouble(),
      supplier: json['supplier'],
    );
  }

  // Copy with
  MeatItem copyWith({
    String? id,
    String? cutName,
    double? weight,
    double? pricePerKg,
    String? supplier,
  }) {
    return MeatItem(
      id: id ?? this.id,
      cutName: cutName ?? this.cutName,
      weight: weight ?? this.weight,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      supplier: supplier ?? this.supplier,
    );
  }

  // Format weight display
  String get weightDisplay {
    return '${weight.toStringAsFixed(2)} kg';
  }
}