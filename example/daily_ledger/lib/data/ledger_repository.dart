/// The "dumb shelf": Hive in, plain lists out. No filtering, no aggregation —
/// all data work lives in `logic/` as fxdart pipelines.
///
/// Each box read is wrapped in an artificial delay so the startup
/// `toAsync().map(...).concurrent(3)` load is an honest concurrency demo
/// without a network dependency.
library;

import 'package:fxdart/fxdart.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/adapters.dart';
import '../models/models.dart';
import 'seed.dart';

class LedgerData {
  final List<Entry> entries;
  final List<Category> categories;
  final List<RecurringRule> rules;
  final Map<String, double> budgets; // categoryId -> monthly budget

  const LedgerData({
    required this.entries,
    required this.categories,
    required this.rules,
    required this.budgets,
  });

  LedgerData copyWith({List<Entry>? entries, Map<String, double>? budgets}) =>
      LedgerData(
        entries: entries ?? this.entries,
        categories: categories,
        rules: rules,
        budgets: budgets ?? this.budgets,
      );
}

class LedgerRepository {
  static const boxLatency = Duration(milliseconds: 400);

  static Future<void> init() async {
    await Hive.initFlutter('daily_ledger');
    Hive
      ..registerAdapter(EntryAdapter())
      ..registerAdapter(CategoryAdapter())
      ..registerAdapter(RecurringRuleAdapter());
    await Future.wait([
      Hive.openBox<Entry>('entries'),
      Hive.openBox<Category>('categories'),
      Hive.openBox<RecurringRule>('rules'),
      Hive.openBox<double>('budgets'), // doubles need no adapter
    ]);
  }

  Box<Entry> get _entries => Hive.box<Entry>('entries');
  Box<Category> get _categories => Hive.box<Category>('categories');
  Box<RecurringRule> get _rules => Hive.box<RecurringRule>('rules');
  Box<double> get _budgets => Hive.box<double>('budgets');

  /// Loads all four boxes "concurrently": with `concurrent(3)` the simulated
  /// reads overlap and the whole load takes ~2× [boxLatency] instead of ~4×.
  /// Change `concurrent(3)` to `concurrent(1)` to feel the difference in the
  /// startup screen.
  Future<LedgerData> loadAll({void Function(String box)? onLoaded}) async {
    final loaded = await fx(['entries', 'categories', 'rules', 'budgets'])
        .toAsync()
        .map((box) => delay(boxLatency, box)) // simulated slow IO per box
        .peek((box) => onLoaded?.call(box))
        .concurrent(3)
        .toList();
    assert(loaded.length == 4);
    return LedgerData(
      entries: _entries.values.toList(),
      categories: _categories.values.toList(),
      rules: _rules.values.toList(),
      budgets: _budgets.toMap().cast<String, double>(),
    );
  }

  Future<void> putEntry(Entry entry) => _entries.put(entry.id, entry);

  Future<void> deleteEntry(String id) => _entries.delete(id);

  Future<void> putBudget(String categoryId, double amount) =>
      _budgets.put(categoryId, amount);

  Future<void> putBudgets(Map<String, double> budgets) =>
      _budgets.putAll(budgets);

  bool get isEmpty => _entries.isEmpty;

  /// Wipes and reseeds the demo data.
  Future<void> reseed(DateTime today) async {
    await Future.wait([
      _entries.clear(),
      _categories.clear(),
      _rules.clear(),
      _budgets.clear(),
    ]);
    final entries = seedEntries(today);
    await _entries.putAll({for (final e in entries) e.id: e});
    await _categories.putAll({for (final c in seedCategories()) c.id: c});
    await _rules.putAll({for (final r in seedRules(today)) r.id: r});
    await _budgets.putAll(seedBudgets());
  }
}
