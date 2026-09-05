---
slug: job-fetch
title: 한도 있는 동시 fetch — FxDart 101
description: 일 튜토리얼: N개 레코드를 동시에 최대 K개, 순서는 유지, 실패는 모두 보관 — mapConcurrent, mapRetry, mapOrAccumulate.
heading: 한도 있는 동시 fetch
section: 15
crumb: bounded concurrent fetch
prev: job-search.html
prevLabel: debounced search
---
  <p class="hero-sub">한도, 순서 유지, 실패는 모두 보관. <code>Future.wait</code>가 원시 연산자를 갖지 않는 일입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    아는 id 리스트를 fetch하는 것은 이벤트 스트림이 아닙니다. 데이터는
    손에 있고, 일은 I/O이며, 정책은 "동시에 최대 <em>n</em>개, 결과는
    원래 순서"입니다. 그것이
    <code><a href="mapConcurrent.html">mapConcurrent</a></code>입니다
    (또는
    <code>.toAsync().map(f).<a href="concurrent.html">concurrent</a>(n)</code>,
    같은 체인을 세 단계로 쓴 것).
    <code>Future.wait(ids.map(fetch))</code>는 전부를 한 번에 쏩니다.
    <em>n</em>개씩 묶으면 각 묶음의 가장 느린 것을 기다립니다. 손으로
    제대로 하면 워커 풀입니다 — 공유 커서, 미리 잡은 슬롯, 워커
    Future. FxDart가 그 풀에 붙인 단어가
    <code>concurrent(n)</code>입니다.
  </p>
  <p>
    불안정한 호출은
    <em>요소마다</em>
    <code><a href="retry.html">mapRetry</a></code>로
    재시도합니다. 터미널 전체를 감싸지 않습니다. 첫 번째만이 아니라 모든 문제를
    보고해야 하는 검증은
    <code><a href="eitherPipelines.html">mapOrAccumulate</a></code>에
    <code>concurrency: n</code>을 준 것입니다.
    각 요소는 제 스코프에서 돌아가서, 하나의 실패가 형제로 새지 않고,
    실패는 입력 순서로 나옵니다.
  </p>
  <p>
    워커 풀 일의
    <a href="../DartComparison/bounded-concurrency.html">Dart 비교</a>는
    명료함에서 <strong>fxdart</strong>입니다. 네이티브 풀은 두 번 쓰고
    나면 짧아 보이지 않습니다. 이 페이지는 그 일에, 비교 예제가 보여
    주지 않는 타입 있는 에러 절반을 더한 것입니다.
  </p>

  <h2>데모 1 · 동시에 둘, 순서는 유지</h2>
  <p>
    fetch 여섯, 겹치는 것은 절대 둘을 넘지 않습니다. 가짜 호출이
    진행 중인 요청을 세어서 한도가 출력에 보이게 합니다.
  </p>
  {{playground:0}}

  <h2>데모 2 · 실패는 모두 보관, 한도는 그대로</h2>
  <p>
    짝수 id는 실패합니다. <code>mapOrAccumulate</code>는 여전히 한 번에
    셋, 여전히 순서대로, <code>Left</code>는 <em>모든</em> 짝수 id를
    담습니다 — fail-fast가 아니라 fail-slow.
  </p>
  {{playground:1}}

  <div class="callout">
    <strong>관련:</strong>
    <a href="whichSurface.html">어느 표면</a> — 이것이 pull-async인 이유 ·
    <a href="concurrent.html"><code>concurrent</code></a> ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> ·
    <a href="retry.html"><code>retry</code> / <code>mapRetry</code></a> ·
    <a href="eitherPipelines.html"><code>mapOrAccumulate</code></a> ·
    <a href="job-search.html">디바운스 검색</a> — 시간 일 ·
    <a href="../DartComparison/bounded-concurrency.html">Dart vs FxDart: 한 번에 둘</a>
  </div>
