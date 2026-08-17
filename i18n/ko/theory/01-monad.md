---
slug: monad
chapter: 1
part: 1
title: 모나드란 정확히 무엇인가
description: 모나드는 연산 두 개와 법칙 세 개를 갖춘 타입입니다. Dart에도 여럿 있습니다. 이 장은 그 모양에 이름을 붙이고, 법칙이 무엇을 사 주는지 보이고, 왜 Dart도 FxDart도 그 인터페이스를 적어 둘 수 없는지 설명합니다.
---
# 모나드란 정확히 무엇인가

> **이 장에서 다루는 것**
> - 이미 쓰고 있는 Dart의 모나드 셋과, 그 셋을 하나의 모양으로 만드는 것
> - 두 연산 — `of`와 `flatMap` — 그리고 왜 "납작하게 만들기"가 핵심인가
> - 세 법칙을 실행 가능한 코드로, 그리고 법칙을 어기면 무엇이 깨지는가
> - Dart가 `Monad` 인터페이스를 선언할 수 없는 이유와, FxDart의 대안

## 정의가 아니라 코드에서 시작하기

그 유명한 정의 — *모나드는 자기함자 범주 위의 모노이드다* — 는 참이고,
동시에 최악의 첫 문장입니다. 인스턴스를 하나도 만나 보지 못한 사람에게
일반형부터 설명하는 셈이니까요. 그래서 인스턴스 셋을 먼저 봅니다. 셋 다
이미 써 보셨을 겁니다.

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parsePort(String text) => either((r) {
  final n = r.ensureNotNull(
      int.tryParse(text), () => 'not a number: $text');
  r.ensure(n > 1023, () => 'privileged port: $n');
  return n;
});

Future<int> fetchTimeout(int port) async => port + 100;

void main() async {
  // List<A>: many values in one structure.
  print([1, 2, 3].expand((x) => [x, x * 10]).toList());

  // Either<String, int>: a value, or a failure instead of it.
  print(parsePort('8080'));
  print(parsePort('80'));

  // Future<A>: a value that is not here yet.
  print(await Future.value(8080).then(fetchTimeout));
}
```

서로 아무 관계 없는 세 타입입니다. `List`는 값을 여러 개 담고, `Either`는
값 하나 또는 실패 하나를 담고, `Future`는 아직 도착하지 않은 값을 담습니다.
셋이 공유하는 것은 *무엇을 담느냐*가 아니라 *그것으로 무엇을 할 수 있느냐*
입니다.

![포트가 둘씩 달린 세 구조](diagrams/t1-1-three-boxes.svg)

*그림 1-1. 내용물은 다르지만 배선은 같다. 어느 것이든 평범한 값을 하나 받아들일 수 있고, 어느 것이든 "같은 종류의 상자를 돌려주는 함수"를 이어 붙일 수 있다.*

세 타입 모두 다음 두 연산을 제공합니다.

| | 값을 넣기 | 상자를 돌려주는 단계를 잇기 |
|---|---|---|
| `List<A>` | `[a]` | `expand` |
| `Future<A>` | `Future.value(a)` | `then` |
| `Either<E, A>` | `Either.right(a)` | `flatMap` |
| `Fx<A>` (FxDart) | `fx([a])` | `flatMap` |

이 두 연산을 갖추고, 곧 볼 세 법칙을 지키는 타입이 **모나드**입니다. 정의는
이게 전부입니다. 이 단어가 위압적인 이유는 개념이 커서가 아니라, 범주론에서
어휘를 통째로 달고 건너왔기 때문입니다.

## 두 연산, 정확하게

구조 `M` 안에 든 `A` 값을 `M<A>`라고 씁시다. 모나드는 타입 생성자 `M`과
다음 두 연산입니다.

- **of** (`pure`, `return`, `unit`이라고도 합니다): `A → M<A>`. 평범한 값
  하나를 받아, 그 값을 담은 가장 심심한 상자를 돌려줍니다. "심심함"은
  기술적 요구 조건입니다 — `Either.right(3)`은 실패를 더하지 않고,
  `Future.value(3)`은 기다림을 더하지 않고, `[3]`은 원소를 더하지 않습니다.
- **flatMap** (`bind` 또는 `>>=`): `M<A> × (A → M<B>) → M<B>`. 상자 하나와,
  그 안의 값을 *또 다른 상자*로 바꾸는 함수를 받아, 상자 **하나**를
  돌려줍니다 — 상자 속 상자가 아니라.

마지막 문장의 뒷부분이 전부이고, 그 이유는 그 부분을 빼 보면 바로 보입니다.
`map`만으로는 부족합니다.

```dart run
void main() {
  // The step returns a List, so map gives a List of Lists.
  final nested = [1, 2, 3].map((x) => [x, x * 10]).toList();
  print(nested);
  print(nested.runtimeType);

  // flatMap (Dart spells it `expand`) joins the inner lists
  // into the outer one.
  final flat = [1, 2, 3].expand((x) => [x, x * 10]).toList();
  print(flat);
  print(flat.runtimeType);
}
```

![map은 겹치고 flatMap은 납작하게 만든다](diagrams/t1-2-map-vs-flatmap.svg)

*그림 1-2. 두 연산은 같은 함수를 적용한다. `map`은 함수가 돌려준 상자를 원래 상자 안에 그대로 넣고, `flatMap`은 두 겹을 하나로 잇는다.*

왜 이게 그렇게 중요할까요? *실패할 수 있거나, 기다리거나, 답을 여러 개 내는
단계는 정확히* `A → M<B>` *타입의 함수*이기 때문입니다. 실제 프로그램은 그런
단계의 나열입니다. `map`만 있으면 단계마다 겹이 하나씩 늘어납니다 — 세 단계면
`Either<E, Either<E, Either<E, A>>>`가 되고, 이 값으로는 세 번 벗겨 내기 전에
아무것도 할 수 없습니다. `flatMap`은 몇 단계를 잇든 깊이를 영원히 1로
유지합니다. 모나드는 **문맥을 돌려주는 함수들을 합성하는 방법**입니다.

> **용어.** `map`만 있고 (자기 몫의 법칙 두 개를 지키는) 타입은
> **펑터(functor)** 입니다 — 5장. 모든 모나드는 펑터입니다.
> `map(f)`를 `flatMap((a) => of(f(a)))`로 정의할 수 있으니까요. 역은
> 성립하지 않고, 그래서 이 탑에는 층이 하나 이상 있습니다.

## 이미 flatMap을 쓰고 있었다

Dart는 `flatMap`을 매일 쓰는 문법 뒤에 숨겨 둡니다. `await`가 곧 `Future`의
`flatMap`입니다 — future에서 값을 꺼내 나머지 함수를 그 값으로 실행하고,
결과는 future 하나입니다. 절대 `Future<Future<T>>`가 되지 않죠. 리스트에
덧붙이는 `for`-in 루프는 `List`의 `flatMap`이고, 14장의 `either { }` 블록은
`Either`의 `flatMap`입니다.

같은 계산을 두 가지로 써 봅시다. 먼저 명시적인 체인, 그다음 FxDart의
`either` 스코프.

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parseAge(String text) => either((r) {
  final n = r.ensureNotNull(
      int.tryParse(text), () => 'not a number: $text');
  r.ensure(n >= 0, () => 'negative age: $n');
  return n;
});

Either<String, String> lookup(String id) => id == 'u1'
    ? Either.right('Ada')
    : Either.left('no such user: $id');

// Explicit chaining: every dependent step nests
// one level deeper.
Either<String, String> greetChained(String id, String ageText) =>
    lookup(id).flatMap((name) =>
        parseAge(ageText).flatMap((age) =>
            Either.right('$name is $age')));

// The same steps in a Raise scope: straight-line code,
// with the same short-circuiting.
Either<String, String> greetScoped(String id, String ageText) =>
    either((r) {
  final name = r.bind(lookup(id));
  final age = r.bind(parseAge(ageText));
  return '$name is $age';
});

void main() {
  print(greetChained('u1', '36'));
  print(greetScoped('u1', '36'));
  print(greetScoped('u9', '36'));
  print(greetScoped('u1', 'old'));
}
```

두 버전은 첫 실패에서 멈추는 것까지 똑같이 동작합니다. 첫 단계가 실패하면
둘째 단계는 실행되지 않습니다. 차이는 체인 버전이 단계마다 오른쪽으로 한
칸씩 밀려난다는 것 — 모나드를 가진 언어라면 결국 이 모양을 감추는 문법을
발명하게 됩니다. 하스켈은 `do` 표기법, 스칼라는 `for` 컴프리헨션, Dart는 그
특수한 경우인 `async`/`await`를 만들었습니다. FxDart의 `either` 블록은 같은
생각에 다른 방식으로 도달한 것이고, [그 이야기는 15장](#ch15)입니다.

## 세 법칙

연산 두 개만으로는 부족합니다. `of`와 `flatMap`을 정의하고도 놀라운 방식으로
동작하는 타입을 만들 수 있으니까요. 그래서 모나드는 세 법칙을 지켜야 합니다.
읽어 보면 당연한 말을 굳이 적어 둔 것 같은데, 바로 그 점이 가치입니다 —
여러분이 코드를 정리할 때 이미 가정하고 있는 보장이거든요.

1. **왼쪽 항등.** `of(a).flatMap(f)` = `f(a)`. 값을 상자에 넣고 곧바로
   단계를 이으면, 그냥 그 단계를 부른 것과 같습니다.
2. **오른쪽 항등.** `m.flatMap(of)` = `m`. 상자를 열어 값을 꺼내고 그대로
   다시 담으면 아무것도 달라지지 않습니다.
3. **결합.** `m.flatMap(f).flatMap(g)` = `m.flatMap((a) => f(a).flatMap(g))`.
   단계들을 어떻게 묶든 결과는 같습니다.

![두 경로가 같은 곳에 도착한다](diagrams/t1-3-monad-laws.svg)

*그림 1-3. 세 법칙 모두 같은 종류의 말을 한다 — 그림을 가로지르는 서로 다른 두 경로가 같은 값에 도착해야 한다는 것. 법칙은 어느 경로로 가도 된다는 허가증이다.*

FxDart의 `Either`로 직접 확인해 봅시다.

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> half(int n) =>
    n.isEven ? Either.right(n ~/ 2) : Either.left('odd: $n');

Either<String, int> minusOne(int n) => Either.right(n - 1);

void main() {
  final m = Either<String, int>.right(20);

  print(
      Either<String, int>.right(20).flatMap(half) == half(20));
  print(m.flatMap((a) => Either<String, int>.right(a)) == m);
  print(m.flatMap(half).flatMap(minusOne) ==
      m.flatMap((a) => half(a).flatMap(minusOne)));

  // The laws hold on the failure side too — that is what makes
  // short-circuiting composable rather than a special case.
  final bad = Either<String, int>.left('boom');
  print(bad.flatMap(half).flatMap(minusOne) ==
      bad.flatMap((a) => half(a).flatMap(minusOne)));
}
```

### 법칙을 어기면 치르는 값

법칙은 장식이 아닙니다. 하나라도 어기면 평범한 리팩터링이 동작을 조용히
바꿉니다. 아래는 단계 수를 세는 상자입니다 — 있을 법한 설계이고, 법칙을
어깁니다.

```dart run
class Logged<A> {
  const Logged(this.value, this.steps);
  final A value;
  final int steps;

  static Logged<A> of<A>(A value) => Logged(value, 0);

  // The `+ 1` is the bug: chaining charges for
  // the chaining itself.
  Logged<B> flatMap<B>(Logged<B> Function(A) f) {
    final next = f(value);
    return Logged(next.value, steps + next.steps + 1);
  }

  @override
  String toString() => 'Logged($value, steps: $steps)';
}

Logged<int> double_(int n) => Logged(n * 2, 1);

void main() {
  // Left identity: of(a).flatMap(f) should equal f(a).
  // It does not.
  print(Logged.of(21).flatMap(double_));
  print(double_(21));

  // Right identity: chaining a step that does nothing
  // should be invisible.
  final m = double_(21);
  print(m);
  print(m.flatMap(Logged.of));
}
```

여기서 결합 법칙은 우연히 살아남습니다 — 체인을 다시 묶어도 개수는 그대로죠.
하지만 항등 법칙 두 개가 깨졌고, 그것만으로 치명적입니다. 사소한 단계를
별도 `flatMap`으로 빼내거나, 거꾸로 인라인해 없애는 일은 어느 리뷰어라도
통과시킬 리팩터링인데, 이 타입에서는 그것이 답을 바꿉니다.

고치는 방법은 특수 처리를 더하는 것이 아니라, `steps`를 **모노이드** —
결합적인 결합 연산과 항등원을 가진 타입(8장) — 로 만들고 `of`가 그 항등원을
내놓게 하는 것입니다. `+ 1`을 지우면 `Logged`는 Writer 모나드가 되어 법칙을
지키고 쓸모도 생깁니다. 대부분의 법칙 위반이 이 패턴입니다 — 무해해 보이지만
항등원이 없는 연산.

> 🎓 **기록을 위한 형식적 정의.** 범주론에서 범주 **C** 위의 모나드는
> 자기함자 `T : C → C`와 두 자연변환 `η : Id ⇒ T`(이것이 `of`),
> `μ : T² ⇒ T`(이것이 `flatten`이고 `flatMap(f) = μ ∘ T(f)`)의 조합이며,
> 단위·결합 정합성 조건 — 위의 세 법칙을 가환 그림으로 그린 것 — 을
> 만족합니다. "자기함자 범주 위의 모노이드"라는 말도 같은 이야기의 반복입니다:
> `μ`가 곱셈, `η`가 단위원이죠. 이 문단은 Dart를 쓰는 데 아무 도움이 되지
> 않고, 그래서 상자 안에 있고, 그래서 제자리는 20장입니다.

## FxDart는 실제로 무엇을 구현하는가

이제 정직한 부분입니다. 방금 설명한 그 인터페이스를 Dart는 표현하지
못합니다. 적어 두려면 타입 매개변수 자체가 제네릭이어야 하는데 — 고차 타입
(higher-kinded type) — Dart에는 없습니다.

```dart
// Does not compile. `M` is a type, and a type cannot take
// arguments here.
abstract class Monad<M> {
  M<A> of<A>(A value);
  M<B> flatMap<A, B>(M<A> box, M<B> Function(A) f);
}
```

FxDart의 타입 있는 오류가 이식해 온 코틀린 Arrow는 컴파일러 플러그인과
컨텍스트 리시버로 이 벽을 우회합니다. 스칼라는 종(kind) 시스템을 언어에
갖고 있습니다. Dart는 둘 다 없고, 어떤 기교로도 되찾을 수 없습니다 — 시도는
결국 `dynamic` 캐스트로 끝나고, 그러면 애초에 추상화가 지키려던 타입
안전성을 그대로 내놓게 됩니다.

그래서 FxDart는 유일하게 정직한 선택을 합니다. *모양*을 타입마다 구현하되,
그것을 추상화한 척은 하지 않는 것.

- **`Either<L, R>`** 에는 `flatMap`이 있고 `Either.right`가 그 `of`입니다.
  법칙은 성립합니다 — 두 쪽 앞에서 직접 확인했죠.
- **`either((r) { … })`** 은 `do` 표기법의 실용적 대체물입니다. 문법
  설탕(desugaring)이 아닙니다 — `r.bind`는 스코프로 raise 하여 단락
  평가합니다(15장). 모나드 재작성이 아니라 제한된 연속(delimited
  continuation) 기법이죠. 같은 직선형 코드, 다른 메커니즘이고, 왜 `Raise`
  모나드 인스턴스가 없느냐는 질문에서 이 구분이 중요해집니다.
- **`Fx<A>`** 는 지연 `Iterable` 체인이고, `Iterable`이 곧 리스트
  모나드입니다 — `flatMap`이 bind, `fx([a])`가 `of`. 지연 평가는 법칙을
  흔들지 않습니다. 왜 평가 순서가 법칙에 보이지 않는지는 11장에서 봅니다.
- **`FxAsyncIterable<A>`** 는 비동기 소스 위의 같은 모양이고, 여기에
  `concurrent(n)`이 원소를 *언제* 계산할지만 바꾸고 *무엇을* 계산할지는
  바꾸지 않는다는 성질이 더해집니다 — 법칙이 뒷받침하는 등식 추론입니다.

`Monad` 인터페이스가 없어서 잃는 것은 모든 모나드에 한꺼번에 통하는 제네릭
코드입니다 — `traverse` 하나, `sequence` 하나, `Either`·`Fx`·`Future`에
공통으로 재사용되는 조합자 한 벌. FxDart는 대신 구체 버전을 각각 씁니다.
라이브러리 쪽 코드는 늘고 여러분 프로그램의 추상화는 줄어드는 거래이며,
이 거래를 고른 것은 라이브러리가 아니라 언어입니다.

## 이 어휘가 값을 하는 순간

`await`를 쓰려고 "모나드"라는 단어가 필요하지는 않습니다. 이 단어가 값을
하기 시작하는 때는 *같은* 문제를 세 군데에서 알아볼 때입니다 — 중첩된
콜백, null 검사의 피라미드, `Either`의 연쇄. 그리고 그것이 해법의 모양이
하나뿐인 한 문제임을 알아챌 때. 또 한 번 값을 하는 때는, 어떤 라이브러리가
`flatMap`이 달린 타입을 줬을 때 소스를 읽지 않고도 그것을 이어 붙이면 무슨
일이 벌어질지 예측할 수 있을 때입니다.

설계를 고를 때도 값을 합니다. 여러분의 타입에 `of`와 `flatMap`이 있고
법칙이 성립한다면, 사용자는 체인을 자유롭게 리팩터링할 수 있습니다. 둘은
있는데 법칙이 성립하지 않는다면, 여러분이 만든 것은 함정입니다. 5장은 한
층 아래 펑터로 내려가고, 6장은 어플리커티브로 갑니다 — 실무의 검증 코드가
아주 많이 사는 층입니다.

## 연습문제

1. `Set<A>`에는 `expand`가 있고 `{a}`가 있습니다. 결과가 겹치는 단계 —
   예를 들어 `{1, 2, 3, 4}` 위의 `(x) => {x % 3}` — 로 세 법칙을 확인해
   보세요. `Set`은 모나드인가요? 그 답은 무엇에 달려 있나요?
2. `Either`의 `map`을 `flatMap`과 `Either.right`만으로 작성하고, `Right`와
   `Left` 양쪽에서 내장 `map`과 결과가 같은지 확인하세요.
3. `Future`에는 `then`이 있습니다. `Future.value(a).then(f)`는 정말로
   `f(a)`와 같은가요 — *값으로서* 같은가요, 아니면 결국 만들어 내는 것만
   같은가요? 이 질문은 법칙이 어떤 등호 위에서 서술되는지에 대해 무엇을
   알려 주나요?
4. `Logged`를 세 법칙이 모두 성립하도록 고치고, 두 단계를 두 가지 묶음으로
   이어 개수가 일치함을 보이세요.

## 정답과 해설

1. **모나드입니다 — 등호에 관한 단서가 붙습니다.** 등호를 집합의 상등으로
   보면 세 법칙 모두 성립합니다. `Set`은 법칙의 양변에서 똑같이 순서와
   중복을 버리기 때문입니다. `{1,2,3,4}.expand((x) => {x % 3})`은 어떻게
   묶어도 `{1, 2, 0}`입니다. 단서가 곧 요점입니다 — 법칙은 언제나 *어떤
   등호 위에서* 서술되고, 한 등호에서는 법칙을 지키는 타입이 다른 등호에서는
   어길 수 있습니다. 집합 상등에서 `List`는 법칙을 지키고, "삽입 순서까지
   같음"에서 `Set`은 지키지 못합니다.
2. `Either<L, B> mapViaFlatMap<L, A, B>(Either<L, A> e, B Function(A) f) =>
   e.flatMap((a) => Either.right(f(a)));`. `Left`에서는 두 버전 모두 `f`를
   부르지 않는데, 이것이 실패 쪽에 남은 왼쪽 항등 법칙의 지문입니다.
3. 둘은 같은 객체가 아니고, future의 `==`는 동일성 비교이므로, 법칙은
   *관찰적* 등호 위에서 서술됩니다 — 두 프로그램이 같은 값과 같은 효과를
   낳는다는 뜻이죠. 모든 모나드 법칙이 실제로 말하는 등호가 이것입니다.
   앞의 `Either` 확인에서 `==`를 쓸 수 있었던 것은 `Either`가 구조적 등호를
   정의해 두었기 때문입니다.
4. `flatMap`에서 `+ 1`을 지우고 각 단계가 자기 비용만 보고하게 하면 됩니다:
   `Logged(next.value, steps + next.steps)`. 이제 `of`는 `+`의 항등원을
   내놓고 이어 붙이기 자체는 아무것도 더하지 않으므로 세 법칙이 모두
   성립합니다 — `Logged.of(1).flatMap(f).flatMap(g)`와
   `Logged.of(1).flatMap((x) => f(x).flatMap(g))`가 둘 다 2를 보고합니다.
