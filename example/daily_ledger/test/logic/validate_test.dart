import 'package:daily_ledger/logic/errors.dart';
import 'package:daily_ledger/logic/validate.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fxdart/fxdart.dart' show Either, EitherNel, Raise, either;

const _categories = [
  Category(
    id: 'dining',
    name: 'Dining',
    iconCodePoint: 0xe000,
    colorSeed: 0xFF000001,
    kind: CategoryKind.money,
  ),
  Category(
    id: 'chores',
    name: 'Chores',
    iconCodePoint: 0xe001,
    colorSeed: 0xFF000002,
    kind: CategoryKind.task,
  ),
];

/// Runs one validator in its own raise scope — the smallest possible
/// `either { }`, which is exactly how the lecture introduces it.
Either<FieldError, A> check<A>(A Function(Raise<FieldError> r) block) =>
    either(block);

/// The raised error, or null when the validator accepted the input.
FieldError? errorOf<A>(Either<FieldError, A> result) => result.leftOrNull();

void main() {
  group('vDate', () {
    test('accepts padded and unpadded YYYY-MM-DD', () {
      expect(
        check((r) => vDate(r, '2026-07-03')).getOrNull(),
        DateTime(2026, 7, 3),
      );
      expect(
        check((r) => vDate(r, ' 2026-7-3 ')).getOrNull(),
        DateTime(2026, 7, 3),
      );
    });

    test('rejects a shape that is not a date', () {
      expect(
        errorOf(check((r) => vDate(r, 'not-a-date'))),
        const FieldError('date', 'want YYYY-MM-DD, got "not-a-date"'),
      );
    });

    test('rejects a well-shaped date that does not exist', () {
      // DateTime(2026, 2, 30) silently rolls over to March 2nd — round 7's
      // importer accepted this and produced a wrong entry.
      expect(
        errorOf(check((r) => vDate(r, '2026-02-30'))),
        const FieldError('date', 'not a real date: "2026-02-30"'),
      );
      expect(
        errorOf(check((r) => vDate(r, '2026-13-01'))),
        const FieldError('date', 'not a real date: "2026-13-01"'),
      );
    });

    test(
      'the field name is caller-chosen, so one validator serves two fields',
      () {
        expect(
          errorOf(check((r) => vDate(r, 'x', field: 'dueDate')))?.field,
          'dueDate',
        );
      },
    );
  });

  group('vType', () {
    test('accepts every enum name', () {
      for (final type in EntryType.values) {
        expect(check((r) => vType(r, type.name)).getOrNull(), type);
      }
    });

    test('rejects an unknown name and lists the valid ones', () {
      final error = errorOf(check((r) => vType(r, 'magic')));
      expect(error?.field, 'type');
      expect(error?.detail, contains('magic'));
      expect(error?.detail, contains('expense|income|task|bill'));
    });
  });

  group('vTitle', () {
    test('trims', () {
      expect(check((r) => vTitle(r, '  Coffee ')).getOrNull(), 'Coffee');
    });

    test('rejects blank', () {
      expect(
        errorOf(check((r) => vTitle(r, '   '))),
        const FieldError('title', 'must not be empty'),
      );
    });
  });

  group('vAmount', () {
    test('empty is fine for a task, missing for anything else', () {
      expect(check((r) => vAmount(r, '', EntryType.task)).getOrNull(), isNull);
      expect(
        errorOf(check((r) => vAmount(r, '  ', EntryType.bill))),
        const FieldError('amount', 'bill needs an amount'),
      );
    });

    test('parses money', () {
      expect(
        check((r) => vAmount(r, '4.50', EntryType.expense)).getOrNull(),
        4.5,
      );
    });

    test('rejects non-numbers and non-positive values', () {
      expect(
        errorOf(check((r) => vAmount(r, 'free', EntryType.expense))),
        const FieldError('amount', 'not a number: "free"'),
      );
      expect(
        errorOf(check((r) => vAmount(r, '0', EntryType.expense))),
        const FieldError('amount', 'must be greater than 0'),
      );
      expect(
        errorOf(check((r) => vAmount(r, '-3', EntryType.expense))),
        const FieldError('amount', 'must be greater than 0'),
      );
    });
  });

  group('vCategory', () {
    final known = categoryIndex(_categories);

    test('matches on display name, case-insensitively', () {
      expect(
        check((r) => vCategory(r, ' dining ', known)).getOrNull()?.id,
        'dining',
      );
      expect(
        check((r) => vCategory(r, 'CHORES', known)).getOrNull()?.id,
        'chores',
      );
    });

    test('rejects an unknown name', () {
      expect(
        errorOf(check((r) => vCategory(r, 'Books', known))),
        const FieldError('category', 'unknown category "Books"'),
      );
    });
  });

  test('parseTags drops blanks and trims', () {
    expect(parseTags('treat| café ||'), ['treat', 'café']);
    expect(parseTags(''), isEmpty);
  });

  group('validateBudget — two independent fields', () {
    final byId = {for (final c in _categories) c.id: c};

    List<FieldError> problems(EitherNel<FieldError, Object?> r) =>
        r.leftOrNull()?.toList() ?? const [];

    test('a valid draft yields the category and the limit', () {
      final result = validateBudget(
        const BudgetDraft(categoryId: 'dining', amount: '250'),
        byId,
      );
      final (category, limit) = result.getOrNull()!;
      expect(category.id, 'dining');
      expect(limit, 250);
    });

    test('both fields wrong reports both, in branch order', () {
      final result = validateBudget(
        // A task category, and a limit that is not a number.
        const BudgetDraft(categoryId: 'chores', amount: 'lots'),
        byId,
      );
      expect(problems(result).map((e) => e.field), ['category', 'amount']);
    });

    test('a blank limit is a problem, unlike a blank entry amount', () {
      expect(
        problems(
          validateBudget(
            const BudgetDraft(categoryId: 'dining', amount: '  '),
            byId,
          ),
        ).single,
        const FieldError('amount', 'enter a monthly limit'),
      );
    });

    test('a non-positive limit is rejected', () {
      expect(
        problems(
          validateBudget(
            const BudgetDraft(categoryId: 'dining', amount: '0'),
            byId,
          ),
        ).single.detail,
        'must be greater than 0',
      );
    });
  });

  group('validateDraft — accumulation', () {
    final byId = {for (final c in _categories) c.id: c};

    EntryDraft draft({
      String title = 'Coffee',
      EntryType type = EntryType.expense,
      String amount = '4.50',
      String? categoryId = 'dining',
      String tags = 'treat',
      DateTime? date,
      DateTime? dueDate,
    }) => EntryDraft(
      id: 'draft-1',
      title: title,
      type: type,
      amount: amount,
      categoryId: categoryId,
      tags: tags,
      date: date ?? DateTime(2026, 7, 10),
      dueDate: dueDate,
    );

    List<FieldError> problems(EitherNel<FieldError, Entry> r) =>
        r.leftOrNull()?.toList() ?? const [];

    test('a valid draft becomes an Entry', () {
      final entry = validateDraft(draft(), byId).getOrNull()!;
      expect(entry.title, 'Coffee');
      expect(entry.amount, 4.5);
      expect(entry.categoryId, 'dining');
      expect(entry.tags, ['treat']);
    });

    test('a task needs no amount', () {
      final entry = validateDraft(
        draft(type: EntryType.task, amount: '', categoryId: 'chores'),
        byId,
      ).getOrNull()!;
      expect(entry.amount, isNull);
    });

    test('FIVE bad fields report FIVE problems, in branch order', () {
      // This is the case try/catch and fail-fast Either cannot express.
      final result = validateDraft(
        draft(
          title: '   ',
          amount: 'free',
          categoryId: 'chores', // a task category on an expense
          dueDate: DateTime(2026, 7, 1), // before the entry date
          tags: 'a|b',
        ),
        byId,
      );
      expect(problems(result).map((e) => e.field), [
        'title',
        'amount',
        'category',
        'dueDate',
        'tags',
      ]);
    });

    test('only the bad branches contribute', () {
      final result = validateDraft(draft(title: '', tags: 'x|y'), byId);
      expect(problems(result).map((e) => e.field), ['title', 'tags']);
    });

    test('the same draft fail-fast reports exactly one problem', () {
      final bad = draft(title: '   ', amount: 'free', tags: 'a|b');
      final slow = validateDraft(bad, byId);
      final fast = validateDraftFailFast(bad, byId).toEitherNel();
      expect(problems(slow), hasLength(3));
      expect(problems(fast), hasLength(1));
      // …and it is the first branch, not an arbitrary one.
      expect(problems(fast).single, problems(slow).first);
    });

    test('a category of the wrong kind is rejected', () {
      final result = validateDraft(draft(categoryId: 'chores'), byId);
      expect(problems(result).single.field, 'category');
      expect(problems(result).single.detail, contains('task category'));
    });

    test('an unset category is rejected', () {
      final result = validateDraft(draft(categoryId: null), byId);
      expect(
        problems(result).single,
        const FieldError('category', 'pick a category'),
      );
    });

    test('a due date before the entry date is rejected', () {
      final result = validateDraft(
        draft(type: EntryType.bill, dueDate: DateTime(2026, 7, 9)),
        byId,
      );
      expect(problems(result).single.field, 'dueDate');
    });

    test('a due date on the same day is fine', () {
      final result = validateDraft(
        draft(type: EntryType.bill, dueDate: DateTime(2026, 7, 10)),
        byId,
      );
      expect(problems(result), isEmpty);
    });

    test('tags cannot contain the CSV separator, or repeat', () {
      expect(
        problems(validateDraft(draft(tags: 'a|b'), byId)).single.detail,
        contains('separator'),
      );
      expect(
        problems(validateDraft(draft(tags: 'x, x'), byId)).single.detail,
        'duplicate tags',
      );
    });
  });

  test('a scope only sees its own raise — validators compose fail-fast', () {
    // Two validators, one scope: the FIRST failure ends the block and the
    // second never runs. That ordering promise is what "fail-fast" means.
    var secondRan = false;
    final result = check<String>((r) {
      vTitle(r, '');
      secondRan = true;
      return vType(r, 'magic').name;
    });
    expect(result.isLeft, isTrue);
    expect(errorOf(result)?.field, 'title');
    expect(secondRan, isFalse);
  });
}
