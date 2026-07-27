---
slug: date-window-spend
title: Spending inside a date window — Dart vs FxDart
description: Sum a slice of a date-sorted ledger — skipWhile/takeWhile/fold in plain Dart vs dropWhile + takeWhile + sumBy in FxDart. Native holds up well.
heading: Spending inside a date window
order: 13
tier: 2
functions: dropWhile, takeWhile, sumBy
alsoLink: fx
domain: transactions
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    가계부 내보내기 데이터가 이미 <strong>날짜순으로 정렬</strong>되어
    있습니다. <strong>2026-07-08부터 2026-07-21까지</strong>(양 끝
    포함) 지출을 리스트 전체를 훑지 않고 합산하세요: 구간 이전
    항목은 건너뛰고, 구간 안에 있는 동안만 가져와서, 남은 것을
    합산합니다. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    거의 차이가 없습니다. Dart는 모든 <code>Iterable</code>에
    <code>skipWhile</code>과 <code>takeWhile</code>을 기본 제공하며
    둘 다 지연 평가됩니다 — 순수 Dart 버전도 FxDart 버전과 정확히
    같은 방식으로 정렬 순서를 활용하고, 읽기도 마찬가지로 좋습니다.
    실질적인 차이는 마지막 단계뿐입니다: <code>sumBy</code>는 의도를
    이름으로 말해주는 반면, <code>fold</code>는 초기값과 결합 함수를
    그대로 드러냅니다. 이건 한 단어짜리 승리이지, 구조적인 승리는
    아닙니다 — 무승부라고 부르는 게 맞습니다. 코드베이스가 이미
    <code>fx</code>로 체이닝하고 있다면 일관성을 위해 여기서도
    쓰세요; 그렇지 않다면 순수 Dart로 충분합니다.
  </p>
