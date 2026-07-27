---
slug: food-spending
title: 이번 달 식비 합계 — Dart vs FxDart
description: 가계부 한 카테고리를 합산합니다 — 순수 Dart의 where/fold 체인과 FxDart의 filter + sumBy를 비교합니다.
heading: 이번 달 식비 합계
order: 1
tier: 1
functions: filter, sumBy
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    날짜, 카테고리, 판매자, 금액을 가진 한 달치 가계부 거래 내역이 주어질 때,
    <strong>Food</strong> 카테고리에서 지출한 금액을 합산하여 통화 형식으로
    출력하세요. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    순수 Dart에는 "필드 합산"이라는 개념이 따로 없습니다 — <code>for</code>
    루프 안에서 누산 변수를 직접 갱신하거나, 초기값과 결합 함수를 명시해서
    <code>fold</code>를 써야 합니다. FxDart의 <code>sumBy</code>는 그 의도를
    한 단어로 표현하고, <code>filter → sumBy</code> 체인은 데이터가 흐르는
    순서 그대로 읽힙니다. 두 단계짜리 작업에서는 차이가 작지만, 단계가
    늘어날수록 그 차이는 점점 벌어집니다.
  </p>
