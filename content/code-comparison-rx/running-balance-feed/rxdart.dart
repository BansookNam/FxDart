import 'package:rxdart/rxdart.dart';

// Deposits (+) and withdrawals (−) against an account opened at zero.
const moves = [250, -80, 120, -40, 500, -320, 90];

Future<void> main() async {
  final balances = await Stream.fromIterable(moves)
      .scan<int>((acc, move, _) => acc + move, 0)
      .toList();

  for (final b in balances) {
    print('Balance: $b');
  }
}
