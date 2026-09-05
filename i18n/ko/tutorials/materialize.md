---
slug: materialize
title: materialize — FxDart 101
description: FxDart materialize 튜토리얼: StreamEvent(Next, Err, Done), materialize, dematerialize, timestamped, intervals, partition, sequenceEqual — 이벤트 터미널과 pull의 sequenceEqual / sequenceEqualAsync — 을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>materialize</code>, <code>timestamped</code>, <code>sequenceEqual</code>
section: 14
crumb: materialize
prev: fxSubscriptions.html
prevLabel: FxSubscriptions
next: job-search.html
nextLabel: debounced search
---
  <p class="hero-sub">알림을 <code>Next</code> / <code>Err</code> / <code>Done</code>으로 재화하고, 이벤트에 시각을 찍고, 두 수열이 같은지 묻습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    Dart <code>Stream</code>의 세 종단 — 값, 에러, 닫힘 — 은 보통
    파이프를 떠납니다. <code>materialize</code>는 각각을
    <code>StreamEvent</code> 값으로 바꿔 체인을
    <em>통과할 수</em> 있게 합니다: 데이터 이벤트는
    <code>Next(value)</code>가 되고, 에러는 <code>Err</code>가 된 뒤
    결과가 <strong>완료됩니다</strong> — 에러를 내지 않습니다 — 그리고
    닫힘은 <code>Done</code>이 된 뒤 결과가 완료됩니다. 재화하는
    이유입니다: <code>toList</code>가 실패하는 대신 에러를 모을 수 있고,
    로그가 <code>Err(boom)</code>을 <code>Next(1)</code> 옆에 찍을 수
    있고, 테스트가 정확한 알림 수열을 단언할 수 있습니다.
    <code>dematerialize</code>는 역입니다 — <code>Next</code>는 값이
    되고, <code>Err</code>는 <code>Stream.addError</code>가 되고,
    <code>Done</code>은 결과를 닫고, <code>Done</code> 이후는
    무시됩니다. 왕복: <code>materialize().dematerialize()</code>는 원래
    값의 스트림입니다. fxdart 이벤트 레이어, Rx의
    <code>materialize</code> / <code>dematerialize</code>를 따랐습니다.
  </p>
  <p>
    시간은 알림이 실을 수 있는 다른 메타데이터입니다.
    <code>timestamped</code>는 각 이벤트를 도착한 벽시계 시각과
    짝짓고 (<code>(DateTime at, T value)</code>),
    <code>intervals</code>는 이전 이벤트 이후의 시간과 짝짓습니다
    (<code>(Duration dt, T value)</code>). 첫 이벤트의 dt는 언제나
    <code>Duration.zero</code>입니다. 둘 다 <code>now:</code>를 받으므로
    테스트가 가짜 시계 — <code>now: () =&gt; DateTime.utc(2020)</code>
    — 를 <code>DateTime.now</code> 대신 넘길 수 있습니다. 에러와 닫힘은
    그대로 통과합니다. Rx의 <code>timestamp</code>와
    <code>timeInterval</code>을 따랐습니다.
  </p>
  <p>
    이벤트의 <code>partition(test)</code>는 풀 쪽
    <code><a href="partition.html">partition</a></code>이 아닙니다 (그건
    한 번 걸으며 리스트 둘을 돌려줍니다). 살아 있는 체인 하나를
    <code>(matches, rest)</code>로 나누되 소스 <strong>한</strong> 번의
    실행을 공유합니다. 레코드는 즉시 반환되고, 어느 쪽이든 듣기 시작하면
    소스가 시작되며, 아무도 듣지 않는 쪽에 속하는 값은 버퍼에 담기지
    않고 버려집니다. 양쪽 반쪽을 모두 원하면 소스가 발화하기 전에 둘 다
    들으세요.
  </p>
  <p>
    <code>sequenceEqual</code>은 두 수열이 같은 값을 같은 순서로 담고
    함께 끝나는지 묻습니다. 이벤트 레이어에서는 터미널입니다:
    <code>fxEvents(a).sequenceEqual(b)</code>는
    <code>Future&lt;bool&gt;</code>을 돌려주고, 첫 값 또는 길이 불일치에서
    false이며, 어느 쪽의 에러든 퓨처를 실패시킵니다. 같은 질문이 pull에도
    있습니다: iterable에는 <code>sequenceEqual</code> /
    <code>Fx.sequenceEqual</code>,
    <code>sequenceEqualAsync</code> /
    <code>FxAsync.sequenceEqual</code>는
    <code>FxAsyncIterable</code>용입니다. Rx의
    <code>sequenceEqual</code>을 따랐습니다.
  </p>

  <h2>데모 1 · Next, Err, Done</h2>
  <p>
    깨끗한 닫힘은 <code>Done</code>이 됩니다. 에러는 <code>Err</code>가
    된 뒤 체인이 완료되므로, <code>toList</code>는 실패하는 대신
    <code>StreamEvent</code> 리스트를 돌려줍니다:
  </p>
  {{playground:0}}

  <h2>데모 2 · 넘길 수 있는 시계</h2>
  <p>
    <code>now: () =&gt; DateTime.utc(2020)</code>가 스탬프를 결정적으로
    만듭니다. <code>intervals</code>도 같은 훅을 쓰며, 간격이 정확하도록
    한 칸씩 나아가는 시계를 넘깁니다:
  </p>
  {{playground:1}}

  <h2>데모 3 · sequenceEqual, 그리고 partition</h2>
  <p>
    pull 표기는 그저 <code>fx([1, 2]).sequenceEqual([1, 2])</code>입니다.
    이벤트 터미널은 <code>Stream</code>을 받습니다.
    <code>partition</code>의 양쪽을 소스가 돌기 전에 들으세요. 듣지 않은
    반쪽은 버려집니다:
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="fxEvents.html"><code>fxEvents</code></a> — 이 연산자들이 앉는 체인 ·
    <a href="streams.html">Stream 브리지</a> — <code>Stream</code>을 <code>FxAsync</code>로 당기는 네 가지 방법 ·
    <a href="partition.html"><code>partition</code></a> — 한 번의 순회로 리스트 둘을 얻는 풀 쪽 원본 ·
    <a href="fxSubscriptions.html"><code>FxSubscriptions</code></a> — 리스너 자루를 함께 취소
  </div>
