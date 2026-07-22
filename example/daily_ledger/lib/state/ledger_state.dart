import 'package:flutter/foundation.dart' hide Category;
import 'package:fxdart/fxdart.dart' show fx;

import '../data/ledger_repository.dart';
import '../models/models.dart';

/// App-wide state: the loaded ledger + the currently viewed month.
/// Deliberately thin — all computation lives in `logic/`.
class LedgerState extends ChangeNotifier {
  final LedgerRepository _repo;

  LedgerState(this._repo);

  LedgerData? _data;
  final List<String> loadedBoxes = [];
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  bool get isLoading => _data == null;
  List<Entry> get entries => _data?.entries ?? const [];
  List<Category> get categories => _data?.categories ?? const [];
  List<RecurringRule> get rules => _data?.rules ?? const [];
  Map<String, double> get budgets => _data?.budgets ?? const {};
  DateTime get month => _month;
  DateTime get today => DateTime.now();

  // indexBy-built lookup, cached until the data changes (the fxdart answer
  // to the O(n) categoryById for-loop this replaced).
  Map<String, Category>? _categoryIndex;
  Map<String, Category> get categoryIndex =>
      _categoryIndex ??= fx(categories).indexBy((c) => c.id);

  Category? categoryById(String id) => categoryIndex[id];

  void _setData(LedgerData? data) {
    _data = data;
    _categoryIndex = null;
    notifyListeners();
  }

  Future<void> load() async {
    if (_repo.isEmpty) {
      await _repo.reseed(today);
    }
    _setData(await _repo.loadAll(onLoaded: (box) {
      loadedBoxes.add(box);
      notifyListeners();
    }));
  }

  Future<void> reseed() async {
    _setData(null);
    loadedBoxes.clear();
    await _repo.reseed(today);
    await load();
  }

  void goToMonth(int delta) {
    _month = DateTime(_month.year, _month.month + delta);
    notifyListeners();
  }

  void setMonth(DateTime month) {
    _month = DateTime(month.year, month.month);
    notifyListeners();
  }

  Future<void> upsertEntry(Entry entry) async {
    await _repo.putEntry(entry);
    final data = _data;
    if (data != null) {
      final without = data.entries.where((e) => e.id != entry.id).toList();
      _setData(data.copyWith(entries: without..add(entry)));
    }
  }

  Future<void> deleteEntry(String id) async {
    await _repo.deleteEntry(id);
    final data = _data;
    if (data != null) {
      _setData(data.copyWith(
          entries: data.entries.where((e) => e.id != id).toList()));
    }
  }

  Future<void> setBudget(String categoryId, double amount) async {
    await _repo.putBudget(categoryId, amount);
    final data = _data;
    if (data != null) {
      _setData(data.copyWith(budgets: {...data.budgets, categoryId: amount}));
    }
  }

  Future<void> setBudgets(Map<String, double> budgets) async {
    await _repo.putBudgets(budgets);
    final data = _data;
    if (data != null) {
      _setData(data.copyWith(budgets: {...data.budgets, ...budgets}));
    }
  }

  Future<void> toggleDone(Entry entry) =>
      upsertEntry(entry.copyWith(done: !entry.done));
}
