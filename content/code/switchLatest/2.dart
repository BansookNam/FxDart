import 'dart:async';

import 'package:fxdart/fxdart.dart';

Stream<int> first() {
  final c = StreamController<int>();
  c.onListen = () {
    Timer(const Duration(milliseconds: 40), () {
      c.add(1);
      c.close();
    });
  };
  return c.stream;
}

Stream<int> later(String tag) {
  final c = StreamController<int>();
  c.onListen = () {
    print('started $tag');
    c.add(2);
    c.close();
  };
  return c.stream;
}

Future<void> main() async {
  // concat waits to subscribe to the next source until the current one
  // completes — later does not start until 1 has landed.
  print('concat:');
  final concatOut = FxEvents.concat([first(), later('concat')]).toList();
  print('subscribed concat');
  print(await concatOut); // [1, 2]

  // concatEager subscribes to EVERY source immediately and buffers later
  // events until their turn — 'started eager' prints before we even
  // return from toList().
  print('concatEager:');
  final eagerOut = concatEager([first(), later('eager')]).toList();
  print('subscribed eager');
  print(await eagerOut); // [1, 2]
}
