---
slug: equational-reasoning
chapter: 19
part: 5
title: 등식 추론
description: 치환으로서의 리팩터링 — 2부의 법칙으로 같음을 증명할 수 있는 코드 변환을 수행하고, 같은 법칙을 CI에서 도는 속성 테스트로 만들기.
---
# 등식 추론

> **이 장에서 다루는 것**
> - 치환의 연쇄로서의 리팩터링, 각 단계마다 이름 붙은 법칙
> - 실제 변환 하나: 다섯 단계를 둘로, 종이 위에서
> - 법칙을 속성 테스트로 — 생성기 하나, 테스트 프레임워크 없음
> - 이 방법 전체를 유효하게 하는 전제 조건들과, 그것이 무너지는 방식

## 리팩터링은 치환이다

2장은 참조 투명성을 정의했습니다. 호출을 결과로 바꿔 놓을 수 있다는 것. 그것의
더 큰 형제가 **등식 추론(equational reasoning)** 입니다. 어떤 식이든 그와 같은
식으로, 어디서든 바꿔 놓고, 프로그램이 그대로임을 아는 것.

2부의 모든 법칙이 그런 등식입니다.

| 법칙 | 등식 |
|---|---|
| 펑터 합성 | `m.map(f).map(g)` = `m.map(g ∘ f)` |
| 펑터 항등 | `m.map(id)` = `m` |
| 모나드 왼쪽 항등 | `of(a).flatMap(f)` = `f(a)` |
| 모나드 결합 | `m.flatMap(f).flatMap(g)` = `m.flatMap((x) => f(x).flatMap(g))` |
| 모노이드 결합 | `(a + b) + c` = `a + (b + c)` |

왼쪽에서 오른쪽으로 읽으면 최적화이고, 오른쪽에서 왼쪽으로 읽으면 명료화입니다.
양방향 모두 합법이며, 그래서 이것들은 사실이 아니라 *도구*입니다.

## 실제 변환 하나

아무도 변호하지 않을 코드에서 시작합니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final source = [3, 8, 2, 9, 4];

  // Before: five stages, two of them pointless.
  final before = fx(source)
      .map((n) => n)
      .map((n) => n * 2)
      .map((n) => n + 1)
      .filter((n) => n > 5)
      .fold(0, (a, b) => a + b);

  // After: two stages. Same value, by four substitutions.
  final after = fx(source)
      .map((n) => n * 2 + 1)
      .filter((n) => n > 5)
      .fold(0, (a, b) => a + b);

  print([before, after, before == after]);
}
```

네 단계와 각각의 허가증입니다.

1. `map((n) => n)`은 `map(id)`이므로 지웁니다. **펑터 항등.**
2. `map(f).map(g)` → `map(g ∘ f)`, 즉 `map((n) => n * 2 + 1)`.
   **펑터 합성.**
3. `filter`를 가로질러 옮긴 것은 없습니다. 술어가 *매핑된* 값을 읽기 때문이고,
   그 재배치에는 우리에게 없는 전제 조건이 필요합니다.
4. `fold`는 그대로입니다. `int`의 `+`는 결합적이고 항등원이 `0`이므로, 그 씨앗은
   진짜로 모노이드의 `empty`입니다. **모노이드 법칙.**

두 가지를 눈여겨볼 만합니다. 첫째, 변환이 기계적입니다 — 영리함도, 믿기 위한
테스트도 필요 없습니다. 둘째, 3번이 부주의한 "단순화"가 버그를 넣었을 자리이고,
멈추라고 말해 주는 것이 법칙입니다.

![허가된 재작성의 연쇄로서의 리팩터링](diagrams/t19-1-rewrite-chain.svg)

*그림 19-1. 화살표 하나하나가 이름을 가진 재작성이다. 법칙 이름을 댈 수 없다면 그것은 리팩터링이 아니라 다시 쓰고 기도하는 것이다.*

## 법칙을 테스트로

법칙은 속성이고, 속성은 여러 입력에 대해 돌릴 수 있는 테스트입니다. 요점을
보이는 데 프레임워크는 필요 없습니다.

```dart run
import 'package:fxdart/fxdart.dart';

// A tiny generator: deterministic, so a failure is reproducible.
List<int> sample(int n, int seed) {
  final rnd = createSeededRandom(seed);
  return List.generate(n, (_) => (rnd() * 200).floor() - 100);
}

Either<String, int> half(int n) =>
    n.isEven ? Either.right(n ~/ 2) : Either.left('odd: $n');

Either<String, int> dec(int n) => Either.right(n - 1);

void main() {
  var checked = 0;
  var failures = 0;

  for (final x in sample(200, 42)) {
    final m = Either<String, int>.right(x);

    // functor identity
    if (m.map((v) => v) != m) failures++;
    // monad left identity
    if (Either<String, int>.right(x).flatMap(half) != half(x)) {
      failures++;
    }
    // monad right identity
    if (m.flatMap((v) => Either<String, int>.right(v)) != m) {
      failures++;
    }
    // associativity
    final lhs = m.flatMap(half).flatMap(dec);
    final rhs = m.flatMap((v) => half(v).flatMap(dec));
    if (lhs != rhs) failures++;

    checked += 4;
  }

  print('$checked properties checked, $failures failures');
}
```

입력 이백 개, 법칙 넷, 출력 한 줄. 실제 스위트에서는 이것이 `package:test`
파일(축소가 필요하면 `package:glados`)이 되지만 모양은 그대로입니다.
**입력을 생성하고, 등식을 단언하고, 매 커밋마다 돌린다.**

이것을 할 이유는 FxDart의 `Either`가 틀렸을지도 모른다는 것이 아닙니다. *여러분의*
타입에도 법칙이 있기 때문입니다 — 절대 음수가 되면 안 되는 `Money`, `put` 뒤의
`get`이 넣은 것을 돌려줘야 하는 `Cache` — 그리고 그것들은 똑같이 테스트할 수
있으며 찾을 버그는 훨씬 많습니다.

```dart run
// A property test for a type of your own.
class Money {
  const Money(this.cents);
  final int cents;

  Money operator +(Money other) => Money(cents + other.cents);
  static const zero = Money(0);

  @override
  bool operator ==(Object o) => o is Money && o.cents == cents;
  @override
  int get hashCode => cents;
}

void main() {
  final values =
      [0, 1, 99, 100, -50, 123456].map(Money.new).toList();
  var bad = 0;

  for (final a in values) {
    // identity
    if (a + Money.zero != a) bad++;
    if (Money.zero + a != a) bad++;
    for (final b in values) {
      for (final c in values) {
        // associativity
        if ((a + b) + c != a + (b + c)) bad++;
      }
    }
  }

  print('monoid violations: $bad');
}
```

## 전제 조건

등식 추론은 같은 것이 진짜로 같을 때 통하고, 그것이 깨지는 방식은 정확히
셋입니다.

1. **순수하지 않음.** 콜백이 로그를 남기거나, 상태를 바꾸거나, 시계를 읽으면 값이
   같은 두 식이 같은 프로그램이 아닙니다. 2장.
2. **잘못된 등호.** 법칙은 *어떤 등호 위에서* 서술됩니다. `Either`는 구조적,
   `Future`는 관찰적, `Set`은 집합 상등. 한 등호에서 성립하는 법칙이 다른
   등호에서는 깨질 수 있고, 1장의 연습문제가 그것을 구체적으로 보여 줬습니다.
3. **법칙을 지키지 않는 타입.** 5장의 `Counted`와 1장의 `Logged` 둘 다 적법해
   보이는 `map`/`flatMap`을 갖고도 법칙을 어겼습니다. 이름을 읽는 것만으로는
   부족합니다. 법칙은 누군가 확인했어야 하는 주장입니다.

세 번째 때문에 이 장의 테스트가 학술적이지 않습니다. 확인하지 않은 법칙은
주석입니다.

> 🎓 **이 방법이 어디까지 가는가.** 전(total)이고 순수한 언어에서는 이 방법이
> 증명까지 이어집니다. 하스켈의 `foldr/build` 융합, Coq의 추출, GHC의 재작성
> 규칙은 모두 기계가 여러분을 대신해 수행하는 등식 추론입니다. Dart는 전 함수
> 언어도 순수 언어도 아니므로, 이 방법은 *사람*의 도구에 테스트를 더한 것으로
> 남습니다. 그것은 종류가 아니라 강도의 차이입니다. 같은 등식을, 증명이 아니라
> 표본으로 확인하는 것이고, 속성 테스트가 증명과 맺는 관계는 어디서나 그렇습니다.

## 이것이 값을 하는 순간

파이프라인을 단순화하거나, 헬퍼를 뽑아내거나, 성능을 위해 두 단계를 융합할
때마다 — 법칙 이름을 대든 안 대든 그것이 이 장의 방법입니다. 이름을 대는 것이
"같은 것 같은데"를 "같고, 이유는 이것이다"로 바꿔 줍니다.

리뷰에서 가장 값을 합니다. "어떤 법칙이 그 `filter`를 `map` 앞으로 옮겨도 된다고
말하나요?"는 답이 있거나, 버그를 찾아낸 질문입니다.

기댈 법칙이 없는 코드에서 격식으로는 값을 못 합니다. 명령형 초기화, IO 순서 잡기,
UI 콜백. 거기서 추론은 상태와 순서에 관한 것이고, 등식은 할 말이 없습니다.

## 연습문제

1. `fx(xs).filter(p).map(f)`와 `fx(xs).map(f).filter(p)`는 같은가요? 전제 조건을
   정확히 서술한 뒤, 그것을 깨뜨리는 `p`와 `f`를 드세요.
2. `xs.map(f).toList().map(g).toList()` → `xs.map((x) => g(f(x))).toList()` 를
   단계별로 정당화하세요. 어느 단계가 비용도 바꾸나요?
3. 속성 테스트를 확장해 `map`과 `flatMap`이 일치함을 검사하세요.
   `m.map(f)` == `m.flatMap((x) => Either.right(f(x)))`. 어느 법칙이 이것을 모든
   적법한 모나드에 대해 참으로 만드나요?
4. 여러분의 `Cache`는 `put` 뒤의 `get`이 넣은 값을 돌려줍니다. 그것을 등식으로
   쓰고, 그 등식이 `put`의 반환 타입에 대해 무엇을 함의하는지 말하세요.

## 정답과 해설

1. 일반적으로는 아닙니다. `p`가 *매핑되지 않은* 값에 대한 술어일 때 —
   즉 맞바꾼 뒤의 버전이 같은 것을 검사할 때 — 만 성립합니다.
   `f = (n) => n * 2`, `p = (n) => n > 5`로 깨뜨릴 수 있습니다. 먼저 거르면 6, 7,
   8…이 남고, 먼저 매핑하면 3, 4…의 두 배가 남습니다. `p`가 다른 종류의 값을
   위해 쓰였기 때문에 두 답이 다릅니다.
2. 중간의 `toList()`를 지우고(재료화이지 의미 단계가 아닙니다), 펑터 합성으로 두
   `map`을 융합하고, 마지막 `toList()`는 남깁니다. 비용이 바뀌는 것은 첫
   단계입니다. 중간 리스트 하나가 사라지는데, 그것이 14장의 할당 장치가
   리팩터링에 나타난 모습입니다.
3. `flatMap`으로 `map`을 정의한 것에 **왼쪽 항등**을 더한 것입니다.
   `Right(a)`에 `flatMap((x) => of(f(x)))`를 적용하면 `of(f(a))`, 즉
   `Right(f(a))`이고, 그것이 `map(f)`입니다. 모든 적법한 모나드가 이것을
   만족하며, 그래서 "모든 모나드는 펑터다"가 관습이 아니라 정리입니다.
4. `cache.put(k, v).get(k) == v` — 그리고 이 등식은 `put`이 캐시를 돌려줄 때에만
   *타입 검사를 통과한다*는 점을 보세요. `void put`이면 변경과 순서를 이야기하지
   않고는 이 속성을 서술할 수조차 없고, 그것이 불변 API가 테스트하기 쉬운 이유와
   같습니다. 등식에는 양변에 값이 필요합니다.
