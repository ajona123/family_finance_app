import 'package:flutter/foundation.dart';
import '../models/arisan.dart';

class ArisanProvider extends ChangeNotifier {
  List<Arisan> _arisans = [];

  List<Arisan> get arisans => _arisans;

  // Add new arisan
  void addArisan(Arisan arisan) {
    _arisans.add(arisan);
    notifyListeners();
  }

  // Update arisan
  void updateArisan(Arisan arisan) {
    final index = _arisans.indexWhere((a) => a.id == arisan.id);
    if (index != -1) {
      _arisans[index] = arisan;
      notifyListeners();
    }
  }

  // Delete arisan
  void deleteArisan(String arisanId) {
    _arisans.removeWhere((a) => a.id == arisanId);
    notifyListeners();
  }

  // Get arisan by ID
  Arisan? getArisanById(String arisanId) {
    try {
      return _arisans.firstWhere((a) => a.id == arisanId);
    } catch (e) {
      return null;
    }
  }

  // Get active arisans
  List<Arisan> getActiveArisans() {
    return _arisans.where((a) => a.status == 'active').toList();
  }

  // Get upcoming arisans (next 30 days)
  List<Arisan> getUpcomingArisans() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thirtyDaysLater = today.add(const Duration(days: 30));
    
    return getActiveArisans().where((a) {
      final nextPayment = a.getNextPaymentDate();
      return (nextPayment.isAtSameMomentAs(today) || nextPayment.isAfter(today)) && nextPayment.isBefore(thirtyDaysLater);
    }).toList()..sort((a, b) => a.getNextPaymentDate().compareTo(b.getNextPaymentDate()));
  }

  // Get arisans for specific month
  List<Arisan> getArisansForMonth(int year, int month) {
    return getActiveArisans().where((a) {
      final nextPayment = a.getNextPaymentDate();
      return nextPayment.year == year && nextPayment.month == month;
    }).toList();
  }

  // Add payment record
  void addArisanPayment(String arisanId, ArisanPayment payment) {
    final arisan = getArisanById(arisanId);
    if (arisan != null) {
      arisan.paymentHistory.add(payment);
      updateArisan(arisan);
    }
  }

  // Clear all data
  void clearData() {
    _arisans = [];
    notifyListeners();
  }

  // Initialize dummy data
  void initializeDummyData() {
    _arisans = [
      Arisan(
        id: 'arisan_001',
        name: 'Arisan Bulanan',
        memberId: 'member_1',
        startDate: DateTime.now(),
        cycleLengthMonths: 12,
        monthlyAmount: 50000,
        participantMemberIds: ['member_1', 'member_2', 'member_3'],
        userPosition: 1,
        paymentHistory: [],
        status: 'active',
        createdAt: DateTime.now(),
      ),
      Arisan(
        id: 'arisan_002',
        name: 'Arisan Pendidikan',
        memberId: 'member_2',
        startDate: DateTime.now(),
        cycleLengthMonths: 24,
        monthlyAmount: 100000,
        participantMemberIds: ['member_1', 'member_2', 'member_4'],
        userPosition: 2,
        paymentHistory: [],
        status: 'active',
        createdAt: DateTime.now(),
      ),
    ];
    notifyListeners();
  }
}
