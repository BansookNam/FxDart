import 'package:flutter/material.dart';
import 'package:fxdart/fxdart.dart' show Left, Nel, Right, find, fx;

import '../logic/errors.dart';
import '../logic/validate.dart';
import '../models/models.dart';
import 'app_shell.dart';
import 'error_panel.dart';
import 'format.dart';
import 'widgets.dart';

/// Add or edit one monthly budget (typed-errors series, round 11).
///
/// Round 1 shipped this as an amount-only dialog that did
/// `double.tryParse(...)` and **silently closed** when the text was not a
/// number — the user got no budget and no explanation. Now it is two
/// independent fields validated by `zipOrAccumulate2`, so picking the wrong
/// category *and* typing a bad number is one round-trip, not two.
///
/// Pass [existing] to edit that category's limit; omit it to add a budget
/// for a category that has none.
Future<void> showBudgetDialog(
  BuildContext context, {
  String? existingCategoryId,
  double? existingLimit,
}) => showDialog(
  context: context,
  builder: (_) => _BudgetDialog(
    lockedCategoryId: existingCategoryId,
    initialLimit: existingLimit,
  ),
);

class _BudgetDialog extends StatefulWidget {
  final String? lockedCategoryId;
  final double? initialLimit;
  const _BudgetDialog({this.lockedCategoryId, this.initialLimit});

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late final _amount = TextEditingController(
    text: widget.initialLimit?.toStringAsFixed(0) ?? '',
  );
  late String? _categoryId = widget.lockedCategoryId;
  bool _attempted = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  BudgetDraft _draft() =>
      BudgetDraft(categoryId: _categoryId, amount: _amount.text);

  void _save(Map<String, Category> byId) {
    setState(() => _attempted = true);
    switch (validateBudget(_draft(), byId)) {
      case Left():
        break; // rendered below
      case Right(:final value):
        final (category, limit) = value;
        LedgerScope.of(context).setBudget(category.id, limit);
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    final locked = widget.lockedCategoryId != null;
    // Adding: only money categories that have no budget yet. Editing: the
    // one being edited.
    final choices = locked
        ? fx(state.categories).filter((c) => c.id == widget.lockedCategoryId).toList()
        : fx(state.categories)
              .filter(
                (c) =>
                    c.kind == CategoryKind.money &&
                    !state.budgets.containsKey(c.id),
              )
              .toList();

    final errors = _attempted
        ? validateBudget(_draft(), state.categoryIndex).leftOrNull()
        : null;
    String? errorFor(String field) => errors == null
        ? null
        : find((FieldError e) => e.field == field, errors)?.detail;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(locked ? 'Edit budget' : 'Add budget')),
          PipelineHelpButton(explain: () => _explain(errors)),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: InputDecoration(
                labelText: 'Category',
                border: const OutlineInputBorder(),
                errorText: errorFor('category'),
                helperText: locked
                    ? null
                    : choices.isEmpty
                    ? 'Every money category already has a budget'
                    : null,
              ),
              items: [
                for (final c in choices)
                  DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        Icon(categoryIcon(c), size: 18, color: categoryColor(c)),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  ),
              ],
              onChanged: locked
                  ? null
                  : (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                if (_attempted) setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Monthly limit',
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
                errorText: errorFor('amount'),
              ),
            ),
            if (errors != null)
              ErrorPanel(errors: errors, title: 'Cannot save', copyable: false),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _save(state.categoryIndex),
          child: const Text('Save'),
        ),
      ],
    );
  }

  PipelineExplanation _explain(Nel<FieldError>? errors) => PipelineExplanation(
    title: 'Saving a budget',
    formula:
        'either((r) => r.zipOrAccumulate2(\n'
        '  vCategoryId, vBudgetLimit,\n'
        '  (category, limit) => (category, limit)))',
    steps: [
      PipelineStep(
        'zipOrAccumulate2',
        'the category and the limit are independent, so both are checked '
            'and both problems come back together',
        '2 branches',
      ),
      PipelineStep(
        'vCategoryId(…, EntryType.expense, …)',
        'reused verbatim from the entry form — "budgets apply to money '
            'categories" is the same rule as "an expense needs a money '
            'category"',
        errors == null || find((FieldError e) => e.field == 'category', errors) == null
            ? 'ok'
            : 'raised',
      ),
      PipelineStep(
        'vBudgetLimit',
        'vAmountValue plus one ensureNotNull: blank is "no money" on an '
            'entry, but a budget with no number is not a budget',
        errors == null || find((FieldError e) => e.field == 'amount', errors) == null
            ? 'ok'
            : 'raised',
      ),
    ],
    result: errors == null
        ? 'Right — (Category, double), ready to store'
        : 'Left — ${errors.length} problem${errors.length == 1 ? '' : 's'}: '
              '${errors.map((e) => e.field).join(', ')}',
  );
}
