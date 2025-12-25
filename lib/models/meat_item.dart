class MeatItem {
  String type;
  String? customType;
  double weight;
  double pricePerKg;

  MeatItem({
    required this.type,
    this.customType,
    this.weight = 0,
    this.pricePerKg = 0,
  });

  double get total => weight * pricePerKg;

  String get displayType => type == 'Lainnya' ? (customType ?? 'Lainnya') : type;

  bool get isValid => weight > 0 && pricePerKg > 0;

  MeatItem copyWith({
    String? type,
    String? customType,
    double? weight,
    double? pricePerKg,
  }) {
    return MeatItem(
      type: type ?? this.type,
      customType: customType ?? this.customType,
      weight: weight ?? this.weight,
      pricePerKg: pricePerKg ?? this.pricePerKg,
    );
  }
}