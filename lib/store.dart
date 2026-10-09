import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class ReplioStore extends ChangeNotifier {
  static const _itemsKey = 'replio_items_v1';
  static const _historyKey = 'replio_history_v1';
  static const _darkKey = 'replio_dark_v1';

  bool ready = false;
  bool darkMode = false;

  final List<RefillItem> _items = [];
  final List<RefillEvent> _history = [];

  List<RefillItem> get items => List.unmodifiable(_items);

  List<RefillEvent> get history {
    final copy = [..._history];
    copy.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(copy);
  }

  int get lowCount => _items
      .where(
        (item) =>
            item.status == StockStatus.low ||
            item.status == StockStatus.refillNow ||
            item.status == StockStatus.out,
      )
      .length;

  int get stockedCount =>
      _items.where((item) => item.status == StockStatus.good).length;

  int get refilledThisWeek {
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    return _history.where((event) => event.date.isAfter(threshold)).length;
  }

  List<RefillItem> get refillList {
    final result = _items
        .where(
          (item) =>
              item.status == StockStatus.refillNow ||
              item.status == StockStatus.out ||
              item.status == StockStatus.low,
        )
        .toList();

    result.sort((a, b) {
      final byStatus = _statusRank(a.status).compareTo(_statusRank(b.status));
      if (byStatus != 0) return byStatus;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return result;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    darkMode = prefs.getBool(_darkKey) ?? false;

    final rawItems = prefs.getString(_itemsKey);
    final rawHistory = prefs.getString(_historyKey);

    _items.clear();
    _history.clear();

    if (rawItems != null && rawItems.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawItems) as List<dynamic>;
        _items.addAll(
          decoded.map(
            (entry) => RefillItem.fromMap(
              Map<String, dynamic>.from(entry as Map),
            ),
          ),
        );
      } catch (_) {}
    }

    if (rawHistory != null && rawHistory.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawHistory) as List<dynamic>;
        _history.addAll(
          decoded.map(
            (entry) => RefillEvent.fromMap(
              Map<String, dynamic>.from(entry as Map),
            ),
          ),
        );
      } catch (_) {}
    }

    ready = true;
    notifyListeners();
  }

  Future<void> addItem(RefillItem item) async {
    _items.add(item);
    await _saveItems();
    notifyListeners();
  }

  Future<void> updateItem(RefillItem item) async {
    final index = _items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) return;

    _items[index] = item;
    await _saveItems();
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _saveItems();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _items[index];
    _items[index] = item.copyWith(favorite: !item.favorite);

    await _saveItems();
    notifyListeners();
  }

  Future<void> useOne(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _items[index];
    final next = (item.quantity - 1).clamp(0, double.infinity).toDouble();

    _items[index] = item.copyWith(quantity: next);

    await _saveItems();
    notifyListeners();
  }

  Future<void> refillItem({
    required String id,
    required double amount,
  }) async {
    if (amount <= 0) return;

    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _items[index];
    final now = DateTime.now();

    _items[index] = item.copyWith(
      quantity: item.quantity + amount,
      lastRefillDate: now,
    );

    _history.add(
      RefillEvent(
        id: '${now.microsecondsSinceEpoch}',
        itemId: item.id,
        itemName: item.name,
        addedQuantity: amount,
        unit: item.unit,
        date: now,
      ),
    );

    await Future.wait([
      _saveItems(),
      _saveHistory(),
    ]);

    notifyListeners();
  }

  Future<void> removeHistoryEvent(String id) async {
    _history.removeWhere((event) => event.id == id);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
    notifyListeners();
  }

  Future<void> resetAll() async {
    _items.clear();
    _history.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_itemsKey);
    await prefs.remove(_historyKey);

    notifyListeners();
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((item) => item.toMap()).toList());
    await prefs.setString(_itemsKey, encoded);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_history.map((event) => event.toMap()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  int _statusRank(StockStatus status) {
    switch (status) {
      case StockStatus.out:
        return 0;
      case StockStatus.refillNow:
        return 1;
      case StockStatus.low:
        return 2;
      case StockStatus.good:
        return 3;
    }
  }
}
