---
slug: budget-alerts
title: 월 예산을 초과한 카테고리 — Dart vs FxDart
description: 카테고리별 지출을 합산하고, 예산을 초과한 것만 남긴 뒤, 초과액 순으로 정렬합니다 — 순수 Dart의 가변 맵 기반 집계와 FxDart의 groupBy + filter + sortBy를 비교합니다.
heading: 월 예산을 초과한 카테고리
order: 25
tier: 3
functions: groupBy, map, filter, sortBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    각 지출 카테고리에는 월 예산이 있습니다. 7월 거래 내역에서 카테고리별로
    합산한 뒤, <strong>예산을 초과한</strong> 카테고리만 남기고, 초과가 가장
    심한 순서로 출력하세요 — 각 줄에 지출액, 예산, 초과액을 표시합니다.
    데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    형식을 맞추는 줄은 두 버전이 동일합니다 — 차이는 그 이전 모든 부분에
    있습니다. 네이티브 Dart는 가변 맵을 이용해 직접 그룹화한 다음, 관용구를
    두 번 바꿉니다: 합산을 위한 <code>for</code> 루프, 필터링을 위한
    <code>where</code>, 순위를 매기기 위해 직접 만든 비교자와 함께 쓰는
    캐스케이드 <code>sort</code>. FxDart 버전은 처음부터 끝까지 하나의
    어휘로 이어집니다: <code>groupBy</code>, 합계를 구하는 <code>map</code>,
    예산과 비교하는 <code>filter</code>, 초과액으로 정렬하는
    <code>sortBy</code>, 그리고 <code>join</code>. "예산 초과", "초과액이
    큰 순서" 같은 각 비즈니스 규칙이 코드 리뷰에서 바로 짚어낼 수 있는 이름
    붙은 한 단계로 존재합니다.
  </p>
