/// Core data model. One [Entry] covers expenses, income, bills, and tasks —
/// which is why every screen in the app is an aggregation over `List<Entry>`.
library;

enum EntryType {
  expense,
  income,
  task, // todo with optional dueDate; `done` = completed
  bill; // expense with a dueDate; `done` = paid

  bool get isMoney => this == expense || this == income || this == bill;

  String get label => switch (this) {
        expense => 'Expense',
        income => 'Income',
        task => 'Task',
        bill => 'Bill',
      };
}

enum CategoryKind { money, task }

enum RecurrencePeriod { weekly, monthly }

class Entry {
  final String id;
  final String title;
  final EntryType type;
  final double? amount; // null for pure tasks
  final String categoryId;
  final List<String> tags;
  final DateTime date; // when it happened / was created
  final DateTime? dueDate; // bills & tasks
  final bool done; // tasks: completed, bills: paid
  final String? recurringRuleId;

  const Entry({
    required this.id,
    required this.title,
    required this.type,
    this.amount,
    required this.categoryId,
    this.tags = const [],
    required this.date,
    this.dueDate,
    this.done = false,
    this.recurringRuleId,
  });

  /// Signed money value: income is positive, expense/bill negative, task 0.
  double get signedAmount => switch (type) {
        EntryType.income => amount ?? 0,
        EntryType.expense || EntryType.bill => -(amount ?? 0),
        EntryType.task => 0,
      };

  // Sentinel so copyWith can also *clear* nullable fields
  // (`copyWith(dueDate: null)` really sets null instead of being ignored).
  static const Object _unset = Object();

  Entry copyWith({
    String? id,
    String? title,
    EntryType? type,
    Object? amount = _unset,
    String? categoryId,
    List<String>? tags,
    DateTime? date,
    Object? dueDate = _unset,
    bool? done,
    Object? recurringRuleId = _unset,
  }) =>
      Entry(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        amount: identical(amount, _unset) ? this.amount : amount as double?,
        categoryId: categoryId ?? this.categoryId,
        tags: tags ?? this.tags,
        date: date ?? this.date,
        dueDate: identical(dueDate, _unset) ? this.dueDate : dueDate as DateTime?,
        done: done ?? this.done,
        recurringRuleId: identical(recurringRuleId, _unset)
            ? this.recurringRuleId
            : recurringRuleId as String?,
      );

  @override
  String toString() => 'Entry($id, $title, ${type.name}, $amount, $date)';
}

class Category {
  final String id;
  final String name;
  final int iconCodePoint; // Material icon code point
  final int colorSeed; // ARGB
  final CategoryKind kind;

  const Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorSeed,
    required this.kind,
  });
}

class RecurringRule {
  final String id;
  final RecurrencePeriod period;
  final DateTime anchorDate;

  const RecurringRule({
    required this.id,
    required this.period,
    required this.anchorDate,
  });
}
