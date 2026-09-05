---
slug: isolateMap
title: isolateMap — FxDart 101
description: FxDart isolateMap2..5 튜토리얼: CPU 단계 2–5개를 보낼 수 있는 워커 하나로 합쳐 parallel이 isolate 홉을 한 번만 내게, 라이브 플레이그라운드와 함께.
heading: <code>isolateMap2..5</code>
section: 11
crumb: isolateMap2..5
prev: parallel.html
prevLabel: parallel
next: debounce.html
nextLabel: debounce
---
  <p class="hero-sub">CPU 단계 2–5개를 보낼 수 있는 워커 하나로 — isolate 홉은 단계마다가 아니라 한 번.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="parallel.html">parallel</a></code>을
    두 번 호출하면 결과가 이 isolate로 돌아왔다가 다시 나갑니다.
    <code>chunk</code>가 줄이려는 바로 그 ~5µs 홉을 두 번 내는 셈입니다.
    <code>isolateMap3(parse, normalise, score)</code>는 세 단계를
    워커 안에서 모두 도는 함수 하나입니다:
  </p>
  <pre><code>await fx(lines)
    .parallel(4, isolateMap3(parse, normalise, score), chunked: true)
    .toList();</code></pre>
  <p>
    각 인자는 보낼 수 있어야 합니다 (top-level이나 static, 또는
    캡처가 모두 보낼 수 있는 클로저). 반환 함수가 그것들을 캡처하고,
    그들이 보낼 수 있으면 이 함수도 그렇습니다. Dart에는 가변
    제네릭이 없어서 헬퍼는 5에서 끝입니다 —
    <code>zipOrAccumulate2..5</code>와 같습니다. 그 이상은 합친
    워커를 직접 쓰세요.
  </p>
  <p>
    <code>parallel</code>은 VM 전용이라, 아래 플레이그라운드는 같은
    합친 워커를 <code>map</code>으로 돌립니다. 결과는 같고, 홉만
    없습니다.
  </p>

  <h2>데모 1 · parse, normalise, score</h2>
  <p>
    단계 세 개, 함수 하나. VM에서는 이것을 <code>parallel</code>에
    넘깁니다. 여기선 플레이그라운드에서 돕니다.
  </p>
  {{playground:0}}

  <h2>데모 2 · 맵 세 번과 같은 숫자</h2>
  <p>
    <code>isolateMap3</code>은 새 연산자가 아니라 합성입니다.
    <code>map</code> 세 번과 합친 워커 하나가 같은 리스트를 찍습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>
    연습: <code>parse</code> → <code>normalise</code> →
    <code>score</code>를 합치고, 점수가 4 이상인 행만 남기세요.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련:</strong>
    <a href="parallel.html"><code>parallel</code></a> — 이 워커가 쓰이는 CPU 풀 ·
    <a href="map.html"><code>map</code></a> — 이 isolate에서의 같은 합성 ·
    <a href="concurrentOrParallel.html">concurrent or parallel</a> — I/O vs CPU ·
    <a href="../parallel-benchmark.html">parallel은 값어치를 하는가?</a> — 홉이 문제가 될 때
  </div>
