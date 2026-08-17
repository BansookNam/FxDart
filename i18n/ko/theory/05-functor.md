---
slug: functor
chapter: 5
part: 2
title: 펑터
description: 탑의 첫 층 — map과 두 법칙, 그리고 "구조는 보존하고 내용만 바꾼다"가 왜 단계 융합을 재작성이 아니라 리팩터링으로 만들어 주는가.
---
# 펑터

> **이 장에서 다루는 것**
> - 펑터: 연산 하나 `map`, 법칙 둘
> - 법칙이 금지하는 것 — 그것을 어기는 타입으로 보이기
> - 왜 합성 법칙이 파이프라인의 단계 융합을 허가하는가
> - 컨테이너가 아닌 펑터들, `Function` 안에 숨은 것까지

## 연산 하나

**펑터(functor)** 는 연산이 하나뿐인 타입 `F`입니다.

`map : F<A> × (A → B) → F<B>`

`A`를 담은 구조와 평범한 함수 `A → B`를 받아, `B`를 담은 같은 구조를 돌려줍니다.
그 문장에서 진짜 일을 하는 것은 "같은 구조"이고, 두 법칙이 그 뜻을 못 박습니다.

Dart는 펑터로 가득한데 저마다 다른 이름을 붙여 부릅니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  print([1, 2, 3].map((n) => n * 2).toList()); // List
  print(Either<String, int>.right(20).map((n) => n * 2));
  print(Either<String, int>.left('nope').map((n) => n * 2));
  print(fx([1, 2, 3]).map((n) => n * 2).toList()); // Fx
}
```

셋째 줄을 보세요. `Left`에 `map`을 걸면 아무 일도 일어나지 않고, 이는 덧붙인
특수 처리가 아니라 강제된 결과입니다. `map`은 구조를 바꿀 수 없고, `Either`에서는
어느 쪽인가가 *곧* 구조입니다. `Left`를 `Right`로 바꾸는 `map`은 그 이름을 달고
있는 다른 함수일 뿐입니다.

## 두 법칙

1. **항등.** `m.map((x) => x) == m`. 항등 함수를 map 하면 아무것도 달라지지
   않습니다 — 값도, 모양도, 관찰 가능한 그 무엇도.
2. **합성.** `m.map(f).map(g) == m.map((x) => g(f(x)))`. 함수 둘로 두 번 훑는
   것은 둘의 합성으로 한 번 훑는 것과 같습니다.

```dart run
import 'package:fxdart/fxdart.dart';

int addOne(int n) => n + 1;
int triple(int n) => n * 3;

void main() {
  final m = Either<String, int>.right(7);

  // identity
  print(m.map((x) => x) == m);

  // composition
  print(m.map(addOne).map(triple) ==
      m.map((x) => triple(addOne(x))));

  // both hold on the other side too
  final bad = Either<String, int>.left('boom');
  print(bad.map((x) => x) == bad);
}
```

![펑터의 두 법칙](diagrams/t5-1-functor-laws.svg)

*그림 5-1. 항등 법칙은 그 고리가 아무 일도 하지 않는다고 말한다. 합성 법칙은 정사각형을 가로지르는 두 경로가 같은 값에 닿는다고 말한다 — 그래서 파이프라인은 단계 사이 어디서든 다시 자를 수 있다.*

## 법칙이 금지하는 것

법칙은 함수를 적용하는 것 *외에* 무언가를 더 하는 `map`을 배제합니다. 그럴듯하지만
법칙을 어기는 타입을 봅시다.

```dart run
// A box that remembers how many times it was mapped.
class Counted<A> {
  const Counted(this.value, this.maps);
  final A value;
  final int maps;

  Counted<B> map<B>(B Function(A) f) =>
      Counted(f(value), maps + 1);

  @override
  bool operator ==(Object other) =>
      other is Counted &&
      other.value == value &&
      other.maps == maps;

  @override
  int get hashCode => Object.hash(value, maps);

  @override
  String toString() => 'Counted($value, maps: $maps)';
}

void main() {
  final m = Counted(7, 0);

  // Identity fails: mapping "nothing" is observable.
  print(m.map((x) => x) == m);

  // Composition fails: two passes cost two, one pass costs one.
  print(m.map((x) => x + 1).map((x) => x * 3));
  print(m.map((x) => (x + 1) * 3));
}
```

이 타입이 *틀린* 것은 아닙니다 — map 횟수를 세는 것이 정확히 원하던 바일 수도
있죠. 다만 이것은 펑터가 아니며, 그 실무적 귀결은 명확합니다. 이제 독자는 이
타입의 `map` 호출을 합치거나 나눌 수 없습니다. 그렇게 하면 결과가 바뀌니까요.
법칙은 허가증이고, 이 타입은 그 허가증을 주지 않습니다.

## 합성 법칙은 성능 기능이다

합성 법칙을 오른쪽에서 왼쪽으로 읽으면 그것은 더 이상 철학이 아닙니다.

`m.map(f).map(g)` — 두 번 순회 — 가 `m.map(g ∘ f)`, 즉 한 번 순회와 *같습니다*.
그러므로 라이브러리는 언제든 앞의 것을 뒤의 것으로 다시 쓸 수 있고, 여러분은
알아채지도 못합니다.

FxDart에서 이것은 가정이 아닙니다. 지연 파이프라인은 단계를 융합해 값 하나가
단계마다 재료화되지 않고 사슬 전체를 한 번에 흘러가게 하는데, 그 재작성의
허가증이 바로 펑터 법칙입니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final seen = <String>[];

  final result = fx([1, 2, 3])
      .map((n) => n + 1)
      .peek((n) => seen.add('after +1: $n'))
      .map((n) => n * 3)
      .peek((n) => seen.add('after *3: $n'))
      .toList();

  print(result);
  // Interleaved, not staged: element by element through the
  // whole chain — the one-pass reading of the composition law.
  seen.forEach(print);
}
```

`map` 둘, 중간 리스트 없음. 즉시 평가 언어라면 단계마다 리스트 하나씩 값을
치렀을 텐데, 여기서는 법칙이 그럴 필요 없다고 말하고 구현이 그 말을 받아들입니다.
11장이 이 평가 이야기를 명시적으로 다룹니다.

## 컨테이너가 아닌 펑터들

"펑터는 값을 담는다"는 쓸모 있는 거짓말입니다. 펑터가 실제로 가진 것은 함수가
작용할 *자리*이고, 그중에는 아무것도 들어 있지 않은 자리도 있습니다.

- `Future<A>` — 값이 아직 여기 없습니다. `then`이 그 `map`입니다.
- 파서나 디코더 — `map`은 *앞으로 일어날* 파싱이 무엇을 내놓을지를 바꿉니다.
- `Function(X) → A` — 리더(reader) 펑터. 함수 위의 map은 그 결과에 합성하는
  것입니다.

```dart run
void main() {
  int Function(String) length = (s) => s.length;

  // map for functions IS composition: apply, then transform.
  int Function(String) doubledLength = (s) => length(s) * 2;

  print([length('functor'), doubledLength('functor')]);
}
```

마지막 것은 곱씹어 볼 만합니다. 합성과 `map`은 같은 연산을 두 각도에서 본
것이고, 그래서 4장의 결합 법칙과 이 장의 합성 법칙이 같은 문장을 두 번 말하는
것처럼 느껴집니다. 실제로 같습니다.

## 이것이 값을 하는 순간

이 단어는 *예측 도구*로서 값을 합니다. `map`이 달린 낯선 타입을 만나면 이미 세
가지를 압니다. 모양을 바꾸지 않는다는 것, 항등을 map 하면 아무 일도 없다는 것,
호출을 나누거나 합쳐도 된다는 것. 단어 하나치고는 많은 지식입니다.

타입이 거짓말하고 있을 때도 알려 줍니다. 재시도, 순서 변경, 캐시를 문서에
언급하는 `map`은 펑터의 `map`이 아니며, 그 주위를 리팩터링하기 전에 소스를 읽어야
합니다.

## 연습문제

1. `Either.map`이 항등 법칙을 만족함을 경우를 나눠 (비형식적으로) 증명하세요.
   경우는 몇 개이고, 왜 그 개수가 증명의 전부인가요?
2. `Set`에도 `map`이 있습니다. `f`가 서로 다른 두 원소를 같은 값으로 보낼 때도
   합성 법칙을 만족하나요? `{1, 2}`에 `f = (x) => 0`, `g = (x) => x + 1`로
   해 보세요.
3. 어떤 타입에 두 법칙을 지키는 `map`이 있다면 그 `map`은 유일한가요? 즉 같은
   타입에 서로 다른 적법한 `map`이 둘 있을 수 있나요 — `List`와 `Either`에서
   답이 다른가요?
4. FxDart의 `peek`은 같은 원소 타입을 돌려줍니다. `peek`은 `map`인가요? 어떤
   법칙을 어기며, 왜 아무도 문제 삼지 않는지는 어느 장의 어휘로 설명되나요?

## 정답과 해설

1. 두 경우입니다. `Left(e).map(id)`는 정의상 `Left(e)`를 돌려주고,
   `Right(a).map(id)`는 `Right(id(a))` = `Right(a)`입니다. `Either`는 생성자가
   정확히 둘인 합이므로, 둘을 덮는 것이 *곧* 모든 값을 덮는 것입니다 — 3장이
   `sealed`에서 얻었던 그 빠짐없음입니다.
2. 만족합니다. `{1, 2}.map(f)`는 `{0}`이고 여기에 `g`를 map 하면 `{1}`입니다.
   합친 `g ∘ f`도 `{1}`을 줍니다. 어느 경로로 가든 중복 제거는 나가는 길에
   일어납니다. `Set`이 깨는 것은 합성이 아니라 "펑터는 크기를 보존한다"는
   직관인데, 법칙은 그런 약속을 한 적이 없습니다.
3. 흥미로운 답은, 내용물의 자리로 모양이 결정되는 타입에 대해서는 법칙이 `map`을
   못 박는다는 것이고, 이는 `List`와 `Either` 모두에 해당합니다. 실무적으로 이
   타입들의 적법한 `map`은 유일하며, 그 유일성이 이름을 믿을 수 있는 이유입니다.
4. `peek`은 `map`이 아닙니다 — 효과가 딸린 `map`이므로, 콜백이 관찰 가능한 일을
   하는 순간 항등 법칙을 어깁니다(`peek((_) {})`는 무연산이지만 `peek(print)`는
   아닙니다). 설명은 2장의 어휘입니다. `peek`은 효과를 *선언된* 것으로 만들려고
   존재하며, 선언된 효과는 위반이 아니라 문서화된 예외입니다.
