---
slug: mergeScan
title: mergeScan — FxDart 101
description: FxDart mergeScan 튜토리얼: 각 이벤트를 내부 스트림으로 접어 공유 상태를 만들기 — switchScan은 취소하고, expandEach는 트리를 걷습니다 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>mergeScan</code>, <code>switchScan</code> &amp; <code>expandEach</code>
section: 14
crumb: mergeScan
prev: switchLatest.html
prevLabel: switchLatest
next: race.html
nextLabel: race
---
  <p class="hero-sub">각 이벤트를 내부 스트림으로 접어 공유 상태를 만듭니다 — 병합하거나, 전환하거나, 트리를 걷거나. 시드는 내보내지 <em>않습니다</em>.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>FxEvents.scan</code>은 시드를 먼저 내보낸 뒤 매 누산
    값을 내보냅니다 — 풀 레이어 관례이며
    <code><a href="scan.html">scan</a></code>과 같습니다.
    <code>mergeScan</code>과 <code>switchScan</code>은
    그렇지 <strong>않습니다</strong>. 시드는 시작 누산기일 뿐,
    이벤트가 아닙니다. Rx와 같고,
    <code>FxEvents.scan</code>에서 온 사람을 놀라게 하는 지점이
    바로 이것입니다: 빈 소스는 빈 채로 닫힙니다.
  </p>
  <p>
    <code>mergeScan(seed, acc)</code>은 각 이벤트를
    <code>accumulator(state, value)</code>를 내부 스트림으로
    열어 접습니다. 내부가 내보내는 모든 값이 새 상태가 되고
    전달됩니다. <code>concurrent: n</code>을 주면 한 번에 최대
    <em>n</em>개만 돌고 나머지는 큐에서 기다립니다. 내부들은
    상태 변수 하나를 공유합니다 — 가장 최근 내부 방출이
    이깁니다. <code>concurrent</code>가 null이면 무제한입니다.
    결과는 소스가 닫히고 모든 내부가 끝났을 때 닫힙니다.
  </p>
  <p>
    <code>switchScan</code>은 취소하는 형제입니다: 새 소스 값이
    이전 내부를 진행 도중에 <strong>취소</strong>하고, 가장 최근
    내부 방출(있다면)이 다음 누산기 호출에 건네지는 상태입니다.
    소스가 닫힌 뒤에도 현재 내부는 끝까지 갈 수 있습니다.
  </p>
  <p>
    <code>expandEach</code>는 Rx의 <code>expand</code>이며,
    풀 레이어가 이미 그 단어를 이터러블
    <code><a href="flatMap.html">flatMap</a></code>에 쓰고 있어
    이름이 바뀌었습니다. 모든 소스 값을 내보낸 뒤, 그 값의
    <code>project</code> — 그리고 <code>project</code> 자신이
    내보내는 모든 값 — 을 재귀적으로, 너비 우선으로
    평탄화합니다. 빈 스트림을 결코 돌려주지 않는
    <code>project</code>는 종료되지 않습니다. fxdart 이벤트
    레이어, Rx의 <code>mergeScan</code>,
    <code>switchScan</code>, <code>expand</code>를 따랐습니다.
  </p>

  <h2>데모 1 · mergeScan — 시드는 침묵한다</h2>
  {{playground:0}}

  <h2>데모 2 · switchScan — 새것이 취소한다</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>expandEach</code>, 유한 트리 <code>0 → 1 → 2</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="scan.html"><code>scan</code></a> — 시드가 <em>내보내집니다</em> ·
    <a href="switchMap.html"><code>switchMap</code></a> / <a href="mergeMap.html"><code>mergeMap</code></a> — 공유 상태 없는 평탄화 ·
    <a href="flatMap.html"><code>expand</code></a> — 풀 쪽의 한 단계 평탄화, 이 연산자가 가져갈 수 없었던 이름
  </div>
