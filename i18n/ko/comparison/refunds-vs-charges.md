---
slug: refunds-vs-charges
title: 환불과 청구, 둘 다 포맷팅 — Dart vs FxDart
description: 원장을 환불과 청구로 나누어 두 쪽 모두 출력합니다 — 순수 Dart의 where 두 번 대 FxDart의 partition 한 번을 비교합니다.
heading: 환불과 청구, 둘 다 포맷팅
order: 13
tier: 2
functions: partition, map, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    원장에는 청구와 환불(음수 금액)이 섞여 있습니다. 이를 두 그룹으로
    나누고, 모든 거래를 <code>merchant $amount</code> 형식으로 포맷팅한
    뒤, 그룹당 한 줄씩 출력하세요 — 환불이 먼저입니다. 데이터는 아래
    코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    Dart에는 <code>partition</code>이 없습니다 — <em>두 쪽 다</em> 필요할
    때 <code>where</code>는 한쪽만 주므로, 네이티브 버전은 데이터를 두 번
    훑습니다: 한 번은 조건으로, 한 번은 그 부정으로, 손수 작성합니다
    (<code>&lt; 0</code>과 <code>&gt;= 0</code>). 이는 데이터를 두 번
    순회하고 두 조건을 서로 맞춰 유지해야 한다는 뜻입니다 — 환불 규칙이
    바뀌면 두 번째 줄이 따라 바뀐다는 보장이 없습니다. FxDart의
    <code>partition</code>은 이 분리를 하나의 선언으로 만듭니다: 조건
    하나, 순회 한 번, 그리고 양쪽 모두를 이름 붙여 구조 분해하는 레코드.
    이후의 <code>map</code> + <code>join</code> 포맷팅은 두 버전이
    동일합니다.
  </p>
