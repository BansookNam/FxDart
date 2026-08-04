---
slug: monthly-category-report
title: 지출액순으로 정렬한 월간 카테고리 리포트 — Dart vs FxDart
description: 가계부를 한 달로 필터링하고 카테고리별로 합산해 순위를 매깁니다 — 순수 Dart의 루프와 가변 맵을 FxDart의 filter + groupBy + sortBy와 비교합니다.
heading: 지출액순으로 정렬한 월간 카테고리 리포트
order: 29
tier: 3
functions: filter, groupBy, map, sortBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    6월에서 7월로 넘어가는 가계부에서 2026년 7월 지출 리포트를 만드세요:
    7월 거래만 남기고, 카테고리별로 합산하여, 카테고리당 한 줄씩
    <strong>지출액이 큰 순서대로</strong> 출력하세요. 데이터는 아래 코드에
    있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄을 출력해야
    합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    순수 Dart에는 <code>groupBy</code>가 없으므로, 루프가 가변 맵 안에서
    그룹화와 합산을 동시에 처리합니다 — 코드는 간결하지만 네 가지
    요구사항(7월만, 카테고리별, 합산, 순위)이 하나의 본문 안에 뒤섞여
    있습니다. FxDart 체인은 이를 눈에 보이는 네 단계로 유지합니다:
    <code>filter</code>로 해당 월을 거르고, <code>groupBy</code>로
    카테고리를 나누고, <code>map</code>으로 각 그룹을 합계로 바꾸고,
    <code>sortBy</code>로 내림차순 정렬한 다음 — <code>join</code>이
    리포트 형식을 만듭니다. 요구사항을 하나 더 추가하는 일(예: 최소
    합계 조건)은 체인에 한 단계를 더하는 것으로 끝나지만, 루프에서는
    이미 복잡한 본문 안에 또 하나의 분기를 더하는 일이 됩니다.
  </p>
