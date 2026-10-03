import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isNull, isNotNull, isList, isMap;

Object? _returnNull() => null;

void main() {
  group('isNull', () {
    test('given non null then should be false', () {
      for (final a in <Object?>[2, true, {}, [], 'a', _returnNull]) {
        expect(fxIsNull(a), isFalse, reason: 'value: $a');
      }
    });

    test('given null then should be true', () {
      expect(fxIsNull(null), isTrue);
    });
  });

  group('isNotNull', () {
    test('should be the negation of isNull', () {
      expect(isNotNull(null), isFalse);
      expect(isNotNull(0), isTrue);
      expect(isNotNull(''), isTrue);
    });
  });

  group('isNil', () {
    test('should check if given value is null', () {
      expect(fxIsNil(null), isTrue);
      expect(fxIsNil(3), isFalse);
      expect(fxIsNil('3'), isFalse);
      expect(fxIsNil({}), isFalse);
      expect(fxIsNil(false), isFalse);
    });
  });

  group('isUndefined (deprecated alias of isNull)', () {
    test('given non null then should be false', () {
      for (final a in <Object?>[2, true, {}, [], 'a']) {
        // ignore: deprecated_member_use
        expect(fxIsUndefined(a), isFalse, reason: 'value: $a');
      }
    });

    test('given null then should be true', () {
      // ignore: deprecated_member_use
      expect(fxIsUndefined(null), isTrue);
    });
  });

  group('isBool', () {
    test('given non boolean then should return false', () {
      for (final s in <Object?>[null, 1, '1', _returnNull, [], {}]) {
        expect(fxIsBool(s), isFalse, reason: 'value: $s');
      }
    });

    test('given boolean then should return true', () {
      expect(fxIsBool(true), isTrue);
      expect(fxIsBool(false), isTrue);
    });
  });

  group('isNum', () {
    test('given non number then should return false', () {
      for (final s in <Object?>[null, true, '1', _returnNull, [], {}]) {
        expect(fxIsNum(s), isFalse, reason: 'value: $s');
      }
    });

    test('given number then should return true', () {
      expect(fxIsNum(2), isTrue);
      expect(fxIsNum(2.5), isTrue);
    });
  });

  group('isString', () {
    test('given non string then should return false', () {
      for (final s in <Object?>[null, true, 1, _returnNull, [], {}]) {
        expect(fxIsString(s), isFalse, reason: 'value: $s');
      }
    });

    test('given string then should return true', () {
      expect(fxIsString('a'), isTrue);
      expect(fxIsString(''), isTrue);
    });
  });

  group('isDateTime', () {
    test('given non DateTime then should return false', () {
      for (final v in <Object?>[
        null,
        true,
        1,
        '2024-01-01',
        _returnNull,
        {},
        [],
      ]) {
        expect(isDateTime(v), isFalse, reason: 'value: $v');
      }
    });

    test('given DateTime then should return true', () {
      expect(isDateTime(DateTime.now()), isTrue);
    });
  });

  group('isList', () {
    test('given non list then should return false', () {
      for (final s in <Object?>[null, true, 1, 'a', _returnNull, {}]) {
        expect(fxIsList(s), isFalse, reason: 'value: $s');
      }
    });

    test('given list then should return true', () {
      expect(fxIsList([1, 2, 3]), isTrue);
      expect(fxIsList(<Object?>[]), isTrue);
    });
  });

  group('isArray (deprecated alias of isList)', () {
    test('given non list then should return false', () {
      for (final s in <Object?>[null, true, 1, 'a', _returnNull, {}]) {
        // ignore: deprecated_member_use
        expect(fxIsArray(s), isFalse, reason: 'value: $s');
      }
    });

    test('given list then should return true', () {
      // ignore: deprecated_member_use
      expect(fxIsArray([1, 2, 3]), isTrue);
    });
  });

  group('isMap', () {
    test('should return whether the given value is a Map', () {
      expect(fxIsMap({}), isTrue);
      expect(fxIsMap({'a': 1}), isTrue);
      expect(fxIsMap([]), isFalse);
      expect(fxIsMap(123), isFalse);
      expect(fxIsMap('abc'), isFalse);
      expect(fxIsMap(null), isFalse);
    });
  });

  group('isObject (deprecated alias of isMap)', () {
    test('should return whether the given value is a Map', () {
      // In Dart, plain objects are Maps; lists and functions are not.
      // ignore: deprecated_member_use
      expect(fxIsObject({}), isTrue);
      // ignore: deprecated_member_use
      expect(fxIsObject({'a': 1}), isTrue);
      // ignore: deprecated_member_use
      expect(fxIsObject([]), isFalse);
      // ignore: deprecated_member_use
      expect(fxIsObject(123), isFalse);
      // ignore: deprecated_member_use
      expect(fxIsObject('abc'), isFalse);
      // ignore: deprecated_member_use
      expect(fxIsObject(null), isFalse);
    });
  });
}
