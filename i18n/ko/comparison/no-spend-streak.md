---
slug: no-spend-streak
title: 지출 없는 날의 최장 연속 기록 — Dart vs FxDart
description: 지출이 전혀 없었던 7월 날짜의 최장 연속 구간을 찾습니다 — 순수 Dart의 streak/longest 카운터 루프와 FxDart의 range + scan + max를 비교합니다.
heading: 지출 없는 날의 최장 연속 기록
order: 28
tier: 3
functions: range, map, scan, max, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    한 달치 가계부 거래 내역에서 <strong>지출이 전혀 없었던 7월 날짜의
    최장 연속 구간</strong>을 찾으세요(2026년 7월은 31일까지 있습니다).
    지출이 없는 날마다 <code>#</code>로 표시한 달력 스트립을 출력한 다음
    연속 일수를 출력하세요. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    연속 기록은 누적되는 값이며, 그것이 바로 <code>scan</code>이 하는
    일입니다: fold의 모든 중간 상태를 그대로 보존합니다. 파이프라인은
    정의 그 자체처럼 읽힙니다 — 날짜들(<code>range</code>)을 지출
    여부로 <code>map</code>하고, 지출이 있는 날에 리셋되는 연속 카운트로
    <code>scan</code>한 다음, <code>max</code>가 정점을 골라냅니다.
    네이티브 루프는 두 개의 가변 카운터와 <code>if</code> 문으로 같은
    것을 계산합니다 — 이를 검증하려면 반복을 머릿속으로 재생해야 하고,
    연속 기록 로직은 옆에 있는 스트립 생성 로직과 뒤엉켜 있습니다.
    FxDart 버전에서는 스트립(<code>map</code> + <code>join</code>)과
    연속 기록이 같은 <code>range</code> 위에서 동작하는 서로 독립적이고
    따로 읽을 수 있는 두 개의 파이프라인입니다.
  </p>
