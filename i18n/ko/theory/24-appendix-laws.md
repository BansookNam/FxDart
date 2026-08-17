---
slug: laws
chapter: 0
part: 6
title: 부록 B · 법칙 모음
description: 이 책의 모든 법칙을 마주 보는 두 쪽에 — 무엇을 말하는지, 무엇을 허가하는지, 어떻게 검사하는지.
---
# 부록 B · 법칙 모음

각 법칙을 코드 한 줄과, 그것이 허락하는 리팩터링과 함께 정리했습니다. 여기 있는
모든 것은 19장이 검사한 방식 그대로 검사할 수 있습니다. 입력을 생성하고 등식을
단언하기.

## 펑터 — 5장

| 법칙 | 등식 |
|---|---|
| 항등 | `m.map((x) => x)` == `m` |
| 합성 | `m.map(f).map(g)` == `m.map((x) => g(f(x)))` |

**허가하는 것:** 무연산 `map` 지우기, `map` 둘을 한 번의 순회로 융합하기, 읽기
좋으라고 `map` 하나를 둘로 쪼개기.

**깨지는 경우:** `map`이 함수를 적용하는 것 외의 일을 할 때 — 세기, 로깅, 캐싱,
순서 바꾸기(5장의 `Counted`).

## 모나드 — 1장

| 법칙 | 등식 |
|---|---|
| 왼쪽 항등 | `of(a).flatMap(f)` == `f(a)` |
| 오른쪽 항등 | `m.flatMap(of)` == `m` |
| 결합 | `m.flatMap(f).flatMap(g)` == `m.flatMap((x) => f(x).flatMap(g))` |

**허가하는 것:** 감싼 값을 인라인하기, 무연산 단계 지우기, 사슬 재그룹핑하기 —
"이걸 헬퍼로 빼자"가 하는 일이 그것입니다.

**깨지는 경우:** 이어 붙이는 것 자체에 타입이 기록하는 비용이 있을 때(1장의
`Logged`).

**따름정리:** `m.map(f)` == `m.flatMap((x) => of(f(x)))` — 모든 적법한 모나드는
적법한 펑터입니다.

## 어플리커티브 — 6장

| 법칙 | 등식 |
|---|---|
| 항등 | `of(id).ap(m)` == `m` |
| 준동형 | `of(f).ap(of(a))` == `of(f(a))` |
| 교환 | `u.ap(of(a))` == `of((f) => f(a)).ap(u)` |
| 합성 | `of(compose).ap(u).ap(v).ap(w)` == `u.ap(v.ap(w))` |

`map2`의 말로 하면 쓸모 있는 귀결은 이것입니다. `map2`는 두 구조를 *모두*
실행하고 결합해야 하며, 한쪽을 들여다보고 다른 쪽을 결정해서는 안 됩니다.

**허가하는 것:** 독립적인 가지를 동시에 실행하기, 그 실패를 누적하기, 독립적인
가지의 순서를 바꾸기(결과는 같은 방식으로 결합됩니다).

**깨지는 경우:** "독립적"인 가지가 사실은 서로 의존할 때 — 검증 가지 안의 공유
가변 상태가 흔한 범인입니다.

## 모노이드 / 반군 — 8장

| 법칙 | 등식 |
|---|---|
| 결합 | `(a + b) + c` == `a + (b + c)` |
| 왼쪽 항등 | `empty + a` == `a` |
| 오른쪽 항등 | `a + empty` == `a` |

**허가하는 것:** fold를 덩어리로 나누기, 병렬·점진적 축약, 항등원을 `fold`의
씨앗으로 삼아 빈 경우를 전 함수로 만들기.

**깨지는 경우:** 연산이 뺄셈 모양일 때, 또는 "항등원"을 연산이 아니라 타입에서
짐작했을 때(곱셈에 `0`).

**함의하지 않는 것:** 교환 — `a + b` == `b + a`는 *별개의* 더 강한 법칙이고,
쓸모 있는 모노이드 대부분에는 없습니다.

## 순회 — 9장

| 법칙 | 진술 |
|---|---|
| 항등 | 항등 어플리커티브로 순회하면 `map`이다 |
| 합성 | 어플리커티브 둘로 차례로 순회한 것 == 그 둘의 합성으로 한 번 순회한 것 |
| 자연성 | 자연변환은 `traverse`와 교환된다 |

**허가하는 것:** 사슬의 어디에서 순회할지 고르기, 원소 단위 함수를 건드리지 않고
빨리 실패를 누적으로 바꾸기.

## 자연변환 — 20장

| 법칙 | 등식 |
|---|---|
| 자연성 | `α(m.map(f))` == `α(m).map(f)` |

**허가하는 것:** 변환(`toList`, `toAsync`, `toNullable`, `first`)을 `map`을
가로질러 양방향으로 옮기기.

**깨지는 경우:** 변환이 값을 들여다볼 때 — `sortBy`가 표준 반례입니다.

## 범주 — 20장

| 법칙 | 등식 |
|---|---|
| 결합 | `(h ∘ g) ∘ f` == `h ∘ (g ∘ f)` |
| 항등 | `id ∘ f` == `f` == `f ∘ id` |

**허가하는 것:** 순수 함수의 어떤 합성이든 뽑아내거나 인라인하기, 파이프라인
단계 포함.

## 그 모두의 전제 조건

1. **순수함.** 위의 모든 법칙은 값에 대해 서술됩니다. 효과는 값이 같은 두 식을
   서로 다른 두 프로그램으로 만듭니다(2장).
2. **맞는 등호.** `Either`와 `Money`는 구조적, `Future`는 관찰적, `Set`은 집합
   상등. 한 등호에서 성립하는 법칙이 다른 등호에서는 깨질 수 있습니다(19장).
3. **누군가 확인했을 것.** 타입의 법칙은 주장입니다. 속성 테스트가 있기 전까지
   그것은 주석입니다(19장).

## 테스트 템플릿

```dart run
import 'package:fxdart/fxdart.dart';

// Generate → assert the equation → report. The seed is fixed so
// a failure can be reproduced exactly.
void main() {
  final rnd = createSeededRandom(7);
  final inputs = List.generate(100, (_) => (rnd() * 100).floor());

  Either<String, int> f(int n) =>
      n.isEven ? Either.right(n ~/ 2) : Either.left('odd');
  Either<String, int> g(int n) => Either.right(n + 1);

  var violations = 0;
  for (final x in inputs) {
    final m = Either<String, int>.right(x);
    if (m.map((v) => v) != m) violations++;
    final lifted = Either<String, int>.right(x);
    if (lifted.flatMap(f) != f(x)) violations++;
    if (m.flatMap(f).flatMap(g) !=
        m.flatMap((v) => f(v).flatMap(g))) {
      violations++;
    }
  }
  print('violations: $violations');
}
```
