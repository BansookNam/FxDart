import 'package:daily_ledger/logic/errors.dart';
import 'package:daily_ledger/logic/export.dart';
import 'package:daily_ledger/logic/import.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fxdart/fxdart.dart' show Left, Right;

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

Entry entry(
  String id, {
  EntryType type = EntryType.expense,
  double? amount = 10,
  String categoryId = 'dining',
  List<String> tags = const [],
  bool done = false,
}) => Entry(
  id: id,
  title: id,
  type: type,
  amount: amount,
  categoryId: categoryId,
  tags: tags,
  date: DateTime(2026, 7, 10),
  done: done,
);

ImportPreview parse(
  String text, {
  List<Entry> existing = const [],
  ImportMode mode = ImportMode.lenient,
}) => parseCsvEntries(
  text,
  categories: _categories,
  existing: existing,
  idPrefix: 'test',
  mode: mode,
);

const _header = 'date,type,title,category,amount,tags,done\n';

/// One good row, then three bad ones (bad date, unknown category, bad type).
const _mixed =
    '$_header'
    '2026-07-03,expense,Coffee,Dining,4.50,,no\n'
    'not-a-date,expense,Broken,Dining,1.00,,no\n'
    '2026-07-05,expense,NoSuchCat,Books,2.00,,no\n'
    '2026-07-06,magic,BadType,Dining,2.00,,no\n';

List<int> issueLines(ImportPreview p) =>
    p.issues?.map((i) => i.line).toList() ?? const [];

void main() {
  group('splitCsvLine', () {
    test('plain cells', () {
      expect(splitCsvLine('a,b,c'), ['a', 'b', 'c']);
    });

    test('quoted commas and escaped quotes', () {
      expect(splitCsvLine('"a,b",c,"say ""hi"""'), ['a,b', 'c', 'say "hi"']);
    });

    test('unbalanced quotes return null', () {
      expect(splitCsvLine('"open,ended'), isNull);
    });
  });

  group('parseCsvEntries — parsing', () {
    test('happy path builds entries with line-based ids', () {
      final p = parse(
        '$_header'
        '2026-07-03,expense,Coffee,Dining,4.50,treat|café,no\n'
        '2026-07-04,task,Sweep floor,Chores,,,yes\n',
      );
      // A clean file has NO error panel — `issues` is null, not empty.
      expect(p.issues, isNull);
      expect(p.isClean, isTrue);
      expect(p.entries, hasLength(2));
      final coffee = p.entries.first;
      expect(coffee.id, 'test-L2');
      expect(coffee.title, 'Coffee');
      expect(coffee.amount, 4.50);
      expect(coffee.categoryId, 'dining');
      expect(coffee.tags, ['treat', 'café']);
      expect(p.entries.last.done, isTrue);
      expect(p.entries.last.amount, isNull);
    });

    test('rows keep their file order with a verdict each', () {
      final p = parse(_mixed);
      expect(p.rows, hasLength(4));
      expect(p.rows.map((r) => r.isRight), [true, false, false, false]);
      expect(p.healthyCount, 1);
    });

    test(
      'a row reports the FIRST bad column — fail-fast is an ordering promise',
      () {
        // Both the date and the type are wrong; the date comes first.
        final p = parse('${_header}nope,magic,X,Dining,1.00,,no\n');
        final row = p.issues!.head;
        expect(row.line, 2);
        expect(
          row.fields.tail,
          isEmpty,
        ); // one field, not both — round 11 changes this
        expect(row.fields.head.field, 'date');
      },
    );

    test('a date that rolls over is rejected, not silently shifted', () {
      final p = parse('${_header}2026-02-30,expense,Ghost,Dining,1.00,,no\n');
      expect(p.entries, isEmpty);
      expect(p.issues!.head.fields.head.detail, contains('not a real date'));
    });

    test('wrong header is rejected up front and no row is attempted', () {
      final p = parse('id,name\n1,x\n');
      expect(p.entries, isEmpty);
      expect(p.rows, isEmpty);
      expect(p.issues!.head.message, contains('must be exactly'));
      expect(p.issues!.head.line, 1);
    });

    test('empty input is a file-level problem', () {
      final p = parse('   \n\n');
      expect(p.issues!.head.fields.head, const FieldError('file', 'no data'));
    });
  });

  group('parseCsvEntries — the three modes', () {
    test('lenient: separated() — good rows import, bad rows are listed', () {
      final p = parse(_mixed, mode: ImportMode.lenient);
      expect(p.entries, hasLength(1));
      expect(p.entries.single.title, 'Coffee');
      expect(issueLines(p), [3, 4, 5]);
    });

    test('strict: sequence() — the first bad row aborts everything', () {
      final p = parse(_mixed, mode: ImportMode.strict);
      expect(p.entries, isEmpty);
      // Only the first failure survives `sequence()`…
      expect(issueLines(p), [3]);
      // …but `rights()` still knows the row that would have been fine.
      expect(p.healthyCount, 1);
    });

    test('report: mapOrAccumulate() — every bad row, nothing committed', () {
      final p = parse(_mixed, mode: ImportMode.report);
      expect(p.entries, isEmpty);
      expect(issueLines(p), [3, 4, 5]);
    });

    test('report is fail-slow inside a row too, not just across rows', () {
      // One row, three bad columns: date, category and amount.
      const row = '${_header}nope,expense,Coffee,Books,free,,no\n';

      // Lenient/strict stop at the first bad column…
      final fast = parse(row, mode: ImportMode.lenient);
      expect(fast.issues!.head.fields.toList().map((f) => f.field), ['date']);

      // …report names every one of them.
      final slow = parse(row, mode: ImportMode.report);
      expect(slow.issues!.head.fields.toList().map((f) => f.field), [
        'date',
        'category',
        'amount',
      ]);
    });

    test('report keeps structural problems fail-fast', () {
      // With the wrong number of cells there are no columns to report on,
      // so accumulation would be meaningless.
      final p = parse('${_header}2026-07-03,expense\n', mode: ImportMode.report);
      final fields = p.issues!.head.fields.toList();
      expect(fields, hasLength(1));
      expect(fields.single.field, 'row');
      expect(fields.single.detail, contains('expected 7 columns, got 2'));
    });

    test('report skips the type-dependent amount rule when the type is bad', () {
      // `bill needs an amount` cannot be decided while the type cell is
      // unreadable — the dependent branch is guarded by acc.hasErrors.
      final p = parse('${_header}2026-07-03,magic,X,Dining,,,no\n',
          mode: ImportMode.report);
      expect(p.issues!.head.fields.toList().map((f) => f.field), ['type']);
    });

    test('a clean file behaves identically in all three modes', () {
      const clean = '${_header}2026-07-03,expense,Coffee,Dining,4.50,,no\n';
      for (final mode in ImportMode.values) {
        final p = parse(clean, mode: mode);
        expect(p.isClean, isTrue, reason: '$mode');
        expect(p.entries, hasLength(1), reason: '$mode');
      }
    });
  });

  group('parseCsvEntries — duplicates', () {
    test('duplicates against existing entries are counted, not dropped', () {
      final existing = [
        Entry(
          id: 'orig',
          title: 'Coffee',
          type: EntryType.expense,
          amount: 4.5,
          categoryId: 'dining',
          date: DateTime(2026, 7, 3),
        ),
      ];
      final p = parse(
        '${_header}2026-07-03,expense,Coffee,Dining,4.50,,no\n',
        existing: existing,
      );
      expect(p.entries, hasLength(1));
      expect(p.duplicateCount, 1);
    });

    test('a mode that commits nothing counts no duplicates', () {
      final existing = [
        Entry(
          id: 'orig',
          title: 'Coffee',
          type: EntryType.expense,
          amount: 4.5,
          categoryId: 'dining',
          date: DateTime(2026, 7, 3),
        ),
      ];
      final p = parse(_mixed, existing: existing, mode: ImportMode.strict);
      expect(p.duplicateCount, 0);
    });
  });

  test('round-trip: export → import preserves the exported fields', () {
    final original = [
      entry('Fancy, dinner "out"', amount: 120.5, tags: ['date-night']),
      entry(
        'Laundry',
        type: EntryType.task,
        amount: null,
        categoryId: 'chores',
        done: true,
      ),
    ];
    final csv = entriesToCsv(
      original,
      categories: {for (final c in _categories) c.id: c},
    );
    final p = parse(csv);
    expect(p.issues, isNull);
    expect(p.entries, hasLength(2));
    for (final (i, e) in p.entries.indexed) {
      // export sorts by date; both share a date so order is stable
      final o = original[i];
      expect(e.title, o.title);
      expect(e.type, o.type);
      expect(e.amount, o.amount);
      expect(e.categoryId, o.categoryId);
      expect(e.tags, o.tags);
      expect(e.done, o.done);
      expect(e.date, DateTime(2026, 7, 10));
    }
  });

  test('parseRow is the unit the modes share', () {
    final byName = {for (final c in _categories) c.name.toLowerCase(): c};
    final ok = parseRow(
      (2, '2026-07-03,expense,Coffee,Dining,4.50,,no'),
      byName: byName,
      idPrefix: 'x',
    );
    final bad = parseRow(
      (3, 'nope,expense,Coffee,Dining,4.50,,no'),
      byName: byName,
      idPrefix: 'x',
    );

    // Sealed: this switch needs no default arm.
    expect(switch (ok) {
      Left() => 'left',
      Right(:final value) => value.title,
    }, 'Coffee');
    expect(bad.leftOrNull()?.line, 3);
  });
}
