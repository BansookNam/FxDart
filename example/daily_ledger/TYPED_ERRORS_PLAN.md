# Daily Ledger — Typed errors series (spec)

Companion to [`plan.md`](plan.md). Same rules apply (principles 1–5, the
round protocol, the "?" explainer contract); this file only covers the
**typed-error series**: rounds 10–13.

## 1. Goal

The library shipped an Arrow-2.x-style typed-error core in 0.6 (`lib/src/typed/`),
and FxDart 101 grew **section 13 — Typed errors** with six lectures:

| # | Lecture (`content/course.json` §13) | page |
| - | ----------------------------------- | ---- |
| 1 | Either | `either.html` |
| 2 | either & Raise scope | `raise.html` |
| 3 | nullable | `nullable.html` |
| 4 | NonEmptyList (Nel) | `nonEmptyList.html` |
| 5 | accumulation (zipOrAccumulate, …) | `accumulate.html` |
| 6 | Either × pipelines | `eitherPipelines.html` |

The app currently demonstrates 50+ *data* operators and **zero** typed-error
API. That is the gap: every failure path in Daily Ledger today is either a
nullable return, a `(T?, Issue?)` tuple, or a Flutter `FormState.validate()`
callback — three different, mutually incompatible dialects of "this can fail".

**This series makes the app the reference implementation for section 13**, on
the same terms as the rest of the app:

1. Every public member of `lib/src/typed/` has **at least one call site** in
   `example/daily_ledger/lib/` (§7 is the proof table — it is the acceptance
   criterion for the series).
2. Every call site is a **real feature**, not a demo. Where a member only
   fits thinly, §7 says so out loud rather than inventing a fake feature —
   principle #3 ("readable over clever") outranks coverage.
3. Every new surface carries the circled **"?"** and an explainer dialog that
   walks the pipeline with the data currently on screen — extended for typed
   errors so the dialog can show *which step raised* and *which side the
   Either landed on* (§6).

### Honest positioning (per the DartComparison honesty rules)

The pitch is **not** "typed errors are faster" or "exceptions are bad". It is:

- **Exhaustiveness** — `Either` is sealed, so `switch` over a result is
  checked by the compiler. A new failure mode becomes a compile error at
  every render site, not a runtime surprise.
- **Accumulation** — `try`/`catch` structurally cannot report five bad fields
  at once. `zipOrAccumulate5` can. This is the one thing native Dart has no
  answer for, and it is where the app leans hardest.
- **Straight-line code** — inside `either((r) { … })` you write ordinary Dart
  with `r.ensure` / `r.bind`, not a `flatMap` pyramid.

The costs are stated too, in the About dialog and in the Health screen's
final card: an allocation per result, a second vocabulary to learn, and no
stack traces on the failure path (a raise is a value, not a throw).

## 2. Non-goals

- No `Option`, no `Task`/`IO`, no HKT. The library will never have them;
  the app must not pretend otherwise (`T?` stays the absence channel).
- No rewrite of the *aggregation* pipelines. Summaries, calendar, heatmap,
  forecast and weekday code are total functions — wrapping them in `Either`
  would be cargo cult. Typed errors go **only** where a failure genuinely
  exists: parsing, user input, and I/O.
- No new fxdart operators expected. Rounds 5–8 each grew the library; this
  series consumes an API that already shipped. If a gap does turn up, it
  follows the same "grow fxdart, then use it" rule as round 5.
- Deployment stays deferred (unchanged from `plan.md`).

## 3. The app's error vocabulary

New file **`lib/logic/errors.dart`** — the one place failures are named.
Sealed, so every renderer is exhaustive.

```dart
/// Everything that can go wrong in the ledger, as data.
sealed class LedgerError {
  const LedgerError();
  String get message;
}

/// One bad field of one draft/row. The atom of accumulation.
final class FieldError extends LedgerError {
  final String field;   // 'amount', 'date', 'category', …
  final String detail;
  const FieldError(this.field, this.detail);
  @override String get message => '$field: $detail';
}

/// One bad CSV row — carries EVERY bad field on that row (Nel: at least one).
final class RowError extends LedgerError {
  final int line;                 // 1-based, header = line 1
  final Nel<FieldError> fields;
  const RowError(this.line, this.fields);
  @override String get message =>
      'line $line — ${fields.map((f) => f.message).join(', ')}';
}

/// A storage box that failed to load.
final class BoxError extends LedgerError {
  final String box;
  final String cause;
  const BoxError(this.box, this.cause);
  @override String get message => 'box "$box" failed: $cause';
}

/// A ledger-wide invariant violation found by the Health audit.
final class AuditError extends LedgerError {
  final String rule;              // 'orphan-category', 'negative-amount', …
  final String subjectId;
  final String detail;
  const AuditError(this.rule, this.subjectId, this.detail);
  @override String get message => '$rule (${subjectId}): $detail';
}
```

`ImportIssue` (the current `(int line, String message)` class) is **deleted**;
`RowError` replaces it. This is a breaking change to `logic/import.dart`'s
public shape and to `import_test.dart` — both are in-app, both get rewritten
in round 10.

## 4. Feature specs

Six chapters, six surfaces. Each surface is a real feature first and a
lecture second.

### 4.1 Chapter 1 — `Either`: CSV import rows

**Change `lib/logic/import.dart`.** Today `parseRow` returns
`(Entry?, ImportIssue?)` and the caller runs `compact` twice to split the
stream. That tuple *is* an `Either` with the type system switched off.

```dart
// before (round 7)
(Entry?, ImportIssue?) parseRow(int line, String raw) { … }
final entries = compact(fx(parsed).map((p) => p.$1)).toList();
final issues  = compact(fx(parsed).map((p) => p.$2)).toList();

// after
Either<RowError, Entry> parseRow(int line, String raw) => …;
final (issues, entries) = fx(numbered.skip(1))
    .map((p) => parseRow(p.$1, p.$2))
    .separated();                       // ← Either × pipelines, §4.6
```

The preview model becomes:

```dart
class ImportPreview {
  final List<Entry> entries;
  final List<RowError> issues;
  final int duplicateCount;
  /// Kept un-split so the UI can render rows in file order with their
  /// verdict inline (the `fold` call site).
  final List<Either<RowError, Entry>> rows;
}
```

The import dialog renders each row with `row.fold(…)`, badge counts with
`isLeft`/`isRight`, and the "unknown category" recovery path with
`Either.recover` (§7).

### 4.2 Chapter 2 — `either` & `Raise` scope: one row, one scope

Inside `parseRow`, the eight early `return (null, issue(…))` statements
collapse into straight-line Dart:

```dart
Either<RowError, Entry> parseRow(int line, String raw) =>
  either<RowError, Entry>((r) {
    // field validators raise FieldError; this scope raises RowError.
    // withError is the adapter between the two error types.
    return r.withError(
      (FieldError f) => RowError(line, Nel.of(f)),
      (fr) {
        final cells = fr.ensureNotNull(
          splitCsvLine(raw),
          () => const FieldError('row', 'unbalanced quotes'),
        );
        fr.ensure(
          cells.length == csvColumns.length,
          () => FieldError('row', 'expected ${csvColumns.length} columns, '
              'got ${cells.length}'),
        );
        final row = fromEntries(fx(csvColumns).zip(cells));
        return fr.bind(entryFromRow(row, line: line)); // Either<FieldError,Entry>
      },
    );
  });
```

Three things this teaches, in order: `r.ensureNotNull` promotes a nullable to
non-null via `Never`; `r.ensure` is a typed `require`; `r.withError` adapts a
field-level error type into a row-level one without a single `catch`.

**`lib/logic/validate.dart`** (new) holds the field validators — pure
`A Function(Raise<FieldError> r, String raw)` functions shared by the CSV
importer and the entry form:

```dart
DateTime  vDate(Raise<FieldError> r, String raw);
EntryType vType(Raise<FieldError> r, String raw);
String    vTitle(Raise<FieldError> r, String raw);
double?   vAmount(Raise<FieldError> r, String raw, EntryType type);
Category  vCategory(Raise<FieldError> r, String raw, List<Category> known);
```

Scope-first, exactly as the lecture teaches: the validators take `r` and
return the *parsed value*, never an `Either`. Composition happens at the
call site — fail-fast in the CSV row (`§4.2`), fail-slow in the form (`§4.5`).

`catching` wraps the throwing primitives (`double.parse`, `DateTime` math)
so a malformed cell becomes a `FieldError` and never an escaped exception —
and, critically, never swallows fxdart's own raise signal the way a bare
`catch` would.

### 4.3 Chapter 3 — `nullable`: "missing on purpose"

Not every absence is an error. Three genuine spots, all currently written as
`?.`/`??` ladders:

1. **`budgets.dart` → `budgetStatusFor(categoryId, month)`** — needs a
   budget *and* a category *and* a non-zero limit; any missing → `null`,
   because "no budget set" is not a failure, it's a state.

   ```dart
   BudgetStatus? budgetStatusFor(LedgerData d, String categoryId, DateTime m) =>
     nullable((r) {
       final limit    = r.bind(d.budgets[categoryId]);   // null → no status
       final category = r.bind(byId(d.categories, categoryId));
       r.ensure(limit > 0);
       return BudgetStatus(category.id, limit, spentByCategory(d.entries, m)[categoryId] ?? 0);
     });
   ```

2. **`forecast.dart` → `runwayEstimate`** — needs ≥2 months of history and a
   negative net; `r.ensure(…)` twice, no error value to report because the UI
   just hides the card.

3. **`nullableAsync`** — `LedgerState.restoreLastCategory()`: reads the
   last-used category id from the box, resolves it against the live category
   list, and yields `null` if either step misses. Async because the box read
   is awaited.

Card copy on the Health screen states the rule explicitly: *nullable when the
caller has nothing useful to say about why; Either when it does.*

### 4.4 Chapter 4 — `NonEmptyList`: the error panel

`Nel<LedgerError>` is the type of every error panel in the app, and the panel
is a real widget (`lib/ui/error_panel.dart`, new):

```dart
class ErrorPanel extends StatelessWidget {
  final Nel<LedgerError> errors;
  // headline = errors.head (total — cannot throw on empty, that's the point)
  // details  = errors.tail (possibly empty → "and N more" collapses away)
}
```

- `Nel.of(head, tail)` — building a single-field row error.
- `Nel.orNull(list)` — the bridge from a plain `List` the UI accumulated
  (`orNull` returning `null` is what lets the panel be *absent* rather than
  empty; there is no such thing as an empty error panel).
- `head` / `tail` — headline vs. "and 4 more" disclosure.
- `map` — `errors.map((e) => e.message)`, non-emptiness preserved in the type
  so the headline stays total after mapping.
- `+` — the import dialog merges header errors with row errors into one
  panel: `headerErrors + rowErrors`.
- `deepEquals` — the panel is an `AnimatedSwitcher`; extension types cannot
  override `==` (it stays `List` identity), so the "did the error set actually
  change?" check **must** be `deepEquals`. Using `==` here would re-run the
  animation on every rebuild. This is a genuine bug the type forces you to
  think about, and the card says so.
- `toList()` — the defensive copy handed to the clipboard "copy report"
  button.

### 4.5 Chapter 5 — accumulation: the entry form

**The headline feature of the series.** Today `entry_form.dart` uses
`_formKey.currentState!.validate()` with per-field `validator:` callbacks and
an untyped `_categoryId == null` check bolted on beside it. Replace with one
function that returns every problem at once:

```dart
// lib/logic/validate.dart
EitherNel<FieldError, Entry> validateDraft(EntryDraft d, List<Category> known) =>
  either<Nel<FieldError>, Entry>((r) => r.zipOrAccumulate5(
    (fr) => vTitle(fr, d.title),
    (fr) => vType(fr, d.type),
    (fr) => vAmount(fr, d.amount, d.type),
    (fr) => vCategory(fr, d.categoryId, known),
    (fr) => vDate(fr, d.date, due: d.dueDate),
    (title, type, amount, category, dates) => Entry(…),
  ));
```

Five bad fields → one `Left(Nel)` with five `FieldError`s → five red field
borders lit simultaneously, plus the `ErrorPanel` summary. A `try`/`catch`
or a fail-fast `Either` chain lights exactly one. **That contrast is the
demo**, and the form ships a "fail-fast vs fail-slow" toggle so you can watch
the difference live (fail-fast path = the same validators composed with
`r.bind`, one `Either` at a time).

Lower arities get genuine homes rather than filler:

- **`zipOrAccumulate2`** — the budget editor dialog (category + amount).
- **`zipOrAccumulate3`** — the recurring-rule editor (period + anchor date +
  category).
- **`zipOrAccumulate4`** — the saved-filter parser: the Entries screen's
  filter state (`query`, `type`, `tag`, `dateRange`) is serialised into the
  URL fragment on web; parsing it back validates four independent fields and
  should report all four, since a hand-edited URL is exactly the case where
  one-error-at-a-time is miserable.

- **`accumulate` / `Accumulator.accumulating` / `Accumulated.value` /
  `hasErrors`** — the CSV import's *file-level* scope, where the branch count
  is dynamic and `zipOrAccumulateN` does not fit: header check, row parse,
  duplicate scan, and budget-reference check each run as an
  `acc.accumulating(…)` branch; `acc.hasErrors` drives the dialog's
  "Import anyway (N rows)" affordance *before* any `.value` is read; the
  `.value` reads at the end detonate with the full list.

- **`AccumulatingRaise.bindNel`** — a row that itself accumulated (`EitherNel`
  from `validateDraft`) is folded into the file-level scope with *all* its
  field errors, not just the first.
- **`AccumulatingRaise.mapOrAccumulate`** — nested accumulation: within the
  "row parse" branch, every row is a nested accumulating pass, so one
  malformed file reports `rows × fields` problems in a single run.
- **`AccumulatingRaise.over`** — `health.dart` adapts the outer
  `Raise<Nel<LedgerError>>` audit scope into a single-error accumulating view
  so audit rules can be written as plain `Raise<LedgerError>` functions and
  still accumulate. (This is the one place the constructor is called
  directly; everywhere else the builders create it.)

### 4.6 Chapter 6 — Either × pipelines

The fusion of the two halves of the library, and the reason `fx_either.dart`
exists. Import gets a **strictness selector** with three real modes, each
mapping to one terminal:

| Mode | Terminal | Behaviour |
| ---- | -------- | --------- |
| **Lenient** (default) | `.separated()` | import the good rows, list the bad ones |
| **Strict** | `.sequence()` | first bad row aborts the whole import |
| **Report** | `.mapOrAccumulate(…)` | import nothing; produce the full problem report |

```dart
final rows = fx(numbered.skip(1)).map((p) => parseRow(p.$1, p.$2));
switch (mode) {
  case Lenient: final (bad, good) = rows.separated();
  case Strict:  final result = rows.sequence();          // Either<RowError, List<Entry>>
  case Report:  final result = fx(numbered.skip(1))
                    .mapOrAccumulate<FieldError, Entry>(parseRowAccumulating);
}
```

`rights()` / `lefts()` back the two count badges ("47 ok · 3 problems") when
only one side is needed and allocating the pair would be waste. The top-level
`rights` / `lefts` / `separateEither` / `sequenceEither` / `mapOrAccumulate`
functions are used by `health.dart`, which works over plain `List`s coming out
of the audit rules rather than over an `Fx` chain — both call styles appear in
the app on purpose, because the lecture shows both.

**Async half — `lib/data/ledger_repository.dart`.** `loadAll` currently
asserts four boxes loaded and cannot express "the rules box is corrupt but
the rest is fine". It becomes:

```dart
Future<Either<Nel<BoxError>, LedgerData>> loadAll({…}) async {
  final boxes = fx(['entries', 'categories', 'rules', 'budgets']).toAsync()
      .map((b) => delay(boxLatency, b))
      .peek((b) => onLoaded?.call(b));

  // Report mode: every broken box, three at a time (the concurrent(n)
  // back-channel still applies — fail-slow and concurrent at once).
  final loaded = await boxes.mapOrAccumulate<BoxError, String>(
    (r, box) => readBox(r, box), concurrency: 3);
  // Strict mode (a flag on the loading screen, for the demo):
  //   await boxes.map(tryRead).sequence();   → fails fast on the first bad box
  return loaded.map((_) => LedgerData(…));
}
```

- `mapOrAccumulateAsync` with `concurrency: 3` — the default path. Keeps the
  round-1 concurrency demo *and* gains fail-slow reporting; the loading screen
  shows a per-box ✓/✗ as each resolves.
- `FxAsyncEitherOps.sequence()` / `sequenceEitherAsync` — the strict path,
  reachable from a toggle on the loading screen so the difference (stops
  pulling at the first `Left`) is observable in the box checklist.
- `eitherAsync` — the outer scope of `LedgerState.load()`.

`LedgerState` gains `Nel<BoxError>? loadError`; `app_shell.dart`'s
`_LoadingScreen` renders the `ErrorPanel` with a Retry button instead of
hanging on a spinner forever.

### 4.7 The Health tab (new 5th screen)

`lib/ui/health_screen.dart` — icon `Icons.verified_outlined`, label
**"Health"**, inserted after Insights in `_tabs`. It is the guide's home:
six `SectionCard`s in lecture order, each showing live data from the current
ledger, each with a "?".

| Card | Chapter | Live content |
| ---- | ------- | ------------ |
| **Ledger audit** | Either | N rules × M entries → `List<Either<AuditError, Entry>>`; ✓/✗ per rule |
| **One entry, one scope** | either & Raise | pick any entry → the validator re-run, step by step |
| **Missing on purpose** | nullable | which cards are hidden right now and why (no budget / <2 months history) |
| **At least one problem** | Nel | the merged `Nel` of everything above; `head` headline + `tail` |
| **All of them, not the first** | accumulation | the last form/import validation, fail-fast vs fail-slow side by side |
| **Validation in the pipeline** | Either × pipelines | the same audit run through `separated` / `sequence` / `mapOrAccumulate`, with the three results contrasted |

`lib/logic/health.dart` (new) holds the audit rules — pure, testable,
`List<Entry> → List<Either<AuditError, Entry>>`:

- `orphan-category` — `categoryId` not in the category list.
- `negative-amount` — expense/income/bill with `amount <= 0`.
- `task-with-amount` — a pure task carrying money.
- `due-before-date` — `dueDate` earlier than `date`.
- `orphan-rule` — `recurringRuleId` pointing at a deleted rule.
- `budget-without-category` — a budget key with no category.

A seventh card, **"When this bites"**, is the honesty card: it documents the
`RaiseLeakedError` hazard with a live, deliberately-wrong example — returning
a lazy `fx(...).map(…)` from a raise block, consumed after the builder
returned — caught and rendered as the error text. Given how `fx`-heavy this
app is, that is the single most useful thing the screen can teach, and it
gets a test (`expect(() => …, throwsA(isA<RaiseLeakedError>()))`).

## 5. Files touched

**New**

| File | Purpose |
| ---- | ------- |
| `lib/logic/errors.dart` | sealed `LedgerError` family |
| `lib/logic/validate.dart` | scope-first field validators + `validateDraft` |
| `lib/logic/health.dart` | audit rules, `auditLedger`, the three-terminal contrast |
| `lib/logic/filter_link.dart` | saved-filter parse (`zipOrAccumulate4`) |
| `lib/ui/health_screen.dart` | the 5th tab, 7 cards |
| `lib/ui/error_panel.dart` | `Nel<LedgerError>` renderer, shared everywhere |
| `test/logic/errors_test.dart`, `validate_test.dart`, `health_test.dart`, `filter_link_test.dart` | |

**Changed**

| File | Change |
| ---- | ------ |
| `lib/logic/import.dart` | tuples → `Either<RowError, Entry>`; three strictness modes |
| `lib/logic/budgets.dart` | `budgetStatusFor` via `nullable` |
| `lib/logic/forecast.dart` | `runwayEstimate` via `nullable` |
| `lib/data/ledger_repository.dart` | `loadAll` → `Either<Nel<BoxError>, LedgerData>` |
| `lib/state/ledger_state.dart` | `loadError`, `restoreLastCategory` |
| `lib/ui/entry_form.dart` | `FormState.validate` → `validateDraft`; fail-fast toggle |
| `lib/ui/import_dialog.dart` | mode selector, per-row verdicts, `ErrorPanel` |
| `lib/ui/app_shell.dart` | 5th tab; loading-screen error state; About copy |
| `lib/ui/widgets.dart` | explainer extensions (§6); typed-error link table |
| `test/logic/import_test.dart` | rewritten against `Either` |
| `plan.md` | coverage-table rows, round log 10–13, final-state refresh |

## 6. The "?" explainer, extended

The existing contract (`PipelineExplanation` = formula + steps + result,
built at click time from live data) is kept verbatim. Two additions, both
backwards compatible — every existing call site keeps compiling:

```dart
enum StepVerdict { ok, raised, accumulated }

class PipelineStep {
  final String op, what, value;
  final StepVerdict verdict;          // NEW, defaults to ok
  const PipelineStep(this.op, this.what, this.value,
      {this.verdict = StepVerdict.ok});
}

class PipelineExplanation {
  … existing fields …
  /// NEW. When set, the dialog closes with a Left/Right verdict chip
  /// instead of the plain `result` line.
  final EitherVerdict? verdict;
}

/// What the pipeline actually returned, for the closing chip.
sealed class EitherVerdict {
  factory EitherVerdict.right(String summary) = _RightVerdict;   // "Right · 47 entries"
  factory EitherVerdict.left(Nel<String> errors) = _LeftVerdict; // "Left · Nel(3)"
}
```

Rendering rules:

- `StepVerdict.ok` — unchanged: numbered circle, `primaryContainer`.
- `StepVerdict.raised` — the circle becomes `!` on `LedgerColors.negative`
  container; the `op` text uses the error colour; every *subsequent* step is
  dimmed to 40 % opacity, because short-circuiting means they never ran. That
  dimming is the whole lesson of `Raise` in one visual.
- `StepVerdict.accumulated` — `+` on a warning-tone container, **not** dimmed
  after, because accumulation keeps going. Fail-fast and fail-slow are
  distinguishable at a glance.
- `verdict` chip — full-width, at the bottom, above the Close button.
  `Right` = positive container with the summary; `Left` = negative container
  with `errors.head` and, if `errors.tail` is non-empty, an expander showing
  the rest. The chip is built from the same `Nel` the `ErrorPanel` renders,
  so the dialog can never disagree with the screen.

**Tutorial links.** `LinkedPipelineText` links identifiers to
`<base><fn>.html`, one page per function. Typed errors do not work that way —
six chapter pages cover ~77 members — so `widgets.dart` gains a second table:

```dart
/// Typed-error identifiers → the section-13 lecture that covers them.
/// Consulted only AFTER `_linkableFns`, so the per-operator pages always
/// win a name collision.
const _typedErrorPages = <String, String>{
  'Either':'either', 'Left':'either', 'Right':'either', 'EitherNel':'either',
  'getOrElse':'either', 'getOrNull':'either', 'leftOrNull':'either',
  'mapLeft':'either', 'swap':'either', 'toEitherNel':'either',
  'either':'raise', 'eitherAsync':'raise', 'foldRaise':'raise',
  'Raise':'raise', 'bind':'raise', 'bindAll':'raise', 'ensure':'raise',
  'ensureNotNull':'raise', 'withError':'raise', 'catching':'raise',
  'raise':'raise', 'RaiseLeakedError':'raise',
  'nullable':'nullable', 'nullableAsync':'nullable',
  'Nel':'nonEmptyList', 'NonEmptyList':'nonEmptyList', 'head':'nonEmptyList',
  'accumulate':'accumulate', 'accumulating':'accumulate',
  'bindNel':'accumulate', 'zipOrAccumulate2':'accumulate',
  'zipOrAccumulate3':'accumulate', 'zipOrAccumulate4':'accumulate',
  'zipOrAccumulate5':'accumulate',
  'rights':'eitherPipelines', 'lefts':'eitherPipelines',
  'separated':'eitherPipelines', 'separateEither':'eitherPipelines',
  'sequence':'eitherPipelines', 'sequenceEither':'eitherPipelines',
  'mapOrAccumulate':'eitherPipelines',
};
```

Collision policy, decided once here so the rounds do not relitigate it. The
names that exist in **both** worlds are `fold`, `map`, `filter`, `toList`,
`head`, `find`, `size` — all of them already in `_linkableFns`. They stay
pointed at their existing **operator** pages, because in this app's formulas
they are far more often the operator. `head` is the exception: in a typed-error
formula it is always `Nel.head`, and the `head` operator page and
`nonEmptyList` page both explain "first element", so the mis-link is harmless
either way; the table sends it to `nonEmptyList` because that is the safer
lesson.

## 7. Coverage proof — every member, one call site

The acceptance criterion for the series. `test/api_coverage_test.dart` reads
`lib/fxdart.dart`'s typed exports and greps `example/daily_ledger/lib/` for
each name, failing on any zero — so this table cannot silently rot.
**Thin** = honest label: the use is real code but a small one, kept because
coverage is a goal, dropped if it ever reads as filler.

### `either.dart`

| Member | Call site |
| ------ | --------- |
| `Either.left` / `Either.right` | `validate.dart` — dot-shorthand returns (`return .left(err)`) |
| `Left` / `Right` (patterns) | `import_dialog.dart` per-row verdict `switch` |
| `EitherNel` | `validateDraft`'s return type |
| `isLeft` / `isRight` | import badge counts "47 ok · 3 problems" |
| `fold` | `error_panel.dart` + every Either render site |
| `map` | `loadAll` — `Either<…, List<String>>` → `LedgerData` |
| `mapLeft` | `import.dart` — stamps the line number onto a field error |
| `flatMap` | `parseRow` → duplicate check chained on the parsed `Entry` |
| `swap` | `health_screen.dart` — the "Problems only" list reuses the OK renderer by swapping sides (**thin**) |
| `getOrNull` | `restoreLastCategory` bridge to nullable-first UI |
| `leftOrNull` | import dialog row tooltip |
| `getOrElse` | unknown category → the `Uncategorized` fallback |
| `onLeft` / `onRight` | import dialog's ok/failed counters, tallied in the pass-through |
| `toEitherNel` | fail-fast row result lifted into the file-level accumulating scope |
| `recover` | `Either.recover` — an unknown category recovers by auto-creating one, or raises `RowError` if the name is also empty |
| `Either.catching` | pasted-text decode (`utf8`/CSV) — captures a thrown decoder error |
| `Either.catchingWith` | `DateTime` arithmetic in `vDate`, thrown → `FieldError` |

### `raise.dart`

| Member | Call site |
| ------ | --------- |
| `Raise.raise` | every validator in `validate.dart` |
| `either` | `parseRow`, `validateDraft`, `auditLedger` |
| `eitherAsync` | `LedgerState.load()` |
| `foldRaise` | `errors.dart` — the app's own builder `issueOr<A>()`, folding a raise into the `(A?, LedgerError?)` record the widget layer prefers. The primitive is public precisely for this |
| `foldRaiseAsync` | async twin of `issueOr`, used by `loadAll`'s partial-data path |
| `nullable` | `budgetStatusFor`, `runwayEstimate` |
| `nullableAsync` | `restoreLastCategory` |
| `SingletonRaise.bind` | `budgetStatusFor` — `r.bind(d.budgets[id])` |
| `SingletonRaise.ensure` | `runwayEstimate` — `r.ensure(months.length >= 2)` |
| `SingletonRaise.ensureNotNull` | `restoreLastCategory` |
| `SingletonRaise.none` | `runwayEstimate` early exit on a non-negative net |
| `catching` | `double.parse` / `int.parse` inside validators |
| `catchingAsync` | Hive box read in `readBox` |
| `RaiseOps.bind` | `parseRow` — binds the field-level `Either` |
| `RaiseOps.bindAll` | import "Apply" — binds every row at once in strict mode |
| `RaiseOps.ensure` | column-count / title / amount checks |
| `RaiseOps.ensureNotNull` | `splitCsvLine`, category lookup |
| `RaiseOps.recover` | audit rule that downgrades `due-before-date` to a warning when the entry is already `done` |
| `RaiseOps.withError` | `FieldError` → `RowError` adapter in `parseRow` |
| `RaiseLeakedError` | the "When this bites" card + `health_test.dart` |

### `non_empty_list.dart`

| Member | Call site |
| ------ | --------- |
| `Nel` (alias) | `RowError.fields`, `LedgerState.loadError` |
| `NonEmptyList` (full name) | `error_panel.dart`'s public field type — the alias and the full name both appear so readers meet both |
| `NonEmptyList.of` | `RowError(line, Nel.of(f))` in `withError` |
| `NonEmptyList.orNull` | `ErrorPanel` construction from an accumulated `List` — `null` means *no panel* |
| `head` | panel headline |
| `tail` | "and N more" disclosure |
| `map` | `errors.map((e) => e.message)` for the clipboard report |
| `operator +` | import dialog merges header errors + row errors |
| `deepEquals` | `AnimatedSwitcher` change detection (§4.4) |
| `toList` | clipboard "Copy report" defensive copy |

### `accumulate.dart`

| Member | Call site |
| ------ | --------- |
| `AccumulatingRaiseOps.accumulate` | `parseCsvEntries` file-level scope (4 branches) |
| `Accumulator.accumulating` | those 4 branches |
| `Accumulator.hasErrors` | "Import anyway (N rows)" affordance, read before any `.value` |
| `Accumulated.value` | the end-of-block combine that detonates |
| `zipOrAccumulate2` | budget editor dialog (category + limit) — **done, round 11** |
| `zipOrAccumulate3` | recurring-rule editor — *the editor does not exist yet*; round 12 builds it as a feature (rules are projected on Insights but uneditable) |
| `zipOrAccumulate4` | shareable view-link parser — *needs the Entries/Insights filter state lifted into `LedgerState` first*; round 12 |
| `zipOrAccumulate5` | **`validateDraft`** — the headline feature. Done, round 11 |
| `AccumulatingRaiseOps.accumulate` | `parseRowAll` — the CSV row's field-level pass. Raw `accumulate` rather than a sixth `zipOrAccumulateN` **because the amount rule depends on the type branch**, and a dependent check cannot sit alongside what it depends on (reading a sibling's `Accumulated.value` detonates). Done, round 11 |
| `AccumulatingRaiseOps.bindNel` | round 13's Health audit: an outer `Raise<Nel<LedgerError>>` folding a rule's `EitherNel`. (Not the importer — its outer scope raises `RowError`, so plain `bind` is correct there.) |
| `AccumulatingRaiseOps.mapOrAccumulate` | Report mode — all rows × all fields in one pass |
| `AccumulatingRaise.bindNel` | same, from inside a branch |
| `AccumulatingRaise.mapOrAccumulate` | nested per-row accumulation inside the "rows" branch |
| `AccumulatingRaise.over` | `import.dart` `_rowCells` — the single-error view of an accumulating scope, so a row's *structural* checks (cell count, quoting) stay fail-fast while its *field* checks accumulate. Done, round 11; this turned out to be a better home than the `health.dart` one originally guessed |

### `fx_either.dart`

| Member | Call site |
| ------ | --------- |
| `FxEitherOps.separated()` | import Lenient mode |
| `FxEitherOps.sequence()` | import Strict mode |
| `FxEitherOps.rights()` | Health "ok count" badge |
| `FxEitherOps.lefts()` | Health "problem count" badge |
| `FxAccumulateOps.mapOrAccumulate` | import Report mode |
| `separateEither` (top-level) | `health.dart` over a plain `List` |
| `sequenceEither` (top-level) | `health.dart` strict contrast card |
| `rights` / `lefts` (top-level) | `health.dart` contrast card |
| `mapOrAccumulate` (top-level) | `health.dart` contrast card — three terminals, one input, side by side |
| `FxAsyncEitherOps.sequence()` | `loadAll` strict path (loading-screen toggle) |
| `sequenceEitherAsync` | same, called directly in the strict branch |
| `FxAsyncAccumulateOps.mapOrAccumulate` | `loadAll` default path, `concurrency: 3` |
| `mapOrAccumulateAsync` | the `concurrency:` argument is passed here explicitly in `readAllBoxes` |

Members that are **not** given a call site, on purpose: none. If the coverage
test finds one the spec missed, the round either finds it a real home or
records it in the `⏸ intentionally uncovered` row of `plan.md` with a reason —
never a fake feature.

## 8. Tests

- `validate_test.dart` — each validator in isolation; `validateDraft` with
  1/3/5 bad fields asserting the **exact** `Nel` contents *and order* (branch
  order is part of Arrow's contract and therefore part of the app's).
- `import_test.dart` — rewritten: the three modes over one fixture file
  produce, respectively, partial entries + issues / a single `Left` / a full
  report. Round-trip with `export.dart` still holds.
- `health_test.dart` — one test per audit rule; plus the `RaiseLeakedError`
  test (a raise block returning a lazy `fx` chain).
- `errors_test.dart` — `LedgerError.message` formatting; `Nel` merge and
  `deepEquals` behaviour (including the `==`-is-identity trap).
- `filter_link_test.dart` — four bad fragment params → four errors.
- `api_coverage_test.dart` — §7's automation.
- Repository/state paths get widget-free unit tests where possible; the
  `concurrency: 3` behaviour is asserted with a fake clock the way round 1's
  load test does.

Target: **67 → ~110 tests**, `flutter analyze` clean, web build compiles.

## 9. Rounds

Same protocol as `plan.md`: each round is one commit series, 10 feedbacks +
3 suggested features, logged at the bottom of `plan.md`.

- **Round 10 — the core.** `errors.dart`, `validate.dart`, `import.dart`
  rewrite, `import_test.dart` rewrite. No UI beyond keeping the import dialog
  compiling. Chapters 1, 2, 6 (sync half).
- **Round 11 — accumulation & the form.** `validateDraft`, entry form
  rewrite with the fail-fast/fail-slow toggle, `error_panel.dart`,
  `zipOrAccumulate2/3/4` sites. Chapters 4, 5.
- **Round 12 — async & nullable.** `loadAll`, `LedgerState.loadError`,
  loading-screen error state and strict toggle, `nullable` sites.
  Chapters 3, 6 (async half).
- **Round 13 — the Health tab & explainers.** `health_screen.dart`,
  `health.dart`, the `PipelineExplanation` extensions, the typed-error link
  table, About-dialog copy, `api_coverage_test.dart`, README + `plan.md`
  refresh.

## 10. Risks

1. **`RaiseLeakedError` × laziness.** This app returns `fx(...)` chains
   everywhere. Any raise block that returns a lazy iterable detonates when the
   widget consumes it, *after* the scope closed. Rule for every round:
   **materialise inside the block** (`.toList()`), or return through
   `mapOrAccumulate` / `sequence`, which are eager terminals by design.
   Round 10 adds a lint-by-review checklist item; round 13 turns it into a
   teaching card.
2. **Error-type sprawl.** Five `LedgerError` subclasses is already the ceiling.
   Adding a sixth needs a justification in the round log.
3. **Dialogs teaching two things at once.** Each new card explains *one*
   chapter. If a card needs two, it is two cards.
4. **Rewriting for the sake of it.** Chapter coverage must never push typed
   errors into total functions (§2). The reviewer question for every diff:
   *what failure does this actually have?*
5. **`Nel` is compile-time discipline, not a runtime guarantee.** It is an
   extension type: it erases to `List`, so `<T>[] as Nel<T>` *succeeds*. The
   app must build every `Nel` through `Nel.of` / `Nel.orNull` and never cast —
   a cast would put an empty list behind `ErrorPanel`'s `head`, which is the
   one thing the type is there to prevent. Round 11 adds a review checklist
   item; `errors_test.dart` pins the trap.

   (No SDK work needed: the dot-shorthand returns want Dart 3.10.4+, and the
   example already requires `^3.12.2` — comfortably above the library's floor.)
