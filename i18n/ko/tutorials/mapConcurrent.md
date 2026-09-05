---
slug: mapConcurrent
title: mapConcurrent — FxDart 101
description: FxDart mapConcurrent 튜토리얼 — toAsync, map, concurrent를 하나로 미리 결합해 동시성 제한 매핑을 한 단계로 씁니다. 라이브 플레이그라운드 포함.
heading: <code>mapConcurrent</code>
section: 11
crumb: mapConcurrent
prev: concurrent.html
prevLabel: concurrent
next: concurrentPool.html
nextLabel: concurrentPool
---
  <p class="hero-sub">동시성 제한이 있는 매핑을 한 단계로 — <code>toAsync().map(f).concurrent(n)</code>을 미리 결합했습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    "이 값들에 이 비동기 함수를, 한 번에 최대 <em>n</em>개씩, 결과는
    순서대로" — 실전 코드에서 가장 흔한 비동기 파이프라인인데, 지금까지는
    연산자 세 개로 말해야 했습니다. 비동기 세계로 들어가는
    <code><a href="toAsync.html">toAsync()</a></code>, 변환하는
    <code>map(f)</code>, 평가를 제한하는
    <code><a href="concurrent.html">concurrent(n)</a></code>.
    <code>mapConcurrent(n, f)</code>는 정확히 그 합성을 체인 한 단계로
    만든 것입니다.
  </p>
  <p>
    재구현이 아니라 합성 <em>그 자체</em>이기 때문에 모든 보장이 그대로
    이어집니다. 결과는 <strong>원본 순서</strong>로 도착하고(완료 순서를
    원하면 긴 형태로 풀어서
    <code><a href="concurrentPool.html">concurrentPool</a></code>을
    쓰세요), 동시에 실행되는 콜백은 최대 <code>concurrency</code>개이며,
    하류 연산자들은 계속 지연 방식으로 값을 끌어옵니다. 이미 비동기인
    체인에서는 <code>map(f).concurrent(n)</code>을 합성해 브리지를
    건너뜁니다.
  </p>
  <p>
    Dart 고유의 추가 기능입니다. FxTS는 <code>concurrent</code>를 별도
    단계로 파이프하며, 맵과 제한 사이에 다른 연산자를 끼워야 할 때는
    그 긴 형태를 언제든 그대로 쓸 수 있습니다.
  </p>

  <h2>데모 1 · 제한된 팬아웃, 순서 있는 결과</h2>
  {{playground:0}}

  <h2>데모 2 · 정확히 map + concurrent입니다</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 순서를 유지하면서 사용자를 한 번에 두 명씩 가져와 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — 바탕이 되는 제한기 ·
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — 원본 순서 대신 완료 순서 ·
    <a href="toAsync.html"><code>toAsync</code></a> — 이 연산자가 흡수한 동기→비동기 브리지 ·
    <a href="concurrentOrParallel.html">concurrent or parallel</a> — I/O vs CPU
  </div>
