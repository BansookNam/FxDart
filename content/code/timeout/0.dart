import 'dart:async';

import 'package:fxdart/fxdart.dart';

/// Endpoint 3 hangs far longer than the rest.
Future<String> fetchStatus(int id) async {
  await Future.delayed(Duration(milliseconds: id == 3 ? 500 : 30));
  return 'service-$id ok';
}

void main() async {
  try {
    await fx([1, 2, 3, 4])
        .toAsync()
        .map(fetchStatus)
        .timeout(const Duration(milliseconds: 100))
        .each(print);
  } on TimeoutException {
    print('a pull exceeded 100ms — the hang became a catchable failure');
  }
  // service-1 ok
  // service-2 ok
  // a pull exceeded 100ms — the hang became a catchable failure
}
