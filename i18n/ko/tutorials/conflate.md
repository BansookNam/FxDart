---
slug: conflate
title: conflate — FxDart 101
description: FxDart conflate 튜토리얼 — 비동기 작업을 한 번에 하나씩 실행하고, 그사이 도착한 값 중 가장 새로운 것만 남깁니다. 탐색, 동기화, 미리보기에.
heading: <code>fxConflate</code>
section: 12
crumb: conflate
prev: onChange.html
prevLabel: onChange
next: shuffle.html
nextLabel: shuffle
---
  <p class="hero-sub">비동기 실행은 한 번에 하나만. 그사이 도착한 것은 가장 새로운 값 하나로 합쳐져 다음에 실행됩니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    비디오 스크러버는 드래그 틱마다 <code>seekTo</code>를 호출하지만, 탐색
    한 번은 틱 하나보다 오래 걸립니다. 하나씩 차례로 await하면 낡은 탐색이
    줄줄이 쌓이고, 한꺼번에 다 실행하면 오래된 것이 마지막에 끝나 이겨
    버립니다. 스크러버가 뜻하는 것은 "손잡이가 <em>지금</em> 있는 곳으로
    가라"이고, <code>fxConflate(run)</code>이 바로 그것입니다. 첫 호출은
    즉시 시작되고, 실행 중에 도착한 호출은 보류되며, 더 새로운 호출이 오면
    그것으로 교체됩니다. 실행이 끝나면 보류된 값 — 가장 새로운 값 — 이
    실행됩니다. 그 사이의 모든 것은 버려집니다.
  </p>
  <p>
    잠잠해지기를 기다리지도 않고(그건
    <a href="debounce.html"><code>fxDebounce</code></a>입니다), 진행 중인
    실행을 버리지도 않습니다(그건 이벤트 레이어의 <code>switchLatest</code>
    입니다) — <code>Future</code>는 취소할 수 없으므로, 정직한 동작은 끝까지
    실행하게 두고 다음으로 넘어가는 것입니다. <code>.isRunning</code>과
    <code>.isPending</code>은 상태를 알려 주고, <code>.idle</code>은 실행 중인
    것도 대기 중인 것도 없을 때 완료되며, <code>.cancel()</code>은 보류된
    값을 버립니다.
  </p>
  <p>
    <code>run</code>이 던진 에러는 <code>onError</code>로, 없으면 현재
    zone으로 가며, 다음 실행을 막지 않습니다 — 실패한 동기화 하나가 그다음
    동기화를 막아서는 안 됩니다. fxdart 확장 기능이며(FxTS에는 없습니다),
    Kotlin Flow의 <code>conflate</code>를 따랐습니다.
  </p>

  <h2>데모 1 · 탐색보다 빠른 스크러버</h2>
  {{playground:0}}

  <h2>데모 2 · 상태, 에러, 그리고 idle</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 첫 번째와 가장 새로운 슬라이더 값만 렌더링해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="debounce.html"><code>fxDebounce</code></a> — 호출이 멈출 때까지 기다리기 ·
    <a href="throttle.html"><code>fxThrottle</code></a> — 구간마다 최대 한 번 ·
    <a href="switchLatest.html"><code>switchLatest</code></a> — 이전 실행을 버리는 스트림 형태 ·
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — 여러 실행을, 한도 안에서
  </div>
