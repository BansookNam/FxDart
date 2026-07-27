---
slug: invoice-summary
title: Line items to invoice summary — Dart vs FxDart
description: Turn order line items into per-category totals plus a grand total — two loop-and-fold idioms in plain Dart vs groupBy + sumBy + sortBy in FxDart.
heading: Line items to invoice summary
order: 27
tier: 3
functions: map, groupBy, sumBy, sortBy, join
domain: orders
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    주문의 각 라인 항목은 상품, 카테고리, 수량, 단가를 가집니다.
    청구서 요약을 출력하세요: 카테고리별로 한 줄씩 합계(수량 ×
    단가의 합)를 <strong>가장 큰 카테고리부터</strong> 나열한 뒤,
    총합을 출력합니다. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    같은 값 <code>qty * unitPrice</code>가 카테고리별로 한 번,
    전체로 한 번, 총 두 번 합산되는데, 두 버전은 이를 다르게
    다룹니다. 순수 Dart는 이를 서로 무관한 두 가지 관용구로 씁니다:
    카테고리를 위한, 맵에 값을 채워 넣는 변형 <code>for</code> 루프와,
    총합을 위한 명시적 초기값을 가진 <code>fold</code>입니다.
    FxDart는 "필드의 합"을 두 번 다 같은 방식으로 말합니다 —
    <code>sumBy</code> — 한 번은 <code>groupBy</code> 그룹마다, 한
    번은 전체 항목에 대해, 그리고 <code>sortBy</code>가 행의 순서를
    매깁니다. 청구서에 할인 규칙이 추가되면, FxDart는 파이프라인당
    한 곳의 어휘만 바뀌지만, 네이티브 버전은 루프 본문<em>과</em>
    fold를 모두 바꿔야 합니다.
  </p>
