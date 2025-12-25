import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';
import '../models/category.dart';
import '../../core/constants/app_constants.dart';

class MemberProvider extends ChangeNotifier {
  List<Member> _members = [];
  String? _selectedMemberId;

  List<Member> get members => _members;
  Member? get selectedMember {
    if (_selectedMemberId == null) return null;
    try {
      return _members.firstWhere((m) => m.id == _selectedMemberId);
    } catch (e) {
      debugPrint('Error getting selected member: $e');
      return null;
    }
  }

  // Initialize with default members
  Future<void> initialize() async {
    await loadMembers();

    // Jika belum ada member, buat dengan struktur baru
    if (_members.isEmpty) {
      await _createDefaultMembers();
    }

    // Select first member by default
    if (_members.isNotEmpty && _selectedMemberId == null) {
      _selectedMemberId = _members.first.id;
      notifyListeners();
    }
  }

  // TAMBAHKAN method baru ini untuk create default members
  Future<void> _createDefaultMembers() async {
    final memberConfigs = [
      {
        'name': 'PD RDFF',
        'categories': [
          CategoryType.meatLocal,
          CategoryType.meatImport,
          CategoryType.groceries,
          CategoryType.utilities,
          CategoryType.dining,
          CategoryType.savings,
          CategoryType.arisan,
        ],
      },
      {
        'name': 'Ayah',
        'categories': [
          CategoryType.groceries,
          CategoryType.utilities,
          CategoryType.dining,
          CategoryType.transport,
          CategoryType.entertainment,
          CategoryType.healthcare,
          CategoryType.education,
          CategoryType.savings,
          CategoryType.arisan,
          CategoryType.other,
        ],
      },
      {
        'name': 'Ibu',
        'categories': [
          CategoryType.groceries,
          CategoryType.utilities,
          CategoryType.dining,
          CategoryType.transport,
          CategoryType.entertainment,
          CategoryType.healthcare,
          CategoryType.education,
          CategoryType.savings,
          CategoryType.arisan,
          CategoryType.other,
        ],
      },
      {
        'name': 'Rendi',
        'categories': [
          CategoryType.groceries,
          CategoryType.utilities,
          CategoryType.dining,
          CategoryType.transport,
          CategoryType.entertainment,
          CategoryType.healthcare,
          CategoryType.education,
          CategoryType.savings,
          CategoryType.arisan,
          CategoryType.other,
        ],
      },
      {
        'name': 'Daffa',
        'categories': [
          CategoryType.groceries,
          CategoryType.utilities,
          CategoryType.dining,
          CategoryType.transport,
          CategoryType.entertainment,
          CategoryType.healthcare,
          CategoryType.education,
          CategoryType.savings,
          CategoryType.arisan,
          CategoryType.other,
        ],
      },
      {
        'name': 'Fauzan',
        'categories': [
          CategoryType.groceries,
          CategoryType.utilities,
          CategoryType.dining,
          CategoryType.transport,
          CategoryType.entertainment,
          CategoryType.healthcare,
          CategoryType.education,
          CategoryType.savings,
          CategoryType.arisan,
          CategoryType.other,
        ],
      },
      {
        'name': 'Farel',
        'categories': [
          CategoryType.groceries,
          CategoryType.utilities,
          CategoryType.dining,
          CategoryType.transport,
          CategoryType.entertainment,
          CategoryType.healthcare,
          CategoryType.education,
          CategoryType.savings,
          CategoryType.arisan,
          CategoryType.other,
        ],
      },
    ];

    for (final config in memberConfigs) {
      final member = Member(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: config['name'] as String,
        allowedCategories: config['categories'] as List<CategoryType>,
      );
      _members.add(member);
      // Delay agar ID unik
      await Future.delayed(const Duration(milliseconds: 10));
    }

    await _saveMembers();
    notifyListeners();
  }

  // Load members from storage
  Future<void> loadMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? membersJson = prefs.getString(AppConstants.keyMembers);

      if (membersJson != null) {
        final List<dynamic> decoded = jsonDecode(membersJson);
        _members = decoded.map((json) => Member.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading members: $e');
    }
  }

  // Save members to storage
  Future<void> _saveMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final membersJson = jsonEncode(
        _members.map((m) => m.toJson()).toList(),
      );
      await prefs.setString(AppConstants.keyMembers, membersJson);
    } catch (e) {
      debugPrint('Error saving members: $e');
    }
  }

  // Add new member
  Future<void> addMember(String name) async {
    final member = Member(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );

    _members.add(member);
    await _saveMembers();
    notifyListeners();
  }

  // Update member
  Future<void> updateMember(Member member) async {
    final index = _members.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      _members[index] = member;
      await _saveMembers();
      notifyListeners();
    }
  }

  // Delete member
  Future<void> deleteMember(String id) async {
    _members.removeWhere((m) => m.id == id);

    // If deleted member was selected, select first member
    if (_selectedMemberId == id && _members.isNotEmpty) {
      _selectedMemberId = _members.first.id;
    }

    await _saveMembers();
    notifyListeners();
  }

  // Select member
  void selectMember(String id) {
    _selectedMemberId = id;
    notifyListeners();
  }

  // Get member by id
  Member? getMemberById(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get categories for specific member
  List<Category> getCategoriesForMember(String memberId) {
    final member = getMemberById(memberId);
    if (member == null) return [];

    return Category.all
        .where((cat) => member.allowedCategories.contains(cat.type))
        .toList();
  }
}