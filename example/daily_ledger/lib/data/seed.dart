/// Deterministic demo fixtures, generated with fxdart:
/// `createSeededRandom` for reproducible randomness, `range` + `flatMap`
/// to lay entries out over ~6 months, `shuffle(seed:)` for stable variety.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';

const seedValue = 20260723;

List<Category> seedCategories() => const [
      Category(id: 'salary', name: 'Salary', iconCodePoint: 0xe25c, colorSeed: 0xFF2E7D32, kind: CategoryKind.money),
      Category(id: 'groceries', name: 'Groceries', iconCodePoint: 0xe395, colorSeed: 0xFF00897B, kind: CategoryKind.money),
      Category(id: 'dining', name: 'Dining', iconCodePoint: 0xe532, colorSeed: 0xFFF4511E, kind: CategoryKind.money),
      Category(id: 'transport', name: 'Transport', iconCodePoint: 0xe1d5, colorSeed: 0xFF3949AB, kind: CategoryKind.money),
      Category(id: 'housing', name: 'Housing', iconCodePoint: 0xe318, colorSeed: 0xFF6D4C41, kind: CategoryKind.money),
      Category(id: 'utilities', name: 'Utilities', iconCodePoint: 0xe1ab, colorSeed: 0xFFFB8C00, kind: CategoryKind.money),
      Category(id: 'fun', name: 'Entertainment', iconCodePoint: 0xe40f, colorSeed: 0xFF8E24AA, kind: CategoryKind.money),
      Category(id: 'health', name: 'Health', iconCodePoint: 0xe3c8, colorSeed: 0xFFE53935, kind: CategoryKind.money),
      Category(id: 'chores', name: 'Chores', iconCodePoint: 0xe156, colorSeed: 0xFF546E7A, kind: CategoryKind.task),
      Category(id: 'work', name: 'Work', iconCodePoint: 0xe6f0, colorSeed: 0xFF1E88E5, kind: CategoryKind.task),
      Category(id: 'personal', name: 'Personal', iconCodePoint: 0xe491, colorSeed: 0xFF00ACC1, kind: CategoryKind.task),
    ];

/// Default monthly budgets per money category (Round 1 feature).
Map<String, double> seedBudgets() => {
      'groceries': 450,
      'dining': 300,
      'transport': 120,
      'fun': 150,
      'utilities': 160,
      'health': 250,
      'housing': 1200,
    };

List<RecurringRule> seedRules(DateTime today) => [
      RecurringRule(
        id: 'rule-rent',
        period: RecurrencePeriod.monthly,
        anchorDate: DateTime(today.year, today.month, 1),
      ),
      RecurringRule(
        id: 'rule-gym',
        period: RecurrencePeriod.weekly,
        anchorDate: today.subtract(Duration(days: today.weekday - 1)),
      ),
    ];

const _groceryTitles = ['Supermarket run', 'Farmers market', 'Corner store', 'Bulk store haul'];
const _diningTitles = ['Lunch out', 'Coffee & pastry', 'Dinner with friends', 'Takeout pizza', 'Brunch'];
const _funTitles = ['Movie night', 'Concert tickets', 'Game on sale', 'Museum visit'];
const _taskTitles = ['Water the plants', 'Call the bank', 'Book dentist', 'Clean the desk', 'Review budget', 'Back up laptop', 'Reply to landlord', 'Plan weekend trip'];

/// Generates ~6 months of history plus a couple of weeks of upcoming
/// bills/tasks. Fully deterministic for a given [today].
List<Entry> seedEntries(DateTime today) {
  final rand = createSeededRandom(seedValue);
  final day0 = DateTime(today.year, today.month, today.day);
  double amount(num base, num spread) => ((base + rand() * spread) * 100).roundToDouble() / 100;
  String pickTitle(List<String> titles) => titles[(rand() * titles.length).floor()];

  // Daily spending & tasks, laid out over the past 180 days with flatMap.
  final daily = fx(range(0, 180)).flatMap((back) {
    final day = DateTime(day0.year, day0.month, day0.day - back);
    final isWeekend = day.weekday >= DateTime.saturday;
    return [
      if (rand() < 0.34)
        Entry(
          id: 'gro-$back',
          title: pickTitle(_groceryTitles),
          type: EntryType.expense,
          amount: amount(18, 45),
          categoryId: 'groceries',
          tags: const ['food'],
          date: day,
        ),
      if (rand() < (isWeekend ? 0.55 : 0.3))
        Entry(
          id: 'din-$back',
          title: pickTitle(_diningTitles),
          type: EntryType.expense,
          amount: amount(9, 32),
          categoryId: 'dining',
          tags: const ['food', 'social'],
          date: day,
        ),
      if (!isWeekend && rand() < 0.6)
        Entry(
          id: 'tra-$back',
          title: 'Transit fare',
          type: EntryType.expense,
          amount: amount(2.5, 4),
          categoryId: 'transport',
          tags: const ['commute'],
          date: day,
        ),
      if (isWeekend && rand() < 0.3)
        Entry(
          id: 'fun-$back',
          title: pickTitle(_funTitles),
          type: EntryType.expense,
          amount: amount(12, 50),
          categoryId: 'fun',
          tags: const ['leisure', 'social'],
          date: day,
        ),
      if (rand() < 0.18)
        Entry(
          id: 'tsk-$back',
          title: pickTitle(_taskTitles),
          type: EntryType.task,
          categoryId: rand() < 0.5 ? 'chores' : 'personal',
          tags: const ['todo'],
          date: day,
          dueDate: DateTime(day.year, day.month, day.day + (rand() * 10).floor()),
          done: rand() < 0.7,
        ),
    ];
  });

  // Monthly fixtures: salary, rent, utilities — one bundle per month.
  final monthly = fx(range(0, 7)).flatMap((m) {
    final month = DateTime(day0.year, day0.month - m, 1);
    bool isPast(int d) => DateTime(month.year, month.month, d).isBefore(day0);
    return [
      Entry(
        id: 'sal-$m',
        title: 'Monthly salary',
        type: EntryType.income,
        amount: 3200,
        categoryId: 'salary',
        tags: const ['fixed'],
        date: DateTime(month.year, month.month, 25),
      ),
      Entry(
        id: 'rent-$m',
        title: 'Rent',
        type: EntryType.bill,
        amount: 1150,
        categoryId: 'housing',
        tags: const ['fixed', 'home'],
        date: DateTime(month.year, month.month, 1),
        dueDate: DateTime(month.year, month.month, 1),
        done: isPast(1),
        recurringRuleId: 'rule-rent',
      ),
      Entry(
        id: 'util-$m',
        title: 'Electricity & water',
        type: EntryType.bill,
        amount: amount(60, 55),
        categoryId: 'utilities',
        tags: const ['fixed', 'home'],
        date: DateTime(month.year, month.month, 12),
        dueDate: DateTime(month.year, month.month, 18),
        done: isPast(18),
      ),
    ];
  });

  // Upcoming: bills and tasks due in the next two weeks (some overdue on
  // purpose so the dashboard's partition demo has both halves).
  final upcoming = [
    Entry(
      id: 'up-internet',
      title: 'Internet bill',
      type: EntryType.bill,
      amount: 49.99,
      categoryId: 'utilities',
      tags: const ['fixed', 'home'],
      date: day0,
      dueDate: DateTime(day0.year, day0.month, day0.day + 5),
    ),
    Entry(
      id: 'up-insurance',
      title: 'Health insurance',
      type: EntryType.bill,
      amount: 210,
      categoryId: 'health',
      tags: const ['fixed'],
      date: DateTime(day0.year, day0.month, day0.day - 9),
      dueDate: DateTime(day0.year, day0.month, day0.day - 2), // overdue!
    ),
    Entry(
      id: 'up-taxes',
      title: 'File quarterly taxes',
      type: EntryType.task,
      categoryId: 'work',
      tags: const ['deadline'],
      date: DateTime(day0.year, day0.month, day0.day - 12),
      dueDate: DateTime(day0.year, day0.month, day0.day - 3), // overdue!
    ),
    Entry(
      id: 'up-gift',
      title: 'Buy birthday gift',
      type: EntryType.task,
      categoryId: 'personal',
      tags: const ['social'],
      date: day0,
      dueDate: DateTime(day0.year, day0.month, day0.day + 3),
    ),
  ];

  // A seeded shuffle keeps insertion order arbitrary-but-stable, proving the
  // pipelines never rely on storage order.
  return shuffle(daily.concat(monthly).concat(upcoming), seedValue);
}
