import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final List<Customer> _customers = [];

  List<Customer> get customers => List.unmodifiable(_customers);

  CustomerProvider() {
    _loadCustomers();
  }

  // Load customers from SharedPreferences
  Future<void> _loadCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customersJson = prefs.getStringList('customers') ?? [];
      
      _customers.clear();
      for (var json in customersJson) {
        _customers.add(Customer.fromJson(jsonDecode(json)));
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading customers: $e');
    }
  }

  // Save customers to SharedPreferences
  Future<void> _saveCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customersJson = _customers
          .map((c) => jsonEncode(c.toJson()))
          .toList();
      await prefs.setStringList('customers', customersJson);
    } catch (e) {
      print('Error saving customers: $e');
    }
  }

  // Add new customer
  Future<void> addCustomer(String name) async {
    final newCustomer = Customer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    
    _customers.add(newCustomer);
    await _saveCustomers();
    notifyListeners();
  }

  // Get customer by ID
  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update customer
  Future<void> updateCustomer(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
      await _saveCustomers();
      notifyListeners();
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String id) async {
    _customers.removeWhere((c) => c.id == id);
    await _saveCustomers();
    notifyListeners();
  }

  // Get all customers sorted by name
  List<Customer> getAllCustomersSorted() {
    final sorted = List<Customer>.from(_customers);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }
}
