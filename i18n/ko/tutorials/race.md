---
slug: race
title: race — FxDart 101
description: FxDart FxEvents.race 튜토리얼: 먼저 내보내는 스트림이 이기고 진 쪽은 모두 즉시 취소됩니다 — 캐시 대 네트워크를 한 줄로 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>race</code>
section: 14
crumb: race
prev: mergeMap.html
prevLabel: mergeMap
next: waitAll.html
nextLabel: waitAll
---
  <p class="hero-sub">먼저 내보내는 후보가 이깁니다: 그 스트림 전체가 비춰지고, 다른 모든 후보는 그 자리에서 취소됩니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    캐시와 네트워크에 동시에 물어보고, 먼저 답하는 쪽을 취합니다.
    다운로드 미러 셋을 시도하고, 가장 빠른 것을 남깁니다.
    <code>FxEvents.race(candidates)</code>는 모든 후보를 한꺼번에
    구독하고, 어디서든 나온 첫 <em>이벤트</em>가 승부를 결정합니다: 그
    이벤트가 전달되고, 진 후보들은 모두 <strong>즉시
    취소됩니다</strong> — 음소거가 아니라 취소입니다. 그들의 소켓은
    닫히고, 작업은 멈추고, 이벤트는 일어나지 않습니다.
  </p>
  <p>
    무엇이 이기는지 정확히 해 둡시다: 어디서든 나온 첫 이벤트가 승자를
    고르고, 그때부터 race는 <strong>이긴 스트림을 온전히
    비춥니다</strong> — 이후 그 스트림이 만들어 내는 모든 이벤트가
    흘러오고, 승자가 닫히면 race도 닫힙니다. <em>에러</em>도 이길 수
    있습니다: 빠르게 고장 난 엔드포인트가 느리지만 건강한 것을
    이깁니다. 이것이 정확히 정직한 동작입니다 — 누가 먼저 답하는지
    물었고, "실패했다"도 하나의 답이니까요. 느리고 불안정한 구간은
    경주에 내보내기 전에 각 후보에
    <code><a href="timeout.html">timeout</a></code>/<code><a href="retry.html">retry</a></code>로
    안전장치를 거세요.
  </p>
  <p>
    한 번도 내보내지 않고 닫히는 후보는 조용히 탈락합니다. 모두가
    그렇거나 — 후보 목록이 비어 있으면 — race는 빈 채로 닫힙니다.
    이웃과의 취소 방향 차이에 주목하세요:
    <code><a href="switchMap.html">switchMap</a></code>은 연속된 스트림
    중 <em>더 오래된</em> 쪽을 취소하고, <code>race</code>는 동시의
    스트림 중 <em>더 느린</em> 쪽을 취소합니다. fxdart 이벤트 계층이며,
    Rx의 <code>race</code>/<code>amb</code>를 따랐습니다.
  </p>

  <h2>데모 1 · 캐시 대 네트워크, 진 쪽은 취소</h2>
  {{playground:0}}

  <h2>데모 2 · 에러도 이길 수 있고, 빈 후보는 탈락한다</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 세 미러 중 가장 빠른 것.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="switchMap.html"><code>switchMap</code></a> — 더 느린 쪽 대신 더 오래된 쪽을 취소 ·
    <a href="timeout.html"><code>timeout</code></a> — 경주 전에 각 후보에 한도 걸기 ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — 승자가 아니라 모두의 이벤트를 원할 때는 <code>FxEvents.merge</code>
  </div>
