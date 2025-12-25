import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_helper.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _migrationComplete = false;

  List<Transaction> get transactions => _transactions;
  bool get migrationComplete => _migrationComplete;

  // Get transactions sorted by date (newest first)
  List<Transaction> get sortedTransactions {
    final sorted = List<Transaction>.from(_transactions);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  // Initialize
  Future<void> initialize() async {
    await loadTransactions();
  }

  // Load transactions from storage
  Future<void> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsJson = prefs.getString(AppConstants.keyTransactions);

      if (transactionsJson != null) {
        final List<dynamic> decoded = jsonDecode(transactionsJson);
        bool needsSave = false;
        int migratedCount = 0;
        
        debugPrint('📊 Loading ${decoded.length} transactions...');
        
        _transactions = decoded.map((json) {
          final txn = Transaction.fromJson(json);
          
          // Get correct type based on category
          final correctType = Category.getDefaultType(txn.category);
          
          // ALWAYS fix type - don't check if it's already correct
          debugPrint('  → ${txn.category.name}: Amount: ${txn.amount} | Current: ${txn.type.name} | Should be: ${correctType.name}');
          
          // Migration: Always apply correct type based on category
          if (txn.type != correctType) {
            migratedCount++;
            debugPrint('    ✓ CONVERTING ${txn.type.name} → ${correctType.name}');
            needsSave = true;
          }
          
          return Transaction(
            id: txn.id,
            memberId: txn.memberId,
            type: correctType, // Always set correct type
            category: txn.category,
            amount: txn.amount,
            note: txn.note,
            meatItems: txn.meatItems,
            customerId: txn.customerId,
            paymentStatus: txn.paymentStatus,
            remainingAmount: txn.remainingAmount,
            createdAt: txn.createdAt,
          );
        }).toList();
        
        // Save migrated data back to storage
        if (needsSave) {
          await _saveTransactions();
          debugPrint('✅ SAVED: $migratedCount transactions fixed');
        }
        
        debugPrint('📈 Final summary:');
        final incomeCount = _transactions.where((t) => t.isIncome).length;
        final expenseCount = _transactions.where((t) => t.isExpense).length;
        debugPrint('   Income: $incomeCount | Expense: $expenseCount');
        
        _migrationComplete = true;
        notifyListeners();
      } else {
        debugPrint('ℹ️ No transactions in storage');
        _migrationComplete = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error loading transactions: $e');
      _migrationComplete = true;
      notifyListeners();
    }
  }

  // Save transactions to storage
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = jsonEncode(
        _transactions.map((t) => t.toJson()).toList(),
      );
      await prefs.setString(AppConstants.keyTransactions, transactionsJson);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  // Add transaction
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _saveTransactions();
    notifyListeners();
  }

  // Update transaction
  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _saveTransactions();
      notifyListeners();
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveTransactions();
    notifyListeners();
  }

  // Get transactions by member
  List<Transaction> getTransactionsByMember(String memberId) {
    return _transactions.where((t) => t.memberId == memberId).toList();
  }

  // Get transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return !t.createdAt.isBefore(start) && !t.createdAt.isAfter(end);
    }).toList();
  }

  // Get transactions for current month
  List<Transaction> get currentMonthTransactions {
    final start = DateHelper.getStartOfMonth();
    final end = DateHelper.getEndOfMonth();
    return getTransactionsByDateRange(start, end);
  }

  // Calculate total income
  double getTotalIncome([List<Transaction>? transactions]) {
    final txns = transactions ?? _transactions;
    return txns
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Calculate total expense
  double getTotalExpense([List<Transaction>? transactions]) {
    final txns = transactions ?? _transactions;
    return txns
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Calculate balance
  double getBalance([List<Transaction>? transactions]) {
    final txns = transactions ?? _transactions;
    return getTotalIncome(txns) - getTotalExpense(txns);
  }

  // Get balance for current month
  double get currentMonthBalance {
    return getBalance(currentMonthTransactions);
  }

  // Get total by category
  Map<CategoryType, double> getCategoryTotals([List<Transaction>? transactions]) {
    final txns = transactions ?? _transactions;
    final Map<CategoryType, double> totals = {};

    for (final category in CategoryType.values) {
      totals[category] = txns
          .where((t) => t.category == category && t.isExpense)
          .fold(0, (sum, t) => sum + t.amount);
    }

    return totals;
  }

  // Get recent transactions (limit)
  List<Transaction> getRecentTransactions([int limit = 10]) {
    final sorted = sortedTransactions;
    return sorted.take(limit).toList();
  }

  // Get transactions grouped by date
  Map<String, List<Transaction>> get transactionsGroupedByDate {
    final Map<String, List<Transaction>> grouped = {};

    for (final transaction in sortedTransactions) {
      String dateKey;

      if (DateHelper.isToday(transaction.createdAt)) {
        dateKey = 'Hari Ini';
      } else if (DateHelper.isYesterday(transaction.createdAt)) {
        dateKey = 'Kemarin';
      } else {
        dateKey = DateHelper.formatDate(transaction.createdAt);
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  // Get transactions by customer ID
  List<Transaction> getTransactionsByCustomer(String customerId) {
    return _transactions
        .where((t) => t.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get transactions by supplier ID
  List<Transaction> getTransactionsBySupplier(String supplierId) {
    return _transactions
        .where((t) => t.supplierId == supplierId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Calculate percentage change from previous month
  double getMonthlyChangePercentage() {
    final currentMonth = currentMonthTransactions;
    final currentBalance = getBalance(currentMonth);

    final now = DateTime.now();
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
    final lastMonth = getTransactionsByDateRange(lastMonthStart, lastMonthEnd);
    final lastBalance = getBalance(lastMonth);

    if (lastBalance == 0) return 0;

    return ((currentBalance - lastBalance) / lastBalance) * 100;
  }

  // Process debt payment - otomatis handle pembayaran hutang
  Future<DebtPaymentResult> processDebtPayment({
    required String memberId,
    required String customerId,
    required double paymentAmount,
    String? note,
  }) async {
    // Get all unpaid transactions from this customer
    final unPaidTransactions = _transactions
        .where((t) =>
            t.category == CategoryType.pelangganRdff &&
            t.customerId == customerId &&
            t.paymentStatus == 'unpaid' &&
            (t.remainingAmount ?? 0) > 0)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // FIFO

    if (unPaidTransactions.isEmpty) {
      return DebtPaymentResult(
        success: false,
        message: 'Tidak ada hutang untuk pelanggan ini',
        fullyPaidCustomers: [],
      );
    }

    double remainingPayment = paymentAmount;
    List<String> fullyPaidCustomers = [];
    bool customerIsFullyPaid = false;
    int paymentNumber = 1;

    // Process pembayaran ke transaksi-transaksi
    for (var txn in unPaidTransactions) {
      if (remainingPayment <= 0) break;

      final currentDebt = txn.remainingAmount ?? 0;
      final debtToPay = remainingPayment >= currentDebt ? currentDebt : remainingPayment;

      // Update remaining amount
      final newRemainingAmount = currentDebt - debtToPay;
      final newPaymentStatus = newRemainingAmount <= 0 ? 'lunas' : 'unpaid';

      final updatedTxn = Transaction(
        id: txn.id,
        memberId: txn.memberId,
        type: txn.type,
        category: txn.category,
        amount: txn.amount,
        note: txn.note,
        meatItems: txn.meatItems,
        customerId: txn.customerId,
        paymentStatus: newPaymentStatus,
        remainingAmount: newRemainingAmount <= 0 ? 0 : newRemainingAmount,
        createdAt: txn.createdAt,
      );

      await updateTransaction(updatedTxn);

      // Create payment record transaction
      final paymentRecord = Transaction(
        memberId: memberId,
        type: TransactionType.income,
        category: CategoryType.debtPayment,
        amount: debtToPay,
        note: note,
        customerId: customerId,
      );
      await addTransaction(paymentRecord);

      remainingPayment -= debtToPay;
      paymentNumber++;

      if (newPaymentStatus == 'lunas') {
        customerIsFullyPaid = true;
      }
    }

    if (customerIsFullyPaid) {
      fullyPaidCustomers.add(customerId);
    }

    return DebtPaymentResult(
      success: true,
      message: 'Pembayaran berhasil diproses',
      fullyPaidCustomers: fullyPaidCustomers,
      paymentAmount: paymentAmount,
    );
  }

  // Process supplier payment - identik dengan processDebtPayment tapi untuk supplier
  Future<SupplierPaymentResult> processSupplierPayment({
    required String memberId,
    required String supplierId,
    required double paymentAmount,
    String? note,
  }) async {
    // Get all unpaid transactions from this supplier (including meat transactions)
    final unPaidTransactions = _transactions
        .where((t) =>
            (t.category == CategoryType.supplierDebt ||
             t.category == CategoryType.meatLocal ||
             t.category == CategoryType.meatImport) &&
            t.supplierId == supplierId &&
            t.paymentStatus == 'unpaid' &&
            (t.remainingAmount ?? 0) > 0)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // FIFO

    if (unPaidTransactions.isEmpty) {
      return SupplierPaymentResult(
        success: false,
        message: 'Tidak ada hutang untuk supplier ini',
        fullyPaidSuppliers: [],
      );
    }

    double remainingPayment = paymentAmount;
    List<String> fullyPaidSuppliers = [];
    bool supplierIsFullyPaid = false;
    int paymentNumber = 1;

    // Process pembayaran ke transaksi-transaksi
    for (var txn in unPaidTransactions) {
      if (remainingPayment <= 0) break;

      final currentDebt = txn.remainingAmount ?? 0;
      final debtToPay = remainingPayment >= currentDebt ? currentDebt : remainingPayment;

      // Update remaining amount
      final newRemainingAmount = currentDebt - debtToPay;
      final newPaymentStatus = newRemainingAmount <= 0 ? 'lunas' : 'unpaid';

      final updatedTxn = Transaction(
        id: txn.id,
        memberId: txn.memberId,
        type: txn.type,
        category: txn.category,
        amount: txn.amount,
        note: txn.note,
        meatItems: txn.meatItems,
        supplierId: txn.supplierId,
        paymentStatus: newPaymentStatus,
        remainingAmount: newRemainingAmount <= 0 ? 0 : newRemainingAmount,
        createdAt: txn.createdAt,
      );

      await updateTransaction(updatedTxn);

      // Create payment record transaction
      final paymentRecord = Transaction(
        memberId: memberId,
        type: TransactionType.expense,
        category: CategoryType.supplierPayment,
        amount: debtToPay,
        note: note,
        supplierId: supplierId,
      );
      await addTransaction(paymentRecord);

      remainingPayment -= debtToPay;
      paymentNumber++;

      if (newPaymentStatus == 'lunas') {
        supplierIsFullyPaid = true;
      }
    }

    if (supplierIsFullyPaid) {
      fullyPaidSuppliers.add(supplierId);
    }

    return SupplierPaymentResult(
      success: true,
      message: 'Pembayaran berhasil diproses',
      fullyPaidSuppliers: fullyPaidSuppliers,
      paymentAmount: paymentAmount,
    );
  }
}

// Model untuk hasil pembayaran hutang supplier
class SupplierPaymentResult {
  final bool success;
  final String message;
  final List<String> fullyPaidSuppliers;
  final double? paymentAmount;

  SupplierPaymentResult({
    required this.success,
    required this.message,
    required this.fullyPaidSuppliers,
    this.paymentAmount,
  });
}

// Model untuk hasil pembayaran hutang
class DebtPaymentResult {
  final bool success;
  final String message;
  final List<String> fullyPaidCustomers;
  final double? paymentAmount;

  DebtPaymentResult({
    required this.success,
    required this.message,
    required this.fullyPaidCustomers,
    this.paymentAmount,
  });
}