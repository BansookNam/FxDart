---
slug: either-railway
chapter: 16
part: 4
title: 기찻길로서의 Either
description: 선로 둘, 단계마다 분기 하나 — 단락 평가를 자명하게 만드는 그림, 그리고 오류 매핑, 복구, 실패 타입이 붙은 단계들이 파이프라인으로 합성되는 방식.
---
# 기찻길로서의 Either

> **이 장에서 다루는 것**
> - 두 선로 그림, 그리고 선로 사이를 오가는 연산은 무엇인가
> - 실패 쪽 매핑, 그리고 오류 타입이 합성되려면 왜 그것이 필요한가
> - 복구: `fold`, `getOrElse`, 그리고 프로그램이 다시 전체가 되는 지점
> - 파이프라인 안의 `Either` — `sequence`, `separate`, 그리고 실제 임포트의 모양

## 두 선로

성공 선로와 실패 선로를 나란히 그리세요. 실패할 수 있는 모든 단계는 분기입니다.
성공 선로를 계속 가거나, 아니면 한 번 실패 선로로 갈라져 나가 거기 머뭅니다.

![두 선로 기찻길](diagrams/t16-1-railway.svg)

*그림 16-1. `map`은 초록 선로에서만 실행된다. `flatMap`이 분기다. 빨간 선로를 건드리는 것은 `mapLeft`뿐이고, 명시적인 `fold` 없이는 아무것도 다시 합류하지 않는다.*

그 그림이 의미론의 전부입니다.

| 연산 | 초록 선로 (`Right`) | 빨간 선로 (`Left`) |
|---|---|---|
| `map(f)` | `f`를 적용 | 그대로 통과 |
| `flatMap(f)` | `f`를 적용, 갈라질 수 있음 | 그대로 통과 |
| `mapLeft(g)` | 그대로 통과 | `g`를 적용 |
| `fold(l, r)` | `r`을 적용 | `l`을 적용 |

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parseQty(String s) {
  final n = int.tryParse(s);
  return n == null
      ? Either.left('not a number')
      : Either.right(n);
}

void main() {
  final ok = parseQty('12');
  final bad = parseQty('twelve');

  print([ok.map((n) => n * 2), bad.map((n) => n * 2)]);
  print(ok.mapLeft((e) => 'qty: $e'));
  print(bad.mapLeft((e) => 'qty: $e'));
  print(bad.fold((e) => 'failed — $e', (n) => 'got $n'));
}
```

빨간 선로에 올라선 값은 불활성입니다. 이후의 모든 `map`과 `flatMap`이
무연산입니다. 그것이 단락 평가이고, 하류 어디에도 특별한 지원이 필요 없습니다 —
그래서 나머지를 건드리지 않고 사슬 중간에 단계를 추가할 수 있습니다.

## 오류 타입도 합성되어야 한다

오류 타입이 다른 두 단계는 이어지지 않고, 실제 코드는 대개 여기서 멈춰
섭니다.

```dart run
import 'package:fxdart/fxdart.dart';

class ParseError {
  const ParseError(this.input);
  final String input;
  @override
  String toString() => 'ParseError($input)';
}

class RangeError2 {
  const RangeError2(this.value);
  final int value;
  @override
  String toString() => 'RangeError2($value)';
}

// A common error type for the pipeline to speak.
sealed class OrderError {
  const OrderError();
}

class BadInput extends OrderError {
  const BadInput(this.detail);
  final String detail;
  @override
  String toString() => 'BadInput($detail)';
}

Either<ParseError, int> parse(String s) {
  final n = int.tryParse(s);
  return n == null ? Either.left(ParseError(s)) : Either.right(n);
}

Either<RangeError2, int> inStock(int n) =>
    n <= 5 ? Either.right(n) : Either.left(RangeError2(n));

void main() {
  // mapLeft lifts both into the pipeline's own error type.
  Either<OrderError, int> order(String raw) => either((r) {
        final n = r.bind(
            parse(raw).mapLeft((e) => BadInput('$e')));
        final ok = r.bind(
            inStock(n).mapLeft((e) => BadInput('$e')));
        return ok;
      });

  print(order('3'));
  print(order('nine'));
  print(order('9'));
}
```

실패 타입을 *국소적*으로 만들어 주는 것이 `mapLeft`입니다. 각 모듈은 자기가 아는
오류를 올리고, 호출자가 경계에서 번역합니다. 그것이 없으면 프로그램의 모든 오류를
담은 신(神) enum 하나로 끝나는데, 그것은 `Exception`을 잡는 것의 타입 있는 오류
버전입니다.

`sealed` 오류 타입(3장)이 여기서 값을 합니다. 프로그램 꼭대기에서 `OrderError`에
대한 `switch`가 빠짐없으므로, 경우를 하나 추가하면 모든 핸들러에서 컴파일
오류가 납니다.

## 복구, 그리고 전체성이 끝나는 곳

기찻길은 선로가 결국 호출자가 쓸 수 있는 무언가로 합류할 때에만 쓸모가 있습니다.
그 합류가 `fold`이고, 실패가 *무엇을 뜻하는지* 결정해야 하는 지점입니다.

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> configPort(String? raw) => raw == null
    ? Either.left('missing')
    : (int.tryParse(raw) == null
        ? Either.left('not a number: $raw')
        : Either.right(int.parse(raw)));

void main() {
  // Substitute a default — the failure was recoverable.
  print(configPort(null).fold((_) => 8080, (n) => n));

  // Keep the reason and report it — the failure was not.
  print(configPort('x')
      .fold((e) => 'config error: $e', (n) => '$n'));

  // Switch on it, exhaustively, when the type is sealed.
  final result = configPort('9000');
  final message = switch (result) {
    Left(:final value) => 'no port ($value)',
    Right(:final value) => 'port $value',
  };
  print(message);
}
```

끝맺음 셋, 규칙 하나. **프로그램은 `fold`에서 다시 전체(total)가 됩니다.** 그
전까지 실패는 선로를 따라 흐르는 데이터이고, 그 뒤로는 결정이 내려진 것입니다.
그 지점을 최대한 늦게 — HTTP 핸들러, UI, CLI의 종료 코드까지 — 미루는 것이 이
장이 주는 가장 쓸모 있는 습관입니다.

## 파이프라인 속의 Either

실제 작업에는 행이 여럿이고, 9장의 순회가 이 기찻길을 값 하나 너머로 확장하는
방법입니다.

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parseRow(String s) {
  final n = int.tryParse(s);
  return n == null ? Either.left('bad row: $s') : Either.right(n);
}

void main() {
  final rows = ['10', 'x', '30', 'y'];

  // All or nothing.
  print(fx(rows).map(parseRow).sequence());

  // Everything that failed, and everything that did not.
  final (errors, values) = separateEither(rows.map(parseRow));
  print('imported ${values.length}, rejected: $errors');

  // Keep going, but report every reason at the end.
  print(fx(rows).map(parseRow).flattenOrAccumulate());
}
```

정책 셋, 파서 하나. 그 분리 — 행 단위 함수는 정책을 전혀 모르고, 파이프라인이
정책을 고른다 — 가 두 선로 모양이 규모에서 사 주는 것입니다.

> 🎓 **철도 지향 프로그래밍, 그리고 그 비유가 새는 곳.** 대부분의 사람이 이
> 그림을 만나는 곳은 Scott Wlaschin의 "railway-oriented programming"
> 강연이고, 좋은 그림입니다 — 다만 그것은 `Either`를 *모나드적으로* 쓴 이야기의
> 절반입니다. 이 그림에는 두 열차가 모두 탈선한 경우(6장의 누적)를 그릴 방법이
> 없고, 실패가 드문 탈선인 것처럼 암시하지만 대부분의 시스템에서 실패는 자기
> 논리를 가진 평범한 결과입니다. 순차 처리에는 이 그림을 쓰고, 독립적인 결과를
> 결합해야 할 때는 내려놓으세요.

## 이것이 값을 하는 순간

호출자가 손쓸 수 있는 도메인 실패. 검증, 파싱, 권한 확인, 비즈니스 규칙, 그리고
그렇지 않았다면 nullable 반환에 주석을 붙여 표현했을 모든 것. 실패가 *정보*를
실어야 하는 곳에서 가장 값을 합니다 — 어느 규칙, 어느 필드, 어느 id인지.

아무도 손쓸 수 없는 실패에는(메모리 부족, 버그) 값을 하지 않고, 유일한 실패
방식이 "없음"인 호출 하나에도(`A?`가 더 작습니다), 아직 이름 붙일 수 없는 오류
타입에도 마찬가지입니다 — 문자열 보간으로 만든 `Either<String, T>`는 단계만 더
거친 문자열 예외입니다.

## 연습문제

1. `Left`에 대한 `map`은 아무 일도 하지 않습니다. 어느 펑터 법칙이 그것을
   강제하며, 라이브러리가 "친절하게" 함수를 실행해 버린다면 무엇이 깨지나요?
2. `fold`로 `Either`의 `getOrElse`를 작성하세요. 그런 다음 대체 값 대신 대체
   `Either`를 받는 `orElse`를 작성하세요.
3. 한 모듈에서 `Either<A, T>`가, 다른 모듈에서 `Either<B, T>`가 오고, 호출자는
   `Either<C, T>`를 원합니다. `mapLeft` 세 번을 스케치하고, 계층형 애플리케이션에서
   그것이 어디에 놓여야 하는지 말하세요.
4. `separateEither`는 `(errors, values)`를 돌려줍니다. 왜 그 순서이고, 그 선택이
   코드를 훑어볼 때 어떤 결과를 낳나요?

## 정답과 해설

1. 항등 법칙입니다. `left.map(id)`는 반드시 `left`와 같아야 합니다. `map`이
   실패 값에 `f`를 실행한다면 그 결과를 어딘가에 넣어야 하고 — `Left`의 타입이나
   내용이 바뀌겠죠 — 그러면 항등을 map 하는 것이 더 이상 무연산이 아닙니다.
   구체적으로 깨지는 것은 합성입니다. `map(f).map(g)`가 둘 중 어느 것도 위해
   쓰이지 않은 오류에 두 함수를 적용하게 되고, 대개 성공 값을 가정한 코드
   안에서 크래시합니다.
2. `T getOrElse<T>(Either<Object?, T> e, T fallback) =>
   e.fold((_) => fallback, (v) => v);` 그리고
   `Either<E, T> orElse<E, T>(Either<E, T> e, Either<E, T> other) =>
   e.fold((_) => other, (_) => e);`. 두 번째 것은 첫 성공을 지키는 `Either` 위의
   반군이고, 항등 실패가 있다면 모노이드가 되겠지만 대개는 없습니다.
3. `moduleA().mapLeft(toC)`와 `moduleB().mapLeft(toC)`를 두 모듈이 만나는
   이음매에 둡니다 — 보통 유스케이스나 서비스 계층이지, 두 모듈 내부도 아니고
   HTTP 경계도 아닙니다. 너무 일찍 번역하면 모듈이 호출자의 어휘에 묶이고,
   너무 늦으면 신 enum이 됩니다.
4. `(Left, Right)`와 맞습니다 — 타입 매개변수 순서, `switch` 갈래 순서와 같으므로
   코드베이스의 누구도 "어느 게 먼저였지?"를 묻지 않습니다. 여기서는 어느 쪽이 더
   중요한가에 대한 어떤 논쟁보다 일관성이 값어치가 큽니다. 순서를 한 번 확인해야
   하는 독자는 매번 확인하게 됩니다.
