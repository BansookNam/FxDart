import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('FxSubscriptions', () {
    test('starts empty and reports its size', () {
      final bag = FxSubscriptions();
      expect(bag.isEmpty, isTrue);
      expect(bag.isNotEmpty, isFalse);
      expect(bag.length, 0);
    });

    test('add returns the subscription it was handed', () async {
      final bag = FxSubscriptions();
      final c = StreamController<int>();
      final sub = c.stream.listen((_) {});
      expect(bag.add(sub), same(sub));
      expect(bag.length, 1);
      expect(bag.isNotEmpty, isTrue);
      await bag.cancelAll();
      await c.close();
    });

    test('addAll takes a batch', () async {
      final bag = FxSubscriptions();
      final controllers = [StreamController<int>(), StreamController<int>()];
      bag.addAll(controllers.map((c) => c.stream.listen((_) {})));
      expect(bag.length, 2);
      await bag.cancelAll();
      for (final c in controllers) {
        await c.close();
      }
    });

    test('cancelAll stops every subscription and empties the bag', () async {
      final bag = FxSubscriptions();
      final a = StreamController<int>();
      final b = StreamController<int>();
      final seen = <int>[];
      bag
        ..add(a.stream.listen(seen.add))
        ..add(b.stream.listen(seen.add));

      a.add(1);
      b.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, 2]));

      await bag.cancelAll();
      expect(bag.isEmpty, isTrue);
      expect(bag.length, 0);

      a.add(3);
      b.add(4);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, 2]), reason: 'cancelled subscriptions are deaf');

      await a.close();
      await b.close();
    });

    test(
      'cancelAll on an empty bag is a no-op, and the bag is reusable',
      () async {
        final bag = FxSubscriptions();
        await bag.cancelAll();

        final c = StreamController<int>();
        final seen = <int>[];
        bag.add(c.stream.listen(seen.add));
        c.add(1);
        await Future<void>.delayed(Duration.zero);
        expect(seen, equals([1]));

        await bag.cancelAll();
        await c.close();
      },
    );

    test('pauseAll buffers and resumeAll releases', () async {
      final bag = FxSubscriptions();
      final a = StreamController<int>();
      final b = StreamController<int>();
      final seen = <int>[];
      bag
        ..add(a.stream.listen(seen.add))
        ..add(b.stream.listen(seen.add));

      bag.pauseAll();
      a.add(1);
      b.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen, hasLength(0));

      bag.resumeAll();
      await Future<void>.delayed(Duration.zero);
      expect(seen, unorderedEquals([1, 2]));

      await bag.cancelAll();
      await a.close();
      await b.close();
    });
  });
}
