import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isNull, isNotNull, isList, isMap;

Object? _returnNull() => null;

void main() {
  group('isNull', () {
    test('given non null then should be false', () {
      for (final a in <Object?>[2, true, {}, [], 'a', _returnNull]) {
        expect(isNull(a), isFalse, reason: 'value: $a');
      }
    });

    test('given null then should be true', () {
      expect(isNull(null), isTrue);
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
      expect(isNil(null), isTrue);
      expect(isNil(3), isFalse);
      expect(isNil('3'), isFalse);
      expect(isNil({}), isFalse);
      expect(isNil(false), isFalse);
    });
  });

  group('isUndefined (deprecated alias of isNull)', () {
    test('given non null then should be false', () {
      for (final a in <Object?>[2, true, {}, [], 'a']) {
        // ignore: deprecated_member_use
        expect(isUndefined(a), isFalse, reason: 'value: $a');
      }
    });

    test('given null then should be true', () {
      // ignore: deprecated_member_use
      expect(isUndefined(null), isTrue);
    });
  });

  group('isBool', () {
    test('given non boolean then should return false', () {
      for (final s in <Object?>[null, 1, '1', _returnNull, [], {}]) {
        expect(isBool(s), isFalse, reason: 'value: $s');
      }
    });

    test('given boolean then should return true', () {
      expect(isBool(true), isTrue);
      expect(isBool(false), isTrue);
    });
  });

  group('isNum', () {
    test('given non number then should return false', () {
      for (final s in <Object?>[null, true, '1', _returnNull, [], {}]) {
        expect(isNum(s), isFalse, reason: 'value: $s');
      }
    });

    test('given number then should return true', () {
      expect(isNum(2), isTrue);
      expect(isNum(2.5), isTrue);
    });
  });

  group('isString', () {
    test('given non string then should return false', () {
      for (final s in <Object?>[null, true, 1, _returnNull, [], {}]) {
        expect(isString(s), isFalse, reason: 'value: $s');
      }
    });

    test('given string then should return true', () {
      expect(isString('a'), isTrue);
      expect(isString(''), isTrue);
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
        expect(isList(s), isFalse, reason: 'value: $s');
      }
    });

    test('given list then should return true', () {
      expect(isList([1, 2, 3]), isTrue);
      expect(isList(<Object?>[]), isTrue);
    });
  });

  group('isArray (deprecated alias of isList)', () {
    test('given non list then should return false', () {
      for (final s in <Object?>[null, true, 1, 'a', _returnNull, {}]) {
        // ignore: deprecated_member_use
        expect(isArray(s), isFalse, reason: 'value: $s');
      }
    });

    test('given list then should return true', () {
      // ignore: deprecated_member_use
      expect(isArray([1, 2, 3]), isTrue);
    });
  });

  group('isMap', () {
    test('should return whether the given value is a Map', () {
      expect(isMap({}), isTrue);
      expect(isMap({'a': 1}), isTrue);
      expect(isMap([]), isFalse);
      expect(isMap(123), isFalse);
      expect(isMap('abc'), isFalse);
      expect(isMap(null), isFalse);
    });
  });

  group('isObject (deprecated alias of isMap)', () {
    test('should return whether the given value is a Map', () {
      // In Dart, plain objects are Maps; lists and functions are not.
      // ignore: deprecated_member_use
      expect(isObject({}), isTrue);
      // ignore: deprecated_member_use
      expect(isObject({'a': 1}), isTrue);
      // ignore: deprecated_member_use
      expect(isObject([]), isFalse);
      // ignore: deprecated_member_use
      expect(isObject(123), isFalse);
      // ignore: deprecated_member_use
      expect(isObject('abc'), isFalse);
      // ignore: deprecated_member_use
      expect(isObject(null), isFalse);
    });
  });
}
