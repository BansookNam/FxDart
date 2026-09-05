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
    워커는 <code>Future</code>를 반환해도 됩니다
    (<code>FutureOr</code>, <code>mapConcurrent</code>와 같은 모양) —
    동기 콜백은 여전히 빠른 경로입니다. 비동기 워커 안의 중첩
    <code>parallel</code>도 됩니다: 그 isolate가 자기 풀을 띄우고,
    바깥 체인을 cancel하면 안쪽 풀을 먼저 걷습니다. 중첩은 한 단계가
    계약입니다 — 세 번째 중첩 <code>parallel</code>은 부모와 함께
    죽으므로, <em>자기</em> 자식 풀을 걷을 기회가 없습니다.
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

  <h2><code>chunk</code> — 메시지 하나에 원소 몇 개를 실을지</h2>
  <p>
    기본값에서는 원소마다 하나씩 따로 워커로 건너갑니다. 그 왕복 비용이
    약 <strong>5µs</strong>인데, 이는 웬만한 콜백보다 비쌉니다. 값싼
    워커가 평범한 반복문보다 <em>느려지는</em> 것도,
    <code>parallel</code>을 쓰고도 손해를 보는 것도 전부 이 때문입니다.
    <code>chunk: k</code>는 그 비용을 원소 <code>k</code>개당 한 번만
    냅니다.
  </p>
  <pre><code>// 원소 20,000개, 각각 약 0.4µs의 일, 워커 4개:
await fx(rows).parallel(4, parseRow).toList();             // 약 142ms
await fx(rows).parallel(4, parseRow, chunk: 512).toList(); //   약 3ms

// 같은 일을 isolate 없이 평범한 반복문으로:               //   약 8ms</code></pre>
  <p>
    이 모양에서 47배이고, 배치 형태가 되어서야 비로소 대체하려던 그
    반복문을 실제로 이깁니다. <code>k</code>는
    <code>k × 콜백</code>이 5µs를 넉넉히 넘도록, 그러면서도 워커마다
    배치가 여러 개는 돌아가도록 잡으세요.
    <code>length ~/ (workers * 4)</code>가 무난한 출발점입니다.
  </p>
  <p>
    배치는 관찰되는 동작을 바꾸지 않습니다. 순서도 그대로, 백프레셔도
    그대로이고, 워커가 던져도 그 <em>앞</em> 원소들의 결과는 그대로
    나온 뒤 실제로 실패한 원소에서 raise합니다. 바뀌는 것은 두 가지입니다.
    첫 원소가 자기 배치 전체를 기다리게 되므로 <code>take(1)</code>에는
    작은 <code>chunk</code>를 쓰거나 아예 쓰지 마세요. 그리고 보낼 수 없는
    <em>입력</em>이나 <em>결과</em>는 자기 pull 하나가 아니라 배치 전체를 실패시킵니다 —
    어느 원소가 문제인지 알아내려면 하나씩 보내야 하는데, 그것이 바로
    배치가 피하려는 비용이기 때문입니다.
  </p>
  <p>
    <code>chunk: n ~/ (workers * 4)</code>를 적고 워커 수를 두 번
    쓰기 싫다면 <code>chunked: true</code>가 소스 길이에서 그렇게
    잡습니다:
  </p>
  <pre><code>await fx(rows).parallel(4, parseRow, chunked: true);
// k = rows.length ~/ 16 — 4가 한 번, 두 번이 아님</code></pre>
  <p>
    소스는 <code>List</code>여야 합니다. generator나 async 소스에는
    길이가 없습니다 — <code>chunk: k</code>를 넘기세요.
    <code>chunk:</code>와 <code>chunked:</code>를 같이 쓰면 던집니다.
    호출에는 정책이 하나입니다.
  </p>

  <h2>CPU 단계 두 개, 홉은 한 번</h2>
  <p>
    <code>.parallel</code>을 두 번 호출하면 결과가 이 isolate로
    돌아왔다가 다시 나갑니다. <code>isolateMap2</code>로 워커를
    합치면 두 단계가 워커 안에서 돕니다:
  </p>
  <pre><code>await fx(blobs)
    .parallel(4, isolateMap2(decodePng, thumbnail), chunk: 64)
    .toList();</code></pre>
  <p>
    <code>decodePng</code>와 <code>thumbnail</code>은 다른
    <code>parallel</code> 워커와 같이 보낼 수 있어야 합니다. 반환
    함수가 둘을 캡처합니다.
  </p>

  <h2>풀을 재사용하기</h2>
  <p>
    <code>parallel</code>은 첫 pull에서 spawn하고 그 체인이 끝나면
    isolate를 죽입니다. 일이 두 번이면 시작 비용을 두 번 냅니다.
    <code>IsolatePool</code>이 한 번 spawn하는 괄호입니다.
    <code>IsolatePool.using</code>은 body가 던져도
    <code>finally</code>에서 죽입니다. 한
    <code>parallelOn</code> 체인을 cancel해도 풀은 살아 있고, 다음
    체인이 쓸 수 있습니다.
  </p>
  <pre><code>await IsolatePool.using(4, (pool) async {
  final a = await fx(batchA).parallelOn(pool, parseRow, chunk: 256).toList();
  final b = await fx(batchB).parallelOn(pool, parseRow, chunk: 256).toList();
  return (a, b);
});</code></pre>

  <div class="callout">
    <strong>관련:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — I/O, 아무 클로저 ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — 결합된 I/O 형태 ·
    <a href="concurrentOrParallel.html">concurrent or parallel</a> — I/O vs CPU ·
    <code>mapParallel</code> — <code>parallel</code>과 같은 연산 ·
    <a href="../parallel-benchmark.html">parallel은 값어치를 하는가?</a> — 같은 작업 다섯 가지 방법, 측정
  </div>
