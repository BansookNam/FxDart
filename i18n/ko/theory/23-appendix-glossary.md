---
slug: glossary
chapter: 0
part: 6
title: 부록 A · 용어 사전
description: 이 책이 정의하는 모든 용어와 그 별칭, Dart에서의 철자, 그리고 그것을 소개하는 장.
---
# 부록 A · 용어 사전

책에서 굵게 표시된 모든 용어를, 다른 곳에서 불리는 이름과 Dart에서 적히는 자리와
함께 정리했습니다. 장 번호는 그 용어가 소개되는 곳입니다.

## 탑

| 용어 | 다른 이름 | Dart / FxDart에서 | 장 |
|---|---|---|---|
| **펑터(Functor)** | 함자 | 적법한 `map`을 가진 모든 타입 | 5 |
| **어플리커티브(Applicative)** | 어플리커티브 펑터 | `map2`, `zipOrAccumulate`, `Future.wait` | 6 |
| **모나드(Monad)** | — | `of`와 적법한 `flatMap`을 가진 모든 타입 | 1 |
| **모노이드(Monoid)** | — | `fold`의 씨앗 + 결합적 결합 연산 | 8 |
| **반군(Semigroup)** | — | 항등원 없는 결합적 결합 — `Nel` | 8 |
| **순회 가능(Traversable)** | — | `sequence`, `mapOrAccumulate`, `Future.wait` | 9 |
| **클라이슬리 합성** | 모나드 합성, `>=>` | `(a) => f(a).flatMap(g)` | 7 |
| **자연변환** | — | 내용물을 무시하는 제네릭 변환 | 20 |
| **고차 타입(HKT)** | 타입 생성자 다형성 | *Dart에서 표현 불가* | 10 |

## 연산

| 용어 | 다른 이름 | Dart / FxDart에서 | 장 |
|---|---|---|---|
| **of** | `pure`, `return`, `unit`, η | `Either.right`, `[x]`, `Future.value`, `fx([x])` | 1 |
| **map** | `fmap`, `<$>` | `map`, `Future.then` | 5 |
| **flatMap** | `bind`, `>>=`, `chain` | `flatMap`, `expand`, `Future.then`, `r.bind` | 1 |
| **join** | `flatten`, μ | `flat()`, `expand(id)` | 20 |
| **map2** | `zipWith`, `liftA2` | `map2`, `zipOrAccumulate2` | 6 |
| **traverse** | 순회 | `mapOrAccumulate`, `.map(f).sequence()` | 9 |
| **sequence** | — | `sequenceEither`, `Future.wait` | 9 |
| **fold** | 카타모피즘, 씨앗 있는 `reduce` | `fold`, `Either.fold` | 8 |

## 평가

| 용어 | 다른 이름 | Dart / FxDart에서 | 장 |
|---|---|---|---|
| **지연(Lazy)** | 유예, 비엄격 | 모든 `Fx` 단계 — 종결자 전까지 아무것도 실행 안 됨 | 11 |
| **종결 연산자** | 소비자, 싱크 | `toList`, `each`, `fold`, `first`, `sum` | 11 |
| **풀(Pull)** | 대화형, `Iterable` 모양 | `Iterable`, `FxAsyncIterable` | 12 |
| **푸시(Push)** | 리액티브, 옵저버블 | `Stream`, `FxEvents` | 12 |
| **배압(Backpressure)** | 흐름 제어 | 다음 값을 요청하지 않는 것 | 12 |
| **융합(Fusion)** | 단계 융합, deforestation | 사슬 전체를 한 번에 통과 | 5 |
| **동시성** | — | `concurrent(n)`, `mapConcurrent` — 기다림을 겹침 | 13 |
| **병렬성** | — | 아이솔레이트 — *계산*을 겹침 | 13 |

## 실패

| 용어 | 다른 이름 | Dart / FxDart에서 | 장 |
|---|---|---|---|
| **Either** | `Result`, `Validation`, 분리합 | `Either<L, R>`, `Left`, `Right` | 16 |
| **Raise 스코프** | 컨텍스트 리시버 스코프, 효과 스코프 | `either((r) { … })`, `r.bind`, `r.ensure` | 15 |
| **제한된 연속** | `shift`/`reset`, 효과 핸들러 | `either` 안의 비국소 탈출 | 15 |
| **단락 평가** | 빨리 실패 | 첫 `Left`가 사슬을 끝냄 | 16 |
| **누적** | 천천히 실패, 어플리커티브 검증 | `accumulate`, `zipOrAccumulate`, `mapOrAccumulate` | 17 |
| **NonEmptyList** | `Nel` | `NonEmptyList<E>` — `List` 위의 확장 타입 | 8 |
| **모나드 트랜스포머** | `EitherT`, `OptionT` | *쓰지 않음* — 대신 `eitherAsync` | 7 |

## 기초

| 용어 | 다른 이름 | Dart / FxDart에서 | 장 |
|---|---|---|---|
| **순수 함수** | — | 같은 입력, 같은 출력, 관찰 가능한 것 없음 | 2 |
| **참조 투명성** | 치환 가능성 | 호출을 결과로 바꿔 놓기 | 2 |
| **효과(Effect)** | 부수효과 | 반환값 외에 관찰 가능한 모든 것 | 2 |
| **전 함수(Total function)** | — | 모든 입력에 정의됨 — `fold`는 그렇고 `reduce`는 아님 | 8 |
| **곱 타입** | 레코드, 튜플, 구조체 | `(A, B)`, 클래스 필드 | 3 |
| **합 타입** | 태그 유니온, 배리언트, 쌍대곱 | `sealed class` + `switch` | 3 |
| **대수적 자료형(ADT)** | — | 합과 곱을 합쳐서 | 3 |
| **커링** | — | `.curried` / `.uncurried` | 4 |
| **부분 적용** | — | 인자 일부를 잡은 클로저 | 4 |
| **고차 함수** | — | 함수를 받거나 돌려줌 | 4 |
| **등식 추론** | — | 법칙에 따라 같은 것을 같은 것으로 바꾸기 | 19 |
| **법칙(Law)** | 속성, 계약 | 인스턴스가 만족해야 하는 등식 | 1, 5, 8 |
| **범주(Category)** | — | 대상 + 합성되는 화살표 + 항등 | 20 |

## 같은 것을 가리키는 이름들

다른 언어의 글을 읽을 때 쓸 짧은 해독표입니다.

- `flatMap` = `bind` = `>>=` = `chain` = `SelectMany`(C#) = `expand`(Dart의
  `Iterable`).
- `of` = `pure` = `return` = `unit` = `just` = `Right` = `Future.value`.
- `map` = `fmap` = `<$>` = `Select`(C#) = `then`(Dart의 `Future`, 이것은
  `flatMap`이기도 합니다).
- `Either<E, A>` = `Result<A, E>`(러스트 — 매개변수 순서가 뒤바뀐 것에 주의) =
  `Validation`(어플리커티브가 누적할 때).
- `NonEmptyList` = `Nel` = `NonEmptyChain`(Cats).
