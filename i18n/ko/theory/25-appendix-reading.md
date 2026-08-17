---
slug: reading
chapter: 0
part: 6
title: 부록 C · 더 읽을거리
description: 다음에 어디로 갈 것인가 — 각 자료의 난이도와, 실제로 무엇에 좋은지에 대한 정직한 메모와 함께.
---
# 부록 C · 더 읽을거리

쓸모 있어지는 순서대로 정렬했고, 난이도를 솔직히 적었습니다. 필수인 것은 없고,
이 책의 모든 장은 그 자체로 섭니다.

## 이 프로젝트 안에서

| 자료 | 무엇에 좋은가 | 난이도 |
|---|---|---|
| **FxDart 101 튜토리얼** | API 표면을 함수 하나씩, 실행되는 데모와 함께 | 쉬움 |
| **Dart vs FxDart** (예제 52개) | 주어진 과제에 파이프라인이 맞는 도구인지, 판정과 함께 | 쉬움 |
| **RxDart vs FxDart** | 12장의 풀/푸시 결정을 실제 문제 50개에 적용 | 쉬움 |
| **`WHY_CURRIED.md`** | 4장 뒤의 추론 — 이식이 원본에 지는 빚 | 보통 |
| **`ARROW_MIGRATION_BLOCKER.md`** | 10장의 고차 타입 벽을, 부딪힌 그대로 기록한 문서 | 보통 |
| **`benchmark/AUTHORING.md`** | 14장의 숫자를 만드는 방법과 케이스 추가법 | 보통 |

## 조상들의 문서

| 자료 | 무엇에 좋은가 | 난이도 |
|---|---|---|
| **Arrow (코틀린) — 타입 있는 오류 가이드** | 사실상 4부의 명세. `Raise` 스코프, 누적, 설계 근거 | 보통 |
| **FxTS 문서** | 연산자 목록과 `concurrent(n)`. 이름이 FxDart와 거의 일치 | 쉬움 |
| **Cats (스칼라) — 타입클래스 문서** | 탑을 제네릭하게: functor → applicative → monad → traverse | 스칼라 없이는 어려움 |
| **하스켈 `Data.Functor` / `Control.Monad`** | 법칙의 원래 형태를, 간결하게 | 어려움 |

## 시간을 들일 만한 논문과 강연

- **Philip Wadler, *Monads for functional programming* (1992).** Moggi의
  의미론을 프로그래밍 기법으로 바꾼 논문. 효과를 값으로 다루는 일이 왜 할 만한지에
  대한 여전히 가장 명확한 동기 부여. *보통. 하스켈 문법이 낯설면 건너뛰고 산문을
  읽으세요.*
- **Conor McBride & Ross Paterson, *Applicative programming with effects*
  (2008).** 어플리커티브에 이름이 붙은 곳. 6장은 이 논문 첫 세 쪽의 요약입니다.
  *보통.*
- **Scott Wlaschin, *Railway Oriented Programming* (강연, 2014).** 16장이 쓰는
  그림을, 잘 발표한 것. *쉬움 — 타입 있는 오류에 대한 최고의 첫 강연.*
- **Erik Meijer, *Subject/Observer is Dual to Iterator* (2010).** 12장의
  쌍대성을, 그것 위에 Rx를 지은 사람에게서. *보통.*
- **Eugenio Moggi, *Notions of computation and monads* (1991).** 기원.
  *어려움 — Wadler 다음에 읽거나, 아예 읽지 않아도 됩니다.*

## 책

- **Scott Wlaschin, *Domain Modeling Made Functional*.** 이 책의 3, 16, 18장을
  F#로 하나의 실무 방법론으로 확장한 책. 현업 개발자에게 하는 단 하나의 추천.
  *쉬움~보통.*
- **Bartosz Milewski, *Category Theory for Programmers*.** 20장을 길게, 온라인
  무료, 초심자에게 인내심 있게. *보통. 배움은 연습문제에 있습니다.*
- **Runar Bjarnason & Paul Chiusano, *Functional Programming in Scala*.** 탑
  전체를 연습문제로 밑바닥부터 짓습니다. 훌륭하고, 진지한 시간 투자입니다.
  *어려움.*
- **Graham Hutton, *Programming in Haskell*.** 원천 언어를 배우기로 했다면
  가장 부드러운 완주 경로. *보통.*

## 특정 질문에 대해 무엇을 읽을 것인가

| 알고 싶은 것 | 갈 곳 |
|---|---|
| "X를 하는 FxDart 함수는 뭐지?" | 101 튜토리얼 |
| "여기서 파이프라인을 쓰긴 해야 하나?" | Dart vs FxDart, 그리고 22장 |
| "이 실패를 어떻게 모델링하지?" | 18장, 그다음 Arrow의 타입 있는 오류 가이드 |
| "왜 제네릭 `traverse`가 없지?" | 10장, 그다음 `ARROW_MIGRATION_BLOCKER.md` |
| "내 타입은 적법한가?" | 19장과 부록 B, 그다음 속성 테스트를 쓰세요 |
| "모나드가 *정말* 뭐지?" | 1장, 그다음 Wadler, 그다음 20장 |

## 이론을 읽는 법에 대한 맺음말

통하는 순서는 **써 보고, 이름 붙이고, 형식화하기** 입니다. 이 책의 모든 장이 그
순서로 쓰였고, 위의 자료들도 같은 방식으로 접근하는 것이 가장 좋습니다. 이미 쓰고
있던 구성물을 찾고, 그것에 이름을 붙이는 절을 읽고, 다음에 다시 만날 때까지
거기서 멈추세요.

코드를 앞에 두지 않고 이론서를 처음부터 끝까지 읽는 방식이 그 악명을 만들어
냈고, 그 방식은 통하지 않습니다.
