/// Field validators (typed-errors series, round 10).
///
/// **Scope-first**, exactly as the `either & Raise scope` lecture teaches:
/// each validator takes the raise scope `r` and returns the *parsed value* —
/// never an `Either`. That is what lets the same five functions serve two
/// opposite policies without a line of duplication:
///
/// - CSV import composes them **fail-fast** (`logic/import.dart`): the first
///   bad field ends the row.
/// - the entry form composes them **fail-slow** (round 11): all five run and
///   every problem is reported at once.
///
/// Had they returned `Either`, the fail-slow caller would have to unpack and
/// re-pack each one. Returning the value and raising into an ambient scope is
/// the difference.
library;

import 'package:fxdart/fxdart.dart';

import '../models/models.dart';
import 'errors.dart';

/// `YYYY-MM-DD`, 1-or-2-digit month/day accepted (export always pads).
final _ymdPattern = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$');

/// Category lookup keyed the way rows name categories: display name,
/// case-insensitive (what `entriesToCsv` writes).
Map<String, Category> categoryIndex(List<Category> categories) =>
    fx(categories).indexBy((c) => c.name.toLowerCase());

DateTime vDate(Raise<FieldError> r, String raw, {String field = 'date'}) {
  final match = r.ensureNotNull(
    _ymdPattern.firstMatch(raw.trim()),
    () => FieldError(field, 'want YYYY-MM-DD, got "$raw"'),
  );
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime(year, month, day);
  // `DateTime` rolls over silently — DateTime(2026, 2, 30) is March 2nd, and
  // round 7's importer accepted it. The round-trip check is what turns that
  // into a reported error instead of a wrong entry.
  r.ensure(
    date.year == year && date.month == month && date.day == day,
    () => FieldError(field, 'not a real date: "$raw"'),
  );
  return date;
}

EntryType vType(Raise<FieldError> r, String raw, {String field = 'type'}) =>
    r.ensureNotNull(
      find((EntryType t) => t.name == raw.trim(), EntryType.values),
      () => FieldError(
        field,
        'unknown type "$raw" — want '
        '${join('|', map((EntryType t) => t.name, EntryType.values))}',
      ),
    );

String vTitle(Raise<FieldError> r, String raw, {String field = 'title'}) {
  final title = raw.trim();
  r.ensure(title.isNotEmpty, () => FieldError(field, 'must not be empty'));
  return title;
}

/// The **type-independent** half: is the cell a usable amount at all?
/// Empty is not an error here — `null` means "no money on this entry".
///
/// Split out from [vAmount] because accumulation needs *independent*
/// branches, and "does an expense require an amount?" depends on the type
/// branch. See `parseRowAll` in `logic/import.dart`.
double? vAmountValue(
  Raise<FieldError> r,
  String raw, {
  String field = 'amount',
}) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  // `ensureNotNull` returns non-null: Dart's flow analysis knows `raise`
  // returns Never, so no `!` is needed below.
  final amount = r.ensureNotNull(
    double.tryParse(text),
    () => FieldError(field, 'not a number: "$raw"'),
  );
  r.ensure(amount > 0, () => FieldError(field, 'must be greater than 0'));
  return amount;
}

/// The **type-dependent** half: only a task may go without an amount.
void vAmountRequired(
  Raise<FieldError> r,
  double? amount,
  EntryType type, {
  String field = 'amount',
}) => r.ensure(
  amount != null || type == EntryType.task,
  () => FieldError(field, '${type.name} needs an amount'),
);

/// Both halves in one scope — what a caller wants when the type is already
/// known and fail-fast is fine (the CSV row, the entry form).
double? vAmount(
  Raise<FieldError> r,
  String raw,
  EntryType type, {
  String field = 'amount',
}) {
  final amount = vAmountValue(r, raw, field: field);
  vAmountRequired(r, amount, type, field: field);
  return amount;
}

Category vCategory(
  Raise<FieldError> r,
  String raw,
  Map<String, Category> known, {
  String field = 'category',
}) => r.ensureNotNull(
  known[raw.trim().toLowerCase()],
  () => FieldError(field, 'unknown category "$raw"'),
);

/// Total — an empty or malformed tag cell is not a failure, it is no tags.
List<String> parseTags(String raw) =>
    raw.split('|').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

// ---------------------------------------------------------------------------
// Entry form (round 11). The CSV importer names categories by display name;
// the form picks an id from a dropdown, so it needs its own lookup — but the
// other four validators above are shared verbatim.
// ---------------------------------------------------------------------------

Category vCategoryId(
  Raise<FieldError> r,
  String? id,
  EntryType type,
  Map<String, Category> byId, {
  String field = 'category',
}) {
  final category = r.ensureNotNull(
    id == null ? null : byId[id],
    () => FieldError(field, 'pick a category'),
  );
  final wanted = type == EntryType.task
      ? CategoryKind.task
      : CategoryKind.money;
  r.ensure(
    category.kind == wanted,
    () => FieldError(
      field,
      '"${category.name}" is a ${category.kind.name} category, but this is '
      'a ${type.label.toLowerCase()}',
    ),
  );
  return category;
}

/// A due date may be absent, but it may not precede the entry itself —
/// the same invariant the Health audit will check across the whole ledger.
DateTime? vDueDate(
  Raise<FieldError> r,
  DateTime? due,
  DateTime date, {
  String field = 'dueDate',
}) {
  if (due == null) return null;
  r.ensure(
    !due.isBefore(DateTime(date.year, date.month, date.day)),
    () => FieldError(field, 'due date is before the entry date'),
  );
  return due;
}

/// The form's tag input is comma-separated. `|` is rejected because CSV
/// export joins tags with it — a tag containing `|` would silently become
/// two tags on the next export→import round-trip.
List<String> vTags(Raise<FieldError> r, String raw, {String field = 'tags'}) {
  final tags = raw
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();
  final piped = tags.where((t) => t.contains('|')).toList();
  r.ensure(
    piped.isEmpty,
    () => FieldError(
      field,
      'a tag cannot contain "|" — CSV export uses it as the separator '
      '(${piped.join(', ')})',
    ),
  );
  r.ensure(
    tags.toSet().length == tags.length,
    () => FieldError(field, 'duplicate tags'),
  );
  return tags;
}

/// A monthly budget limit. Unlike an entry amount, blank is not "no money" —
/// a budget with no number is not a budget.
double vBudgetLimit(
  Raise<FieldError> r,
  String raw, {
  String field = 'amount',
}) => r.ensureNotNull(
  vAmountValue(r, raw, field: field),
  () => FieldError(field, 'enter a monthly limit'),
);

/// The budget editor's raw state.
class BudgetDraft {
  final String? categoryId;
  final String amount;
  const BudgetDraft({required this.categoryId, required this.amount});
}

/// Two independent fields, so both are reported at once — picking a task
/// category *and* typing a bad number should not take two attempts to fix.
///
/// The category check is [vCategoryId] with `EntryType.expense`, because
/// "budgets apply to money categories" is the same rule as "an expense needs
/// a money category". One validator, two callers.
EitherNel<FieldError, (Category, double)> validateBudget(
  BudgetDraft d,
  Map<String, Category> byId,
) => either<Nel<FieldError>, (Category, double)>(
  (r) => r.zipOrAccumulate2(
    (fr) => vCategoryId(fr, d.categoryId, EntryType.expense, byId),
    (fr) => vBudgetLimit(fr, d.amount),
    (category, limit) => (category, limit),
  ),
);

/// The entry form's raw state: strings and enums straight off the widgets.
///
/// Validation is a pure function of this value rather than of a
/// `GlobalKey<FormState>`, which is what makes it unit-testable and lets the
/// same draft run through two different policies (see [validateDraft] and
/// [validateDraftFailFast]).
class EntryDraft {
  final String id;
  final String title;
  final EntryType type;

  /// Raw text; `''` when the type carries no money.
  final String amount;
  final String? categoryId;

  /// Raw comma-separated text.
  final String tags;
  final DateTime date;
  final DateTime? dueDate;
  final bool done;
  final String? recurringRuleId;

  const EntryDraft({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.tags,
    required this.date,
    this.dueDate,
    this.done = false,
    this.recurringRuleId,
  });
}

Entry _entryFrom(
  EntryDraft d, {
  required String title,
  required double? amount,
  required Category category,
  required DateTime? dueDate,
  required List<String> tags,
}) => Entry(
  id: d.id,
  title: title,
  type: d.type,
  amount: amount,
  categoryId: category.id,
  tags: tags,
  date: d.date,
  dueDate: dueDate,
  done: d.done,
  recurringRuleId: d.recurringRuleId,
);

/// **Fail-slow**: every field is checked and *all* the problems come back.
///
/// This is the one thing `try`/`catch` structurally cannot do, and the reason
/// the entry form moved off `FormState.validate()`. The five branches are
/// independent, so `zipOrAccumulate5` runs them all and only then combines —
/// a form with five bad fields lights five error messages, not one.
///
/// Branch order is the error order, and it is part of the contract:
/// title · amount · category · dueDate · tags.
EitherNel<FieldError, Entry> validateDraft(
  EntryDraft d,
  Map<String, Category> byId,
) => either<Nel<FieldError>, Entry>(
  (r) => r.zipOrAccumulate5(
    (fr) => vTitle(fr, d.title),
    (fr) => vAmount(fr, d.amount, d.type),
    (fr) => vCategoryId(fr, d.categoryId, d.type, byId),
    (fr) => vDueDate(fr, d.dueDate, d.date),
    (fr) => vTags(fr, d.tags),
    (title, amount, category, dueDate, tags) => _entryFrom(
      d,
      title: title,
      amount: amount,
      category: category,
      dueDate: dueDate,
      tags: tags,
    ),
  ),
);

/// **Fail-fast**: the same five validators in the same order, composed in a
/// plain raise scope, so the first problem ends it.
///
/// Kept alongside [validateDraft] because the form ships a toggle between the
/// two — the contrast is the demo, and it is one `either` block versus one
/// `zipOrAccumulate5` call over identical validators.
Either<FieldError, Entry> validateDraftFailFast(
  EntryDraft d,
  Map<String, Category> byId,
) => either((r) {
  final title = vTitle(r, d.title);
  final amount = vAmount(r, d.amount, d.type);
  final category = vCategoryId(r, d.categoryId, d.type, byId);
  final dueDate = vDueDate(r, d.dueDate, d.date);
  final tags = vTags(r, d.tags);
  return _entryFrom(
    d,
    title: title,
    amount: amount,
    category: category,
    dueDate: dueDate,
    tags: tags,
  );
});
