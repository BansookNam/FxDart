---
slug: parallel
title: parallel — FxDart 101
description: FxDart parallel 튜토리얼: concurrent의 CPU 짝 — isolate 풀, 보낼 수 있는 top-level 워커, 순서 유지. VM과 Flutter만.
heading: <code>parallel</code>
section: 11
crumb: parallel
prev: concurrentOrParallel.html
prevLabel: concurrent or parallel
next: debounce.html
nextLabel: debounce
---
  <p class="hero-sub">CPU 일을 isolate들에 겹칩니다, 소스 순서로. 이름만 다른 <code>concurrent</code>가 아닙니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="concurrent.html">concurrent(n)</a></code>은 같은
    isolate 위의 <code>Future</code>를 겹칩니다 — I/O. Dart의 CPU 이야기는
    isolate입니다. <code>parallel(n, worker)</code>가 그 짝입니다:
    <strong>재사용 풀</strong> <code>n</code>개 isolate, 결과는 소스
    순서, <code><a href="mapConcurrent.html">mapConcurrent</a></code>가
    map-plus-concurrent의 결합형인 것과 같습니다. 같은 연산자가
    아닙니다 — 비교는
    <a href="concurrentOrParallel.html">concurrent or parallel</a>에
    있습니다.
  </p>
  <p>
    top-level 또는 static 함수를 쓰세요. 보낼 수 없는 것
    (<code>ReceivePort</code>, 열린 소켓)을 캡처한 클로저는 spawn에서
    <code>ArgumentError</code>를 던집니다 — isolate의 계약이지 fxdart가
    만든 규칙이 아닙니다. 보낼 수 없는 입력이나 결과도 그 풀을
    멈추지 않고 같은 방식으로 실패합니다. 웹에서는
    <code>UnsupportedError</code> — 거기서는
    <code>concurrent(n)</code>을 쓰세요. 아래 프로그램은 VM 전용이며
    라이브 플레이그라운드가 아닙니다.
  </p>
  <p>
    <code>n</code>을 고르기 싫다면 <code>parallelWorkers</code>가 VM의
    프로세서 수입니다 — 첫 인자로 넘기면 됩니다.
    <code>n</code>보다 짧은 <code>List</code>는 풀을 리스트 길이에
    맞춥니다. 원소가 두 개인데 <code>parallel(8, w)</code>하면 isolate는
    여덟 개가 아니라 두 개입니다.
    <code>mapConcurrent</code>에서 온 사람은 <code>mapParallel</code>을
    쓸 수 있습니다. 같은 연산입니다.
  </p>
  <pre><code>int timesTen(int x) =&gt; x * 10;

Future&lt;void&gt; main() async {
  print(await fx([1, 2, 3, 4]).parallel(2, timesTen).toList());
  // [10, 20, 30, 40]
}</code></pre>

  <div class="callout">
    <strong>관련:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — I/O, 아무 클로저 ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — 결합된 I/O 형태 ·
    <a href="concurrentOrParallel.html">concurrent or parallel</a> — I/O vs CPU ·
    <code>mapParallel</code> — <code>parallel</code>과 같은 연산
  </div>
