---
slug: concurrentOrParallel
title: concurrent 또는 parallel — FxDart 101
description: FxDart concurrent 또는 parallel 튜토리얼: 이 isolate에서 Future를 겹칠 때와, CPU 일을 isolate 풀로 보낼 때.
heading: concurrent 또는 parallel
section: 11
crumb: concurrent or parallel
prev: using.html
prevLabel: using
next: parallel.html
nextLabel: parallel
---
  <p class="hero-sub">일을 겹치는 두 가지 방법입니다. 이름만 다른 같은 연산자가 아닙니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="concurrent.html">concurrent(n)</a></code>은
    <code>Future</code>를 <em>이</em> isolate 위에서 겹칩니다 — I/O, 기다림.
    <code><a href="parallel.html">parallel(n, worker)</a></code>은
    CPU 일을 <em>다른</em> isolate들에 겹칩니다. 콜백이 시간을 어디에
    쓰는지로 고르세요. "더 빠르게" 하고 싶은 양이 아닙니다.
  </p>
  <table>
    <tr><th></th><th><code>concurrent(n)</code></th><th><code>parallel(n)</code></th></tr>
    <tr><td>겹치는 것</td><td>이 isolate의 <code>Future</code></td><td>워커 isolate</td></tr>
    <tr><td>콜백</td><td>아무 클로저</td><td>top-level 또는 static 함수</td></tr>
    <tr><td>값</td><td>무엇이든</td><td>보낼 수 있는 것</td></tr>
    <tr><td>플랫폼</td><td>VM, Flutter, web</td><td>VM / Flutter만</td></tr>
    <tr><td>싼 일 (<code>x + 1</code>, <code>Future.delayed(0)</code>)</td><td>마커뿐, hop이 싸다</td><td>원소마다 isolate 메시지 — 대개 손해</td></tr>
    <tr><td>맞는 일</td><td>HTTP, DB, 파일, <code>await</code></td><td>JSON 파싱, 이미지, 암호화, tight loop</td></tr>
  </table>
  <p>
    I/O는 대부분 기다림입니다. 요청이 떠 있는 동안 isolate는 쉬고
    있으므로 <code>concurrent(4)</code>로 <code>Future</code> 네 개를
    겹치면 벽시계가 줄고, 다른 isolate는 필요 없습니다. CPU 일이
    <em>곧</em> isolate입니다. 반환할 때까지 이벤트 루프(그리고 Flutter
    프레임)를 막습니다. 그때 쓰는 것이 <code>parallel</code>입니다.
  </p>
  <p>
    isolate hop은 공짜가 아닙니다. 각 원소를 직렬화하고, 보내고, 돌리고,
    다시 직렬화하고, 순서를 맞춥니다. 본문이 <code>x + 1</code>인
    콜백은 덧셈보다 hop에 더 오래 걸립니다. 워커를 네 개로 늘리면
    <em>더 느려집니다</em>. 거둘 CPU는 없는데 택배비는 네 배입니다.
    측정: <code>x + 1</code> 천 개는 워커 네 개가 하나보다 약 두 배
    걸렸고, 20000번 tight loop는 워커 네 개가 하나보다 약 두 배
    <em>빨랐습니다</em>. 일이 hop보다 무겁지 않으면 이 isolate에
    남으세요.
  </p>
  <pre><code>// I/O — overlap Futures here
fx(ids).mapConcurrent(8, fetchUser);

// CPU — only when the body is heavy enough
fx(blobs).parallel(parallelWorkers, parseJson);

// This is a loss. The hop is bigger than the work.
fx(nums).parallel(4, (x) =&gt; x + 1);</code></pre>

  <div class="callout">
    <strong>관련:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — I/O, 아무 클로저 ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — 결합된 I/O 형태 ·
    <a href="parallel.html"><code>parallel</code></a> — CPU, 보낼 수 있는 워커 ·
    <a href="parallel.html"><code>mapParallel</code></a> — <code>parallel</code>의 별칭
  </div>
