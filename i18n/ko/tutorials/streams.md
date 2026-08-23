---
slug: streams
title: Stream 브리지 — FxDart 101
description: FxDart의 Stream 브리지 — fromStream, fromStreamLatest, fromStreamChunked, fromStreamNext, fxStream, toStream()으로 Dart Stream을 FxAsyncIterable로 당기는 네 가지 방법. 라이브 플레이그라운드 포함.
heading: Stream 브리지
section: 11
crumb: Stream bridges
next: concurrent.html
nextLabel: concurrent
---
  <p class="hero-sub">fromStream, fxStream, .toStream() — Dart의 Stream과 FxDart의 FxAsyncIterable 사이를 자유롭게 오갑니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>fromStream</code>은 단일 구독이든 브로드캐스트든 어떤
    <code>Stream</code>이라도 <code>FxAsyncIterable</code>로 바꿔 줍니다.
    덕분에 소켓이나 파일, 위젯의 이벤트 스트림 등 Dart가
    <code>Stream</code>으로 건네주는 모든 데이터 위에서 FxDart의 연산자
    전체(<code>map</code>, <code>filter</code>, <code>concurrent</code>, …)를
    쓸 수 있습니다. <code>fxStream(stream)</code>도 같은 일을 하지만,
    날것의 <code>FxAsyncIterable</code> 대신 체이닝 가능한
    <code>FxAsync</code>를 바로 반환합니다 — <code>fx</code>와
    <code>fxAsync</code>에 대응하는 비동기 버전인 셈입니다.
  </p>
  <p>
    반대 방향으로는 <code>.toStream()</code>이
    <code>FxAsyncIterable</code>(또는 <code>FxAsync</code> 체인)을 끝까지
    돌리면서 그 값들을 평범한 <code>Stream</code>으로 다시 내보냅니다 —
    다른 API(예컨대 <code>StreamBuilder</code>)가 이를 요구할 때
    유용합니다. 한 가지 주의할 점은
    <code>toStream()</code>이 언제나 <strong>순차적으로</strong>
    값을 끌어당기며, 상류의 <code>concurrent(n)</code>을 무시한다는
    것입니다 — 병렬 처리가 실제로 일어나길 원한다면
    <code>concurrent</code>나 <code>concurrentPool</code>을 체인에
    <em>먼저</em> 적용한 다음 <code>.toStream()</code>을 호출하세요.
    스트림 변환 자체는 병렬성을 더해 주지 않습니다.
  </p>
  <p>
    푸시에서 풀로 건너오는 것은 연산 하나가 아닙니다 — 넷입니다. 소비자가
    바쁜 동안에도 스트림은 계속 내보낼 수 있기 때문입니다. RxJS 9는 넷을
    <code>iterateEach</code>, <code>iterateLatest</code>,
    <code>iterateBuffered</code>, <code>iterateNext</code>로 부릅니다.
    FxDart는 이를 <code>fromStream*</code>(날것 iterable)과
    <code>FxEvents.pull*</code>(체인)에 대응시킵니다:
  </p>
  <table>
    <thead><tr><th>RxJS 9</th><th>FxDart</th><th>바쁜 동안</th></tr></thead>
    <tbody>
      <tr><td><code>iterateEach</code></td><td><code>fromStream</code> / <code>.pull()</code></td><td>무손실 FIFO — 소스를 일시정지하고 모든 값을 큐에 담음</td></tr>
      <tr><td><code>iterateLatest</code></td><td><code>fromStreamLatest</code> / <code>.pullLatest()</code></td><td>낡은 값 버리기 — 읽히지 않은 최신 값만 유지</td></tr>
      <tr><td><code>iterateBuffered</code></td><td><code>fromStreamChunked</code> / <code>.pullChunked()</code></td><td>배치 — 도착분을 리스트 하나로 내보냄</td></tr>
      <tr><td><code>iterateNext</code></td><td><code>fromStreamNext</code> / <code>.pullNext()</code></td><td>수요 게이트로 버리기 — 기다리는 pull이 없을 때 온 것은 무시</td></tr>
    </tbody>
  </table>
  <p>
    <code>fromStream</code>이 기본값이자 데모 1이 쓰는 것이고, 파일이나
    소켓은 바이트를 잃으면 안 되기 때문입니다. 최신만 쓰는 UI에는
    latest, 묶음으로 일하고 싶으면 chunked, 낡은 이벤트가 공백보다 나쁠
    때는 next를 고르세요.
  </p>

  <h2>데모 1 · fromStream과 fxStream</h2>
  <p>둘 다 <code>Stream.fromIterable</code>을 감싸므로, 기존 스트림을
    FxDart 연산자에 그대로 흘려보낼 수 있습니다.</p>
  {{playground:0}}

  <h2>데모 2 · 유한한 주기 스트림으로 왕복하기</h2>
  <p>
    <code>Stream.periodic</code>은 스스로 끝나지 않으므로
    <code>.take(n)</code>으로 데모를 유한하게 만듭니다. 후반부는 반대
    방향을 보여 줍니다 — <code>FxAsync</code> 체인을 구성한 다음
    <code>.toStream()</code>으로 다시 평범한 <code>Stream</code>으로
    내보내는 것입니다.
  </p>
  {{playground:1}}

  <h2>데모 3 · 스트림을 당기는 네 가지 방법</h2>
  <p>
    이미 pull이 기다리는 동안 1, 2, 3의 동기 버스트가 도착합니다.
    <code>fromStream</code>은 모든 값을 지키고,
    <code>fromStreamLatest</code>는 최신만 지키고,
    <code>fromStreamChunked</code>는 리스트 하나로 내보내고,
    <code>fromStreamNext</code>는 기다리던 pull을 만난 값만 지킵니다.
    이벤트 체인 표기는 <code>.pull()</code>,
    <code>.pullLatest()</code>, <code>.pullChunked()</code>,
    <code>.pullNext()</code>입니다.
  </p>
  {{playground:3}}

  <h2>하나의 Stream, 두 개의 체인</h2>
  <p>
    <code>Stream</code>은 FxDart의 두 세계 모두에 속하는 유일한 소스라서
    getter가 둘 붙습니다. 서로의 변종이 아니라 <strong>모델이 다릅니다</strong>.
  </p>
  <table>
    <thead><tr><th></th><th><code>stream.fx</code></th><th><code>stream.fxEvents</code></th></tr></thead>
    <tbody>
      <tr><td>결과</td><td><code>FxAsync&lt;T&gt;</code></td><td><code>FxEvents&lt;T&gt;</code></td></tr>
      <tr><td>함수 표기</td><td><code>fxStream(stream)</code></td><td><code>fxEvents(stream)</code></td></tr>
      <tr><td>모델</td><td><strong>pull</strong> — 수요에 따라 흐르는 데이터</td><td><strong>push</strong> — 시간 위에 놓인 이벤트</td></tr>
      <tr><td>속도를 정하는 쪽</td><td>소비자 — <code>next()</code> 한 번에 하나</td><td>스트림 — 연산자는 타이밍을 다듬을 뿐</td></tr>
      <tr><td>주로 쓰는 연산자</td><td><code>map</code>, <code>filter</code>, <code>concurrent</code>, <code>toList</code></td><td><code>debounce</code>, <code>throttle</code>, <code>switchMap</code>, <code>combineLatest</code></td></tr>
      <tr><td>배압(backpressure)</td><td>있음 — 요청하기 전에는 당기지 않음</td><td>없음 — 스트림은 나올 때 나옴</td></tr>
    </tbody>
  </table>
  <p>
    고르는 기준은 이렇습니다. 질문이 <em>“한 번에 몇 개씩?”</em>이면 pull
    체인입니다. <code>concurrent(n)</code>은 소비자가 수요를 쥐고 있을 때만
    의미가 있기 때문입니다. 질문이 <em>“얼마나 자주, 그리고 어느 것이
    이기나?”</em>라면 이벤트 체인입니다. 어느 쪽에서 시작하든 건너올 수
    있습니다 —
    <code>.pull()</code> / <code>.pullLatest()</code> /
    <code>.pullChunked()</code> / <code>.pullNext()</code>가
    <code>FxEvents</code>를 pull 체인으로, <code>.toStream()</code>은
    <code>FxAsync</code>를 다시 <code>Stream</code>으로 바꿉니다.
  </p>
  <p>
    자세한 수업: push 체인은
    <a href="fxEvents.html"><code>fxEvents</code></a>, 체인 모델과 getter
    표기는 <a href="fx.html"><code>fx</code></a>, pull 쪽에서만 가능한 일은
    <a href="concurrent.html"><code>concurrent</code></a>에 있습니다.
  </p>

  <h2>직접 해 보기</h2>
  <p>연습: 이 스트림에서 10 이상인 값만 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="toAsync.html"><code>toAsync</code></a> — 스트림 대신 평범한 Iterable을 끌어올리기 ·
    <a href="asyncVariants.html">비동기 변형</a> — *Async 명명 규칙 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 실제 병렬 처리를 원하면 toStream() 이전에 적용 ·
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — 완료 순서 방식의 변형 ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — 푸시 체인; <code>.pull()</code> / <code>.pullLatest()</code> / <code>.pullChunked()</code> / <code>.pullNext()</code>로 되돌아옴
  </div>
