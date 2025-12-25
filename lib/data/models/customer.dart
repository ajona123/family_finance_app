class Customer {
  final String id;
  final String name;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // Create from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy with
  Customer copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Customer(id: $id, name: $name, createdAt: $createdAt)';
}
