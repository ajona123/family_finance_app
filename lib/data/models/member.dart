import 'category.dart';

class Member {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final List<CategoryType> allowedCategories;

  Member({
    required this.id,
    required this.name,
    this.avatarUrl,
    DateTime? createdAt,
    List<CategoryType>? allowedCategories,
  }) : createdAt = createdAt ?? DateTime.now(),
       allowedCategories = allowedCategories ?? CategoryType.values;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'allowedCategories': allowedCategories.map((c) => c.toString()).toList(),
    };
  }

  // Create from JSON
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      allowedCategories: json['allowedCategories'] != null
          ? (json['allowedCategories'] as List)
              .map((c) => CategoryType.values.firstWhere(
                    (type) => type.toString() == c,
                  ))
              .toList()
          : CategoryType.values,
    );
  }

  // Get initials untuk avatar
  String get initials {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  // Copy with
  Member copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    List<CategoryType>? allowedCategories,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      allowedCategories: allowedCategories ?? this.allowedCategories,
    );
  }
}