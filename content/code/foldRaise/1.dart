import 'package:fxdart/fxdart.dart';

typedef Outcome<A> = ({A? value, String? error});

/// A builder of your own, in one call: fxEither and fxNullable
/// are written exactly this way.
Outcome<A> outcome<A>(A Function(Raise<String> r) block) =>
    fxFoldRaise<String, A, Outcome<A>>(
      block,
      onValue: (value) => (value: value, error: null),
      onRaise: (error) => (value: null, error: error),
    );

Future<void> main() async {
  print(outcome((r) => 21 * 2)); // (error: null, value: 42)
  print(outcome<int>((r) => r.raise('no stock')));
  // (error: no stock, value: null)

  // Nested scopes: a raise from the OUTER scope passes the inner
  // fold untouched and lands where it belongs.
  final nested = fxEither<String, int>(
    (outer) => fxFoldRaise<int, int, int>(
      (inner) => outer.raise('outer error'),
      onValue: (v) => v,
      onRaise: (code) => -code, // never called
    ),
  );
  print(nested); // Left(outer error)

  // The async twin: the block and every handler may await.
  final total = await fxFoldRaiseAsync<String, int, String>(
    (r) async {
      final prices = await Future.value([3, 4, 5]);
      r.ensure(prices.isNotEmpty, () => 'empty cart');
      return fxSum(prices).toInt();
    },
    onValue: (sum) async => 'total $sum',
    onRaise: (error) => 'failed: $error',
  );
  print(total); // total 12
}
