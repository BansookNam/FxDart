# Functional Programming Theory — content plan

Status: **complete in English and Korean — 22 chapters + 3 appendices.**
74 runnable listings, all verified by `dart run tool/check_theory.dart`;
24 figures. Korean is 100% (299/299 site-wide) and its listings are checked
byte-for-byte against the English source on every run of the checker.

This file is the working plan for the theory textbook at `docs/theory/`
(sources in `content/theory/`, viewer described in the root `CLAUDE.md`).

---

## 0. What this book is

- **Title** — *Functional Programming Theory* (cover subtitle: "The ideas behind
  the pipeline — for working Dart developers"). Cover strings live in
  `content/chrome.arb` (`theoryTitle` / `theorySubtitle` / `theoryByline`), so
  they translate with the chrome.
- **Reader** — a working Dart developer. Knows Dart, generics, `async`/`await`,
  and has probably used FxDart or RxDart. Knows no Haskell and no category
  theory, and is not required to learn either to finish a chapter.
- **Promise** — after each chapter the reader can *name* a structure they were
  already using, *say what it guarantees*, and *predict* how an unfamiliar API
  with the same shape will behave.
- **Relationship to the rest of the site**
  - `content/tutorials/` answers "how do I call this function".
  - `docs/DartComparison` + `docs/RxDartComparison` answer "should I".
  - This book answers "why does it have that shape, and what does the shape
    guarantee". It links *out* to tutorials; tutorials may link *in* to a
    chapter anchor (`theory/#ch7`).
  - The Korean book (`fxdart-book`, private, metaphor-first, for teenagers) is a
    different work with a different reader. Nothing is copied between them; the
    shared inheritance is the visual language and the manuscript format.

### Non-goals

- Not an API reference, not a tutorial, not a marketing document.
- No claim that FP is always better. Chapter 14 and Chapter 22 exist to say
  where it is not, with measurements from the benchmark suite behind them.
- No formalism for its own sake. Category theory appears twice: as a depth box
  in Chapter 1 and as its own chapter (20) that the reader can skip entirely.

---

## 1. Conventions every chapter follows

### Anatomy

```
# <Chapter title>
> **In this chapter** — 3–4 bullets, each a capability, not a topic
## <Motivating section>       ← code the reader recognises, before any term
## <The idea, named>          ← the term, defined against what they just saw
## <Figures + laws/mechanics>
## What FxDart actually implements    ← honest, per-type, names the gaps
## When this earns its keep           ← and when it does not
## Exercises        (4, ordered easy → "makes you look something up")
## Solutions        (full, with the reasoning, not just the answer)
```

### Prose rules

1. **Instance before abstraction.** Never define a structure before the reader
   has run code that has it. Chapter 1 opens with `expand`/`then`/`flatMap`,
   not with "a monad is…".
2. **Name the thing they already do.** The reward sentence in every chapter is
   some version of "you have been writing this for years; here is its name".
3. **Honesty over advocacy** — the site's verdict culture. If Dart cannot
   express something, say so, show the code that fails to compile, and explain
   what FxDart does instead (Chapter 1 §"What FxDart actually implements" is
   the template).
4. **No unexplained jargon.** A term is introduced once, in bold, with its
   aliases in parentheses (`flatMap` / `bind` / `>>=`), and lands in the
   glossary appendix.
5. **Every numeric or behavioural claim is verified** by running the code.

### Code rules

- Listings are fenced ```` ```dart ```` ; add ` run` to make them executable.
  Only mark a listing runnable when its output is worth seeing.
- **≤ 66 columns.** Wider lines wrap inside the page box and read as broken
  typography. Check with the width script before publishing.
- Every runnable listing must be executed with `dart run` inside this repo
  (a scratch file, deleted afterwards) and its printed output must match what
  the prose claims. Listings that show a compile error are *not* marked `run`
  and say so in a comment on line 1.
- Prefer FxDart's real API over pseudo-code. If an example needs a type FxDart
  does not have (`Logged` in Chapter 1), define it inline in the listing.
- **Code is locale-invariant.** Translations copy the listing verbatim,
  comments included, and translate only prose. Rationale: two copies of a
  program drift, and a Korean comment cannot be verified by the same
  `dart run` audit.

### Figures

Same visual language as the print book (`fxdart-book/CLAUDE.md` §"시각 언어"),
adapted to this viewer:

| Token | Meaning |
|---|---|
| `--fp-value` blue circle | a value |
| `--fp-op` purple | an operation / function |
| `--fp-ok` green circle + ✓ | success, `Right` |
| `--fp-err` red square + ✗ | failure, `Left` (failure only — never "not selected") |
| `--fp-time` orange | time, async |
| `--fp-lazy` grey dashed | work that has not happened yet |

- Colours are referenced as `var(--fp-x, #fallback)`; the viewer defines them on
  `#book-stage` (fixed light palette — the book is paper in both themes).
- `viewBox` width **560** and base font-size 13–15px: the page box is ~484px
  wide, so a 560-wide figure renders near 1:1 and text stays legible.
- Ids are namespaced at build time, so `id="a1"` in two figures is safe.
- Text must not overlap shapes: place it in empty space first, and check the
  right edge (`text-anchor="end"` near `x=544`) — clipping is the failure mode
  that survived review twice already.
- 1–3 figures per chapter. One figure that carries the chapter's mental model
  beats three that decorate it; only Chapter 1 needed three.

### Length

The page box is ~560×700 CSS px. Measured: chapter 1 ≈ 18 pages including
exercises and solutions. **Budget ≤ 20 pages; split rather than compress.**
Rules of thumb: a figure ≈ ⅔ page, a 25-line listing ≈ ⅔ page, a depth box
≈ ⅓ page.

### i18n

- English is the source of truth; `i18n/ko/theory/` is a complete translation.
  `tool/check_theory.dart` fails if any translated chapter's fenced blocks
  differ from the English ones — prose is translated, programs never are. Other locales fall back to English with the standard
  "not yet translated" banner; their chrome (nav, Contents, ▶ Run, Output) is
  translated so the viewer is not half-English.
- Front matter: only `title` and `description` may differ per locale. `slug`,
  `chapter`, `part` are structure and are checked at build time.
- After translating, `dart run tool/build_docs.dart --record` **in the same
  commit** as the English edit.

---

## 2. Chapter list

Five parts, 22 chapters, 3 appendices — all written and live. "Figs" is the number of SVG figures in the chapter.

### Part I · Shapes you already use

| # | Chapter | Covers | Figs |
|---|---|---|---|
| 1 | What a monad actually is | The shape behind `expand`/`then`/`flatMap`; two operations, three laws, and why Dart cannot declare `Monad` | 3 |
| 2 | Purity and effects | Referential transparency as substitution; what purity buys; where Dart hides effects | 1 |
| 3 | Making illegal states unrepresentable | Sums and products, `sealed` + exhaustive `switch`, records; counting a type’s states | 1 |
| 4 | Functions as values | Composition, partial application, currying, and why FxDart ships chains not a curried `pipe` | 1 |

### Part II · The tower

| # | Chapter | Covers | Figs |
|---|---|---|---|
| 5 | Functor | `map` and its two laws; the composition law as the licence for stage fusion | 1 |
| 6 | Applicative | Independent vs dependent steps; why accumulation cannot be monadic | 1 |
| 7 | Monad, in anger | Kleisli composition, the pyramid, do-notation in four languages, `async`/`await` | 1 |
| 8 | Monoid and semigroup | Identity and associativity; `fold` vs `reduce`; why errors accumulate into `Nel` | 1 |
| 9 | Traverse | Swapping structures; the applicative decides the failure policy; four spellings | 1 |
| 10 | The missing floor | Kinds, the exact Dart limitation, the `Kind` encoding and its cost | 1 |

### Part III · Evaluation

| # | Chapter | Covers | Figs |
|---|---|---|---|
| 11 | Laziness | Descriptions vs executions; work proportional to consumption; the two hazards | 1 |
| 12 | Pull and push | The duality; backpressure; why FxDart is not built on `Stream`; the bridges | 1 |
| 13 | Concurrency as an effect | `concurrent(n)`: when, not what; the back-channel; order and its price | 1 |
| 14 | What the abstractions cost | 53 measured tasks; three mechanisms; how to decide for your own code | 1 |

### Part IV · Failure

| # | Chapter | Covers | Figs |
|---|---|---|---|
| 15 | The Raise scope | Delimited continuation vs desugaring; the three scopes; the leak rule | 1 |
| 16 | Either as a railway | Two tracks; `mapLeft` and composing error types; where totality returns | 1 |
| 17 | Accumulating failure | The four tools; independent vs dependent rules; a form end to end | 1 |
| 18 | The honest boundary | Three failure channels; what typed errors cannot promise; converting at edges | 1 |

### Part V · Laws and lineage

| # | Chapter | Covers | Figs |
|---|---|---|---|
| 19 | Equational reasoning | Refactoring as licensed rewrites; laws as property tests; the preconditions | 1 |
| 20 | Category theory, in the right dose | Categories, functors, natural transformations, the monad triple, the famous sentence | 1 |
| 21 | Lineage | Haskell → Scala → Arrow → FxTS → FxDart, and what each translation dropped | 1 |
| 22 | When not to use any of this | Five shapes where the loop wins; the unlisted costs; the checklist | 1 |

### Appendices

| Appendix | Covers |
|---|---|
| A · Glossary | every bolded term, its aliases across languages, its Dart spelling, and its chapter |
| B · Law reference | each law with the refactor it licenses, what breaks it, and a runnable property-test template |
| C · Further reading | in-project sources, the four ancestors, papers and books, each with a difficulty note |

## 3. What shipped, and what it measured

Written in file order, verified per batch. Final shape:

| | |
|---|---|
| Chapters | 22 + 3 appendices |
| Pages (at 560×700) | 270 |
| Runnable listings | 74, all executed against this package |
| Figures | 24 SVG, palette-driven |
| Exercises | 4 per chapter, with full solutions |

The per-chapter unit that held up in practice: ~1,800–2,200 words, 3–6
verified listings, 1–2 figures, 4 exercises. Chapters land at 10–14 pages,
comfortably inside the 20-page budget.

`dart run tool/check_theory.dart [NN …]` runs every `dart run` listing, prints
its real output, and enforces the 66-column rule. It is the gate for any
future edit: the book asserts what programs print, so a failing listing is a
factual error in the prose.

## 4. Per-chapter production checklist

1. Draft `content/theory/NN-slug.md` (front matter first — `chapter` and `part`
   are structural and must match across locales).
2. Extract every ```` ```dart run ```` listing to a scratch file in the repo,
   `dart run` each, paste the real output into the prose, delete the scratch.
3. Run the ≤ 66-column check over all listings.
4. Draw figures into `content/theory/diagrams/tN-M-slug.svg` using the palette
   variables; no hard-coded colours.
5. `dart run tool/build_docs.dart`, then read the chapter **in the viewer** at
   a 1400×900 viewport: check page breaks, that no figure is orphaned from its
   caption, that Exercises land on a recto and Solutions after the turn, and
   that ▶ Run prints what the prose says.
6. Translate to `i18n/ko/theory/NN-slug.md` (prose only, listings verbatim),
   then `--record` in the same commit.
7. If the chapter introduces terms, add them to Appendix A.

## 5. Deferred / backlog

Known gaps, in the order they will start to matter:


- **Mobile.** The viewer scales the whole spread to fit, so a phone gets a
  legible-but-small two-page spread. A single-page mode (one page per turn
  under ~760px) is the fix, and it is now cheap: the viewer already renders
  one spread at a time into two slots, so the change is hiding one slot and
  stepping by one page instead of two.
- ~~**Precompiled listings.**~~ Done: all 74 listings are precompiled into
  `docs/pg/` and stamped with `data-pg`; a warm run prints in ~200ms. Re-run
  `precompile_playgrounds.dart --only=content/theory` after editing any
  listing, or the page silently falls back to the compile service.
- **Print/PDF.** `@media print` currently hides the viewer entirely. A print
  stylesheet that lays the manuscript out as a flowing document (and a PDF
  build) is a separate deliverable.
- **Search.** No in-book search; the browser's find only sees the current
  spread (by design — only two pages are ever in the DOM).
- **Deep links.** `#chN` opens a chapter and `#chN-M` its Mth page — the same
  anchor the language links carry, so a locale switch keeps your place.
  Section-level anchors are not routed yet (headings do carry `id="chN-slug"`,
  but the slug is empty for non-Latin headings, so it cannot be shared across
  translations).
- **More locales.** en and ko are complete books; zh-Hans/ja/es/pt-BR/ru have
  translated chrome and render the English text with a notice in the HUD.
- **Cross-links.** Chapters reference each other by number in prose; only
  `#chN` deep links are wired. Turning those references into links, and linking
  the relevant tutorials into the book (and back), is a mechanical pass worth
  doing once the numbering is stable.
- **A per-chapter index.** 270 pages with no search: the browser's find only
  sees mounted pages, so an in-book index or search box is the next real
  usability gap.
