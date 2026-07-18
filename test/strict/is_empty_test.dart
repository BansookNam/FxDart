import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty;

void main() {
  group('isEmpty', () {
    final testParameters = <(Object?, bool)>[
      (1, false),
      (0, false),
      (false, false),
      (true, false),
      (DateTime.now(), false),
      (null, true),
      (<String, Object?>{}, true),
      ({'a': 1}, false),
      (<Object?>[], true),
      ([1], false),
      ('', true),
      ('a', false),
      (<Object, Object>{}, true),
      ({'key': 'value'}, false),
      (<Object>{}, true),
      ({'value'}, false),
      (() {}, false),
    ];

    test('should return `true` if the given value is an empty value', () {
      for (final (input, expected) in testParameters) {
        expect(isEmpty(input), equals(expected), reason: 'input: $input');
      }
    });
  });
}
