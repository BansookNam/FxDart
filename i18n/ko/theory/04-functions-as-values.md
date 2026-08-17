---
slug: functions-as-values
chapter: 4
part: 1
title: 값으로서의 함수
description: 합성, 부분 적용, 커링 — 그것이 무엇인지, 가변 제네릭이 없는 언어에서 얼마를 치러야 하는지, 그리고 왜 FxDart가 커리된 pipe 대신 메서드 체인을 택했는지.
---
# 값으로서의 함수

> **이 장에서 다루는 것**
> - 함수 둘을 하나로 만드는 연산으로서의 합성
> - 부분 적용과 커링, 그리고 둘의 차이
> - 왜 충실한 커리드 `pipe`를 Dart에서 타입 지어 쓸 수 없는가
> - FxDart가 대신 내놓은 것과 그 선택의 대가

## 합성

한 함수의 출력이 다른 함수의 입력과 맞아떨어질 때, 둘을 합성하면 중간값을 전혀
언급하지 않는 세 번째 함수가 나옵니다.

```dart run
import 'package:fxdart/fxdart.dart';

String trim(String s) => s.trim();
String upper(String s) => s.toUpperCase();

// Dart has no composition operator, so composition is a
// three-line helper. Its shortness is the point: the concept
// is small, only the notation is missing.
C Function(A) compose2<A, B, C>(
        B Function(A) f, C Function(B) g) =>
    (a) => g(f(a));

void main() {
  // By hand.
  String shout(String s) => upper(trim(s));
  print(shout('  hello  '));

  // As a value: the composition is itself passable.
  final shout2 = compose2(trim, upper);
  print(shout2('  hello  '));
  print(['  a ', ' b'].map(shout2).toList());

  // pipe1 is the same idea with the value supplied first.
  print(pipe1('  hi ', shout2));
}
```

합성은 결합적입니다 — `(f ∘ g) ∘ h`와 `f ∘ (g ∘ h)`가 같습니다 — 그리고 항등
함수가 그 단위원입니다. 그것이 모노이드이고(8장), 파이프라인의 단계를 어떻게
묶어도 결과가 같은 이유입니다. "헬퍼로 빼내기"가 언제나 안전한 이유이기도
합니다. 체인의 세 단계를 이름 붙은 함수로 뽑아내는 것이 바로 그 법칙이 허락하는
재그룹핑이니까요.

## 부분 적용과 커링

두 말이 섞여 쓰이지만 같은 것이 아닙니다.

- **부분 적용(partial application)** 은 인자 *일부*를 지금 고정하고 나머지는
  나중에 받습니다. `add(2, _)`가 인자 하나짜리 함수가 되는 것이죠.
- **커링(currying)** 은 인자 *n*개짜리 함수를 인자 하나짜리 함수 *n*개의 중첩으로
  다시 씁니다. `int Function(int, int)`이
  `int Function(int) Function(int)`이 됩니다. 부분 적용은 그중 첫 겹을 호출하는
  것일 뿐입니다.

```dart run
import 'package:fxdart/fxdart.dart';

int addTwo(int a, int b) => a + b;

void main() {
  // Currying: one call per argument.
  final curriedAdd = addTwo.curried;
  final add10 = curriedAdd(10);
  print([add10(5), add10(32)]);

  // Partial application without currying: a closure does it too.
  int Function(int) addAlso(int a) => (b) => a + b;
  print(addAlso(10)(32));

  // Uncurrying goes back.
  print(curriedAdd.uncurried(40, 2));
}
```

![합성과 커링](diagrams/t4-1-compose-curry.svg)

*그림 4-1. 합성은 기계 둘을 끝과 끝으로 잇고 그 이음매를 감춘다. 커링은 입력이 둘인 기계 하나를, 입력이 하나인 기계 둘로 다시 끼운다.*

## FxTS의 `pipe`를 왜 그대로 옮길 수 없었나

FxTS는 커리된 `pipe` 위에 서 있습니다. 모든 연산자가 콜백을 받아 데이터를
기다리는 함수를 돌려주고, `pipe`가 값을 그 목록에 통과시킵니다. TypeScript는
그것을 손으로 쓴 오버로드 20여 개(항수마다 하나)와, 그것들을 엮는 가변 튜플
타입으로 타입 짓습니다.

Dart에는 오버로드도 가변 제네릭도 없습니다. 단계 개수를 가리지 않는 `pipe`는
`dynamic`으로 후퇴할 수밖에 없습니다.

```dart
// FxDart ships this for FxTS parity — and every stage boundary
// is an unchecked cast.
final result = pipe(
  [1, 2, 3, 4],
  (dynamic xs) =>
      map((dynamic n) => (n as int) * 2, xs as Iterable),
  (dynamic xs) => toList(xs as Iterable<int>),
);
```

모든 단계 경계가 검사되지 않는 캐스트입니다. 컴파일러가 잡아 주길 바랐던 타입
오류 — `int` 파이프라인에 `String` 단계 — 가 이제 런타임에, 지연 이터레이터
한복판에서, 라이브러리 내부를 가리키는 스택 트레이스와 함께 도착합니다.

그래서 FxDart는 같은 아이디어에 다른 모양을 골랐습니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final result = fx([1, 2, 3, 4, 5, 6])
      .map((n) => n * 2)
      .filter((n) => n > 4)
      .take(3)
      .toList();
  print(result);
}
```

체인은 *타입이 붙은* 합성입니다. 각 메서드가 새 원소 타입의 `Fx<R>`을
돌려주므로 컴파일러가 값을 끝까지 따라가고, 에디터가 자동완성을 해 줍니다.
포기한 것은 단계 하나를 일급 값으로 붙들고 여기저기 넘기는 능력입니다. FxTS에서는
`map(f)` 자체가 값이지만, FxDart에서는 수신자가 필요한 메서드 호출입니다.
저장소의 `WHY_CURRIED.md`에 그 거래가 자세히 적혀 있습니다.

> 🎓 **커링은 관습이 아니라 동형입니다.** `(A, B) → C`와 `A → (B → C)`는 정확히
> 같은 정보를 담습니다 — 손실 없이 양방향으로 변환할 수 있고, `.curried` /
> `.uncurried`가 런타임에 그것을 보여 줍니다. 기본이 커링인 언어(하스켈, OCaml)는
> 동형의 한쪽을 원시로 골랐고, Dart는 다른 쪽을 골랐습니다. 한쪽에서 표현되는
> 것 중 다른 쪽에서 표현 못 할 것은 없습니다 — 다른 것은 편의성뿐이고, 편의성이야말로
> 이 선택이 중요한 이유입니다.

## 이미 쓰고 있는 고차 함수

함수를 받거나 돌려주는 함수를 **고차(higher-order)** 함수라고 하고, 파이프라인의
어휘는 고차 함수 그 자체입니다. `map`, `filter`, `fold`, `sortBy` 모두 행동을
인자로 받습니다. 이름으로 알아 둘 만한 FxDart의 두 가지를 더 봅시다.

```dart run
import 'package:fxdart/fxdart.dart';

bool small(int n) => n < 10;
bool odd(int n) => n.isOdd;

void main() {
  // juxt: one input, several functions, all their results.
  final stats = juxt([
    (Iterable<int> xs) => xs.length,
    (Iterable<int> xs) => xs.reduce((a, b) => a + b),
  ]);
  print(stats([3, 1, 4, 1, 5]));

  // Predicates are values too, so they combine.
  final both = (int n) => small(n) && odd(n);
  print(fx([3, 12, 7, 20]).filter(both).toList());
  print(fx([3, 12, 7, 20]).filter(negate(small)).toList());
}
```

## 이것이 값을 하는 순간

함수를 값으로 다루는 것은 행동은 달라지지만 구조는 그대로일 때 값을 합니다 —
파이프라인 하나에 정책 넷을 넘기기, 작고 이름 붙은 규칙들로 조립한 검증기 하나.
테스트할 때도 값을 합니다. 함수 파라미터는 가장 값싼 이음매이고 모킹 프레임워크가
필요 없습니다.

합성이 그것이 대체한 것보다 길어지는 순간부터는 값을 못 합니다. 독자가 머릿속에서
값에 적용해 봐야 하는 포인트프리 조합자 여섯 개의 사슬은, 이름이 좋은 `for` 루프보다
나쁩니다. Dart에는 합성 연산자가 없어서 그 임계점이 하스켈보다 빨리 오고, 그렇지
않은 척하는 것이 FP 코드가 악명을 얻는 방식입니다.

## 연습문제

1. `compose2(f, g)`는 `f`를 먼저 적용합니다. 하스켈의 `.` 연산자는 *오른쪽* 함수를
   먼저 적용합니다. `fx(...).map(f).map(g)`는 어느 순서를 쓰고, 왜 그것이 메서드
   체인에서 유일하게 온전한 선택인가요?
2. `compose2`를 두 번 써서 인자 하나짜리 함수 셋을 위한 `compose3`를 작성하세요.
   그런 다음 두 가지 묶는 방식이 같은 함수를 준다고 논증하세요.
3. `addTwo.curried(10)`은 함수를 돌려줍니다. 그 타입을 온전히 적으면
   무엇인가요? Dart는 왜 임의 항수의 함수에 대한 `curried` 게터를 추론하지
   못하나요?
4. `fx(xs).filter(small).filter(odd)`를 `filter` 하나로 다시 쓰세요. 그것은 언제나
   안전한 리팩터링인가요? `filter`의 어떤 성질에 기대고 있나요?

## 정답과 해설

1. 체인은 왼쪽에서 오른쪽으로 적용합니다. `map(f)` 다음 `map(g)`, 읽는 순서와
   같습니다. 메서드 체인은 그럴 수밖에 없습니다 — 수신자가 왼쪽에 있으니, 먼저
   적힌 것이 먼저 적용됩니다. 하스켈의 `.`이 오른쪽에서 왼쪽으로 읽히는 것은
   수학의 `f ∘ g`를 그대로 옮겼기 때문입니다. 둘 다 일관되며, 진짜 위험은 한
   코드베이스에서 둘을 섞는 것입니다.
2. `D Function(A) compose3<A, B, C, D>(...)`를
   `compose2(compose2(f, g), h)` 또는 `compose2(f, compose2(g, h))`로 만듭니다.
   합성이 결합적이므로 같은 함수입니다 — 파이프라인 단계를 재그룹핑할 수 있게
   해 주는 그 법칙이고, 1장 모나드 결합 법칙과 같은 모양입니다.
3. `int Function(int)`. Dart는 "임의 항수의 함수"를 타입 매개변수로 표현하지
   못하므로 `curried`는 항수마다 하나씩 적혀 있습니다 — `R Function(A, B)`,
   `R Function(A, B, C)` … 에 대한 `Curry2`부터 `Curry5`까지의 확장입니다.
   `pipe`에서 가변 제네릭이 없던 그 벽이고, 10장의 고차 타입과도 같은
   벽입니다. Dart의 타입 시스템은 의도적으로 1차입니다.
4. `fx(xs).filter((n) => small(n) && odd(n))`. 술어들이 순수할 때 안전합니다 —
   합쳐진 버전도 같은 원소에 같은 순서로 `small`과 `odd`를 부르고, 단락 평가도
   똑같습니다. 술어에 부수효과가 있다면(본 원소 수를 센다든지) 두 버전은
   달라집니다. 체인 형태도 살아남은 원소에만 `odd`를 부르고 합친 형태도
   그렇지만, 두 필터 *사이*에 순서가 정해진 효과가 있었다면 그 위치가
   달라집니다. 융합을 재작성이 아니라 리팩터링으로 만들어 주는 것이 순수함입니다.
