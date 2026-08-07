---
slug: switchMap
title: switchMap — FxDart 101
description: FxDart switchMap 튜토리얼: 각 이벤트를 내부 스트림으로 매핑하고 최신 것만 비추기 — 검색창을 위한 새것에-의한-취소 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>switchMap</code>
section: 14
crumb: switchMap
prev: withLatestFrom.html
prevLabel: withLatestFrom
next: mergeMap.html
nextLabel: mergeMap
---
  <p class="hero-sub">각 이벤트를 내부 스트림으로 매핑하고 최신 것 하나만 비춥니다 — 새 이벤트가 오면 이전 내부 스트림을 진행 도중에 <em>취소</em>합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    모든 UI가 최소 한 번은 출시해 본 검색창 버그입니다: 사용자가
    <code>da</code>를 치고 <code>dart</code>를 칩니다. <code>da</code>
    요청이 더 느립니다. 그 낡은 결과가 마지막에 도착해 좋은 결과를
    덮어씁니다. 해법은 오래된 응답을 <em>무시</em>하는 것이 아니라
    아예 불가능하게 만드는 것입니다: <code>switchMap(f)</code>는 각
    이벤트를 내부 스트림으로 매핑하고, 더 새 이벤트가 도착하는 순간
    이전 내부 스트림을 즉시 <strong>취소</strong>합니다. 하류로 비춰지는
    것은 언제나 가장 새로운 내부 스트림뿐입니다.
  </p>
  <p>
    새것에-의한-취소는 하나의 정책이고, 더 새로운 입력이 생기는 순간
    오래된 작업이 <em>무가치</em>해지는 경우에 정확히 옳은 정책입니다 —
    검색, 자동 완성, 내비게이션, "선택된 행의 상세 불러오기". 모든 내부
    스트림의 출력이 중요한 경우(예: 파일마다 업로드 하나)에는 틀린
    정책입니다 — 그것은 아무것도 취소되지 않는 pull 쪽
    <code><a href="mapConcurrent.html">mapConcurrent</a></code>의 팬아웃
    작업입니다.
  </p>
  <p>
    가장자리의 의미론: 체인은 소스가 닫히고 <em>그리고</em> 마지막 내부
    스트림이 완료됐을 때 닫힙니다 — 소스가 끝난다고 이미 화면에 오른
    작업이 잘리는 일은 없습니다. 매퍼가 던지면 에러 이벤트가 되고
    소스는 계속 갑니다. fxdart 이벤트 계층이며, Rx의
    <code>switchMap</code>을 따랐습니다.
  </p>

  <h2>데모 1 · 검색창, 고쳐진 모습</h2>
  {{playground:0}}

  <h2>데모 2 · 마지막 내부 스트림은 말을 끝맺는다</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 낡은 제안을 보여 줄 수 없는 자동 완성.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="debounce.html"><code>debounce</code></a> — 자연스러운 상류 파트너: 들어가는 쿼리는 줄이고, 나오는 낡은 결과는 없앰 ·
    <a href="race.html"><code>race</code></a> — 연속된 스트림이 아니라 <em>형제</em> 스트림 사이의 취소 ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — 모든 결과가 중요할 때, pull 쪽 팬아웃
  </div>
