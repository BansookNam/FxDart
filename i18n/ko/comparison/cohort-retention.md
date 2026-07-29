---
slug: cohort-retention
title: 코호트 리텐션 테이블 — Dart vs FxDart
description: 가입월 기준 코호트와 이후 활동을 비교합니다 — 중첩된 groupBy/dropWhile/filter 파이프라인과 누산 리스트를 사용하는 중첩 for 루프를 비교합니다.
heading: 코호트 리텐션 테이블
order: 32
tier: 4
functions: groupBy, sortBy, map, dropWhile, filter, size, join
domain: users
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    각 사용자(데이터는 코드 안에 있음)는 가입월과 활동한 월의 목록을 갖고
    있습니다. 사용자를 <strong>가입월 기준 코호트</strong>로 묶고,
    <em>그 이후의</em> 각 월마다 코호트 중 몇 퍼센트가 여전히 활동
    중이었는지 출력하세요 — 코호트당 한 줄씩, 오래된 순서로 정렬합니다.
    두 버전 모두 <em>예상 출력</em> 아래에 표시된 테이블을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    리텐션 테이블은 파이프라인 속의 파이프라인입니다: 바깥쪽은 코호트,
    안쪽은 월입니다. FxDart에서는 두 계층 모두 표현식입니다 — 코호트에
    대해서는 <code>groupBy</code> → <code>sortBy</code> → <code>map</code>이
    적용되고, 각 행 안에서는 <code>dropWhile</code>이 가입월까지의 달을
    건너뛴 뒤 <code>filter</code> + <code>size</code>가 여전히 활동 중인
    사용자 수를 셉니다. 네이티브 버전은 계층마다 가변 누산 리스트
    (<code>rows</code>, <code>cells</code>)가 필요하고, 이를 엮기 위해 두
    겹의 중첩 <code>for</code> 루프가 필요합니다. 실제 리텐션 로직은
    동일하지만, 코드의 눈에 보이는 뼈대가 되는 대신 루프 본문 곳곳에
    흩어져 있습니다.
  </p>
