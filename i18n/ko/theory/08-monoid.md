---
slug: monoid
chapter: 8
part: 2
title: 모노이드와 반군
description: 결합적인 결합 연산에 항등원 하나 — 쓸모 있는 것 중 가장 작은 대수이자, fold에 씨앗이 필요한지, 축약을 병렬로 할 수 있는지, 오류가 왜 NonEmptyList로 쌓이는지를 결정하는 것.
---
# 모노이드와 반군

> **이 장에서 다루는 것**
> - 두 법칙 — 결합과 항등 — 그리고 각각이 따로 사 주는 것
> - 왜 `reduce`는 빈 컬렉션에서 던지고 `fold`는 그러지 않는가
> - 병렬 축약과 덩어리 축약이 같은 답을 주게 하는 성질
> - 반군으로서의 `NonEmptyList`, 그리고 FxDart의 오류가 그리로 쌓이는 이유

## 쓸모 있는 것 중 가장 작은 대수

**반군(semigroup)** 은 결합적인 이항 연산을 가진 타입입니다.

`combine(a, combine(b, c)) == combine(combine(a, b), c)`

**모노이드(monoid)** 는 항등원을 가진 반군입니다.

`combine(empty, a) == a == combine(a, empty)`

그게 전부입니다. `+`와 `0`을 가진 `int`, `*`와 `1`을 가진 `int`, `+`와 `''`를
가진 `String`, `+`와 `[]`를 가진 `List`, `&&`와 `true`를 가진 `bool`. 오늘도
그 전부를 쓰셨을 겁니다.

```dart run
void main() {
  // associativity: grouping does not matter
  print((1 + 2) + 3 == 1 + (2 + 3));
  print(('a' + 'b') + 'c' == 'a' + ('b' + 'c'));

  // identity: the neutral element changes nothing
  print(0 + 7 == 7 && 7 + 0 == 7);
  print(''.length + 'abc'.length == 3);

  // subtraction is neither associative nor unital
  print((10 - 3) - 2 == 10 - (3 - 2));
}
```

마지막 줄이 이 정의의 요점입니다. "둘을 결합한다"만으로는 부족합니다. 뺄셈도
`int` 둘을 결합하지만 아래의 어떤 일에도 쓸모가 없습니다.

## 각 법칙이 사 주는 것

**항등은 빈 경우를 줍니다.** Dart에 폴드 메서드가 둘 있고 빈 컬렉션에서 다르게
동작하는 이유가 이것입니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  // fold carries the identity element as a seed — total, always.
  print(fx(<int>[]).fold<int>(0, (a, b) => a + b));
  print(fx([1, 2, 3]).fold<int>(0, (a, b) => a + b));

  // reduce has no seed, so the empty case has no answer to give.
  try {
    print(fx(<int>[]).reduce((a, b) => a + b));
  } catch (e) {
    print('reduce on empty: ${e.runtimeType}');
  }
}
```

`reduce`는 반군만 요구하므로 부분 함수입니다. `fold`는 모노이드를 요구하고 —
`empty`를 씨앗으로 넘겨 주죠 — 전 함수입니다. 여러분이 백 번쯤 만난 그 예외는
항등원이 없다는 사실이 런타임에 나타난 것입니다.

**결합은 묶는 자유를 줍니다.** 이것은 들리는 것보다 값어치가 큽니다. 같은 연산을
다음과 같이 실행할 수 있다는 뜻이니까요.

- 왼쪽에서 오른쪽으로 한 원소씩(평범한 fold);
- 덩어리로 나눠 처리한 뒤 덩어리 결과를 결합;
- 여러 아이솔레이트에서 병렬로, 결과가 오는 대로 결합;
- 점진적으로, 누적 합을 들고 있다가 나중에 더하기.

네 가지가 모두 같은 답을 주고, 그것을 보장하는 것은 *오직* 결합 법칙입니다.

![법칙 하나, 평가 순서 넷](diagrams/t8-1-monoid-orders.svg)

*그림 8-1. 결합 법칙은 같은 수열을 어떻게 묶어도 같은 값에 닿는다고 말한다. 그것이 덩어리 나누기, 병렬 축약, 누적 합 이어 가기의 허가증이다.*

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final data = List.generate(12, (i) => i + 1);

  // Sequential.
  final straight = fx(data).fold(0, (a, b) => a + b);

  // Chunked, then the chunk results combined — legal because +
  // is associative and 0 is its identity.
  final chunked = fx(data)
      .chunk(5)
      .map((c) => fx(c).fold(0, (a, b) => a + b))
      .fold(0, (a, b) => a + b);

  print([straight, chunked, straight == chunked]);

  // Order does NOT come free: subtraction disagrees with itself.
  final subStraight = fx(data).fold(0, (a, b) => a - b);
  final subChunked = fx(data)
      .chunk(5)
      .map((c) => fx(c).fold(0, (a, b) => a - b))
      .fold(0, (a, b) => a - b);
  print([subStraight, subChunked, subStraight == subChunked]);
}
```

## 교환은 *다른* 법칙이다

결합은 묶는 방식이 상관없다고 말합니다. **교환(commutativity)** —
`a + b == b + a` — 은 *순서*가 상관없다고 말하는데, 쓸모 있는 모노이드 대부분은
그 성질이 없습니다. 문자열 이어 붙이기, 리스트 덧붙이기, 함수 합성 모두
결합적이지만 어느 것도 교환적이지 않습니다.

이 구분은 FxDart의 비동기 장에서 실제로 이빨을 드러냅니다. `concurrent(n)`은
원소를 순서 없이 평가하지만 **소스 순서대로** 내보내는데, 바로 그래야 하류의
fold가 교환이 아니라 결합만 요구하기 때문입니다. 완료 순서대로 결과를 내주는
라이브러리라면 여러분의 코드에 더 강한 법칙을 말없이 요구하는 셈입니다.

## `NonEmptyList`, 그리고 오류가 반군인 이유

6장에서 검증 오류를 모았습니다. 그것들이 *무엇으로* 쌓이는지 물으면 대수가 먼저
답합니다. 결합적으로 합칠 수 있는 것이 필요하고(실패한 두 가지가 이어 붙습니다),
실패를 합친 결과는 결코 비어 있지 않습니다 — 그러니 항등원은 불필요할 뿐 아니라
거짓말이 됩니다.

그것이 모노이드가 아닌 반군이고, FxDart는 그것을 `NonEmptyList`라 부릅니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final a = NonEmptyList.of('name is empty');
  final b = NonEmptyList.of(
      'age is negative', ['age is not a number']);

  // Combining failures is list concatenation: associative,
  // and the result cannot be empty.
  final all = NonEmptyList.of(a.first, [...a.skip(1), ...b]);
  print(all.toList());
  print('length: ${all.length}');

  // Nel is an extension type over List, so it costs nothing at
  // runtime — and `orNull` is the only way in from a plain list.
  print(NonEmptyList.orNull(<String>[]));
}
```

그러므로 `Either<Nel<E>, A>`는 정확한 주장으로 읽힙니다. *이것이 실패했다면
이유가 적어도 하나 있고, 이유들은 합쳐진다.* `List<E>`였다면 "오류 0개로
실패함"이라는 말이 안 되는 상태를 허용했을 것입니다 — 3장의 논지를 오류 통로에
적용한 것이죠.

> 🎓 **모노이드는 합성되고, 그래서 어디에나 있습니다.** `A`와 `B`가 모노이드면
> `(A, B)`도 모노이드입니다. 성분별로 결합하고 `(emptyA, emptyB)`가 항등원이죠 —
> 그래서 "합계, 개수, 최댓값을 한 번에"는 곱 모노이드에 대한 fold 하나이고,
> 평균은 그 fold에 나눗셈 하나입니다. 모노이드로 가는 함수들도 모노이드를
> 이루고(`(f + g)(x) = f(x) + g(x)`), 자기함수들은 합성 아래 `identity`를 단위원
> 삼아 모노이드를 이룹니다 — "모나드는 자기함자 범주 위의 모노이드다"라는 문장
> 안에 숨은 말이 이것입니다. `flatten`이 결합이고 `of`가 항등원이며, 1장의 세
> 모나드 법칙이 이 두 법칙을 변장시킨 것입니다.

## 이것이 값을 하는 순간

`fold`를 쓸 때마다 여러분은 모노이드를 고르고 있고, 그것을 소리 내어 이름 붙이면
코드가 맞는지 알 수 있습니다. 항등원이 있는가(빈 경우엔 무엇을 돌려줘야 하지?),
결합적인가(작업을 쪼개도 되나?)

규모가 클수록 값을 합니다 — 덩어리 처리, 병렬 집계, 데이터베이스의 점진적 합계.
API 설계에서도 그렇습니다. "씨앗과 결합 연산을 달라"는 인터페이스는 라이브러리가
여러분에게 묻지 않고도 작업을 배치로 묶을 수 있게 해 줍니다.

원소 열 개짜리 `reduce` 하나가 전부인 코드베이스에서는 어휘로서의 값은 없습니다.
거기서는 그냥 "합계"라고 말하세요.

## 연습문제

1. `max`는 `int` 위에서 반군인가요? 모노이드인가요? 항등원은 무엇이어야 하고,
   Dart에 그것이 있나요?
2. `empty`가 "뻔한 빈 값"이 아닌 모노이드를 하나 드세요 — 독자가 틀리게 짐작할
   만한 것으로.
3. `fx(xs).fold(0, (a, b) => a + b.length)`는 문자열 길이를 더합니다. `fold`에
   넘긴 함수는 결합적인가요? 왜 그것이 문제가 되지 않나요?
4. `Either` 누적과 `Future.wait` 모두 독립적인 결과를 결합합니다.
   `Future.wait`가 쓰는 모노이드는 무엇이고, 실패는 어떻게 처리하나요?

## 정답과 해설

1. 둘 다 예입니다. `max`는 결합적이고 교환적이며, 그 항등원은 음의 무한대인데
   Dart의 `int`에는 그런 값이 없습니다 — 그래서 `max`는 `int` 위에서는 *반군*이고,
   `double`(`double.negativeInfinity`)이나 `null`을 항등원으로 삼는 `int?` 위에서만
   모노이드입니다. `max`에는 `reduce`가 자연스럽고 `fold`에는 어색한 씨앗이
   필요한 정직한 이유가 그것입니다.
2. 여럿 있습니다. `&&` 아래의 `bool`은 항등원이 `false`가 아니라 `true`이고,
   `*` 아래의 `int`는 `0`이 아니라 `1`이며, "첫 non-null" 모노이드의 항등원은
   `null`입니다. 교훈은 `empty`가 타입이 아니라 언제나 연산에 의해 결정된다는
   것입니다 — 타입만 보고 짐작하는 것이 fold가 모든 것에 0을 곱하게 되는 길입니다.
3. 결합적이지 않습니다 — 애초에 모양부터 맞지 않는데, 씨앗 타입 `int`가 원소
   타입 `String`과 다르기 때문입니다. Dart의 `fold`는 더 일반적인 *카타모피즘*
   `(B, A) → B`이고, `B == A`일 때에만 모노이드 질문이 생깁니다. 순차 fold는 결코
   재그룹핑하지 않으므로 문제가 되지 않습니다. 덩어리로 나누고 싶어지는 순간
   문제가 되고, 그때는 연산을 진짜 모노이드로 분해해야 합니다(`String → int`,
   그다음 합계).
4. `Future.wait`는 결과에 대한 리스트 모노이드를 씁니다 — 인자 순서대로 이어
   붙이고, `[]`가 항등원입니다(아무것도 기다리지 않으면 빈 리스트). 실패는
   누적되지 *않습니다*. 기본값에서는 첫 오류가 이기고 나머지는 버려지는데, 6장이
   `zipOrAccumulate`와 대비했던 그 빨리 실패 동작입니다. `eagerError: false`는
   언제 보고할지를 바꿀 뿐 몇 개를 보고할지는 바꾸지 않습니다.
