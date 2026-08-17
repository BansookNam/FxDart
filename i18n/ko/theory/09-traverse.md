---
slug: traverse
chapter: 9
part: 2
title: 순회(traverse)
description: 결과의 리스트를 리스트의 결과로 바꾸기 — 두 구조를 맞바꾸는 연산, 왜 어플리커티브가 필요한가, 그리고 Dart가 한 번에 쓸 수 없어 FxDart가 네 가지 철자로 싣는 이유.
---
# 순회(traverse)

> **이 장에서 다루는 것**
> - 맞바꾸기: `List<Either<E, A>>` → `Either<E, List<A>>`, 그리고 왜 계속 필요해지는가
> - `traverse` = map + sequence, 그리고 어플리커티브가 기여하는 것
> - 빨리 실패하는 버전과 천천히 실패하는 버전, 각각의 정직한 대가
> - 비동기 쌍둥이, 그리고 `traverse`가 `concurrent(n)`을 만나는 지점

## 자꾸 손으로 짜게 되는 모양

행 열 개를 검증하면 `List<Either<E, Row>>`가 손에 남습니다. 하류의 어떤 코드도
그것을 원하지 않습니다. 호출자가 원하는 것은 모든 행이거나, 아니면 그것을 줄 수
없는 이유들입니다. 손으로 쓰면 매번 같은 열다섯 줄입니다 — 누산기 하나, 루프
하나, 이른 반환 하나.

이 연산에는 **sequence** 라는 이름이 있고, 먼저 map 하고 나서 sequence 하는
일반화가 **traverse** 입니다.

```
sequence : List<F<A>>              → F<List<A>>
traverse : List<A> × (A → F<B>)    → F<List<B>>
```

*두 구조를 맞바꾸는 것*으로 읽으세요. 리스트는 리스트로 남고 효과는 효과로
남습니다. 바뀌는 것은 어느 쪽이 바깥에 있느냐입니다.

![구조 맞바꾸기](diagrams/t9-1-traverse-swap.svg)

*그림 9-1. 맞바꾸기 전에는 원소마다 자기 몫의 작은 효과를 지고 있고, 맞바꾼 뒤에는 효과 하나가 리스트 전체를 진다. 값은 그대로이고 중첩만 달라진다.*

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parsePort(String s) {
  final n = int.tryParse(s);
  if (n == null) return Either.left('not a number: $s');
  if (n < 1024) return Either.left('privileged: $n');
  return Either.right(n);
}

void main() {
  // traverse: map each element to an Either, then swap.
  print(fx(['8080', '9000']).map(parsePort).sequence());
  print(fx(['8080', 'x', '80']).map(parsePort).sequence());
}
```

값 하나가 나오고, 그것이 프로그램의 나머지가 원하는 값입니다. 모든 포트를 담은
`Right`, 아니면 애초에 리스트가 없는 첫째 이유를 담은 `Left`.

## 왜 펑터가 아니라 어플리커티브가 필요한가

`map`만으로는 이것을 할 수 없습니다. 리스트 위에 map 하면 효과는 *안쪽*에
남고, `map`에는 그것을 밖으로 옮길 수단이 전혀 없습니다. `F<List<A>>`를 만들려면
원소들의 효과를 서로 결합해야 하고, 그것이 6장의 `map2`를 반복 적용하는
것입니다.

`sequence([a, b, c])` = `map2(a, map2(b, map2(c, of([]), cons), cons), cons)`

여기서 두 가지 동작이 곧바로 설명됩니다. 결합 연산이 어플리커티브의 것이므로,
**어떤 어플리커티브로 순회하느냐가 실패 정책을 결정합니다.**

- `Either`의 빨리 실패 어플리커티브로 순회 → 첫 `Left`에서 멈춤.
- 누적 어플리커티브로 순회 → 모든 `Left`를 수집.

같은 순회, 다른 대수, 다른 보고서. FxDart는 둘 다 내놓습니다.

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parsePort(String s) {
  final n = int.tryParse(s);
  if (n == null) return Either.left('not a number: $s');
  if (n < 1024) return Either.left('privileged: $n');
  return Either.right(n);
}

void main() {
  final raw = ['8080', 'x', '80', '9000'];

  // Fail fast: the first reason, and nothing after it ran.
  print(fx(raw).map(parsePort).sequence());

  // Fail slow: every reason, in order.
  print(fx(raw).map(parsePort).flattenOrAccumulate());

  // And the map-and-swap in one step, with the accumulating
  // applicative doing the combining.
  print(mapOrAccumulate(
      (r, String s) => r.bind(parsePort(s)), raw));
}
```

원할 법한 세 번째가 있습니다 — *멀쩡한 행은 남기고 잘못된 행은 보고하기* — 그리고
그것은 아예 순회가 아닙니다. 결과가 효과 하나가 아니라 리스트 둘이니까요. 그것은
자기 이름을 갖고 있습니다.

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parsePort(String s) {
  final n = int.tryParse(s);
  return n == null ? Either.left('bad: $s') : Either.right(n);
}

void main() {
  final results = ['8080', 'x', '9000'].map(parsePort).toList();
  final (bad, good) = separateEither(results);
  print('kept: $good');
  print('dropped: $bad');

  // …or take just one side.
  print(rights(results));
  print(lefts(results));
}
```

셋 중 무엇을 고를지는 기술이 아니라 제품의 결정입니다. 임포트 도구는
`separateEither`를, 설정 로더는 `flattenOrAccumulate`를, API 핸들러는
`sequenceEither`를 원합니다.

## 비동기 쌍둥이

`Either` 자리에 `Future`를 넣으면 같은 연산이 Dart 자신의 옷을 입고
나타납니다. `Future.wait`가 **곧** future에 대한 `sequence`입니다. 그러니
흥미로운 버전은 순회하면서 *동시에* 작업량을 제한하는 쪽입니다.

```dart run
import 'package:fxdart/fxdart.dart';

Future<int> fetchSize(String url) async {
  await Future.delayed(const Duration(milliseconds: 20));
  return url.length;
}

void main() async {
  final urls = ['a.com', 'bb.com', 'ccc.com', 'dddd.com'];

  // Sequence with unbounded concurrency: Future.wait.
  print(await Future.wait(urls.map(fetchSize)));

  // Traverse with *bounded* concurrency: three in flight,
  // results still in source order.
  final bounded =
      fx(urls).toAsync().mapConcurrent(3, fetchSize);
  print(await bounded.toList());
}
```

`Future.wait`는 제동 장치가 없는 어플리커티브 순회입니다. 전부 시작해 버리죠.
`mapConcurrent(n)`은 제한이 걸린 같은 순회이고, 요청 수 제한이 있는 API를 상대할
때 실제로 원하는 것입니다. 그 제한이 권고가 아니라 진짜가 되게 하는 백채널은
13장이 설명합니다.

> 🎓 **traverse는 리스트보다 일반적입니다.** 온전한 시그니처는 임의의 *순회
> 가능한* 컨테이너 `T`와 임의의 어플리커티브 `F`에 대해
> `traverse : T<A> × (A → F<B>) → F<T<B>>` 입니다 — 트리도, 맵도, `Option`도
> 순회 가능합니다. 법칙이 둘(펑터처럼 항등과 합성) 있고, 유명한 따름정리가
> 하나 있습니다. 항등 어플리커티브로 `traverse` 하면 그냥 `map`이고, 상수
> 어플리커티브로 하면 `fold`입니다. `map`, `fold`, `traverse`는 한 연산의 세
> 얼굴입니다 — 아름다운 결과이고, 한 번이라도 서술하려면 고차 타입이
> 필요합니다. 그것이 10장의 주제이며, FxDart가 일반적인 순회 하나 대신 구체적인
> 순회 넷을 싣는 이유입니다.

## 일반적으로 갖지 못한 대가

위 코드에 나온 버전을 세어 보세요. `sequenceEither`, `flattenOrAccumulate`,
`mapOrAccumulate`, `separateEither` — 여기에 비동기 체인을 위한
`sequenceEitherAsync`, `flattenOrAccumulateAsync`, `mapOrAccumulateAsync`까지.
고차 타입이 있는 언어가 하나로 쓰는 자리에 함수 일곱 개입니다.

이것은 무능이 아니라 언어의 천장이고, 여러분에게 실제 비용을 물립니다. FxDart에
새 효과 타입이 추가되면, 누군가 일곱 번째, 여덟 번째, 아홉 번째 변종을 손으로
쓰기 전까지 여러분의 기존 순회는 그 타입과 함께 동작하지 않습니다.

## 이것이 값을 하는 순간

독립적이고 실패할 수 있는 것들의 모음이 하나의 결정이 되어야 하는 모든 경계.
설정 파일 파싱, 임포트 검증, 레코드 N개 로딩, 서비스 N개로 팬아웃. `for (final x
in xs) { final r = f(x); if (r.isLeft) return r; out.add(...); }` 를 두 번 넘게
쓰셨다면 그것이 순회이고, 그렇게 말해야 합니다.

모음이 원소 하나뿐이면 건너뛰세요(그냥 `Either`를 쓰면 됩니다). 부분 성공 의미가
필요할 때도(그건 `separateEither`입니다), 루프가 순수한 map이 아닌 무언가를
원소마다 정말로 하고 있을 때도 마찬가지입니다 — 부수효과를 감춘 순회는 그것이
대체한 루프보다 나쁩니다.

## 연습문제

1. 빈 리스트에 대한 `sequence`는 무엇인가요 — `Either`에 대해, 그리고 `Future`에
   대해? 8장의 어떤 법칙이 답을 정하나요?
2. `traverse(xs, f)`와 `xs.map(f)` 후 `sequence`는 같은 결과를 줍니다. Dart에서
   어느 쪽이 더 싸고, FxDart는 왜 그래도 두 철자를 다 싣나요?
3. `Either<E, List<A>>`가 있고 `List<Either<E, A>>`를 원합니다 — 반대 방향의
   맞바꾸기. 언제나 가능한가요? `Left`에 대해 해 보세요.
4. `Future.wait`는 모든 future를 즉시 시작합니다. 그것이 정확히 옳은 상황 둘과,
   `mapConcurrent(n)`만이 옳은 상황 둘을 적어 보세요.

## 정답과 해설

1. `Right([])`와 `Future.value([])` — 어플리커티브의 `pure`로 감싼 빈
   리스트입니다. 8장 리스트 모노이드의 항등원이 `[]`이고, 아무것도 없는 것의
   `sequence`는 반드시 항등원을 내놓아야 합니다. 그렇지 않으면 이어 붙인 입력에
   대한 두 순회의 합성이 깨집니다.
2. 같은 양의 일이지만 `traverse`는 중간의 `List<F<B>>`를 만들지 않습니다. 규모가
   크면 의미가 있고 원소 열 개에서는 아닙니다. FxDart가 둘 다 싣는 이유는 두 단계
   형태(`.map(f).sequenceEither()`)가 기존 지연 체인에 합성되기 때문이고, 융합된
   형태는 소스가 이미 재료화되어 있을 때 원하는 것이기 때문입니다.
3. 가능하지만, 흥미로운 경우는 `Left(e)`입니다. `[Left(e)]`로 갈까요, `[]`로
   갈까요? 둘 다 변호할 수 있고, 그것이 이 방향은 순회가 *아니라는* 신호입니다 —
   답을 강제하는 법칙이 없으니까요. 일반적인 맞바꿈 `F<T<A>> → T<F<A>>`는
   *분배 법칙(distributive law)* 이라 불리며 특정한 구조 쌍에 대해서만
   존재합니다.
4. 옳은 경우: 빠른 로컬 계산 몇 개, 그리고 원격이 명시적으로 병렬 부하를 위해
   만들어진 팬아웃. 틀린 경우: 요청 수 제한이 있거나 과금되는 모든 API(제한 없는
   팬아웃은 스로틀링이나 청구서를 부릅니다), 그리고 길이를 사용자가 정하는 모든
   리스트 — 원소 10만 개짜리에 `Future.wait`를 걸면 소켓 10만 개가 열리고,
   무너지는 것은 상대가 아니라 여러분의 프로세스입니다.
