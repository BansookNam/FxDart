---
slug: attempt
title: attempt — FxDart 101
description: FxDart attempt 튜토리얼: Dart 스트림 에러를 타입 있는 Left로 값 채널에 올리고, raiseLefts로 Left를 다시 에러 채널에 내려놓는 법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>attempt</code> &amp; <code>raiseLefts</code>
section: 14
crumb: attempt
prev: onErrorResume.html
prevLabel: onErrorResume
next: mapEither.html
nextLabel: mapEither
---
  <p class="hero-sub">실패를 Dart <code>Stream</code>의 두 채널 사이로 옮깁니다. 하나는 <code>listen(onError:)</code>가 보는 에러 채널이고, 다른 하나는 <code>Either</code>를 실어 나르는 값 채널입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    이벤트 레이어의 에러 도구(<code><a href="onErrorResume.html">onErrorReturn</a></code>,
    <code>onErrorResume</code>, <code><a href="retryOn.html">retryOn</a></code>,
    <code>retryOnError</code>)는 모두 타입 없는 <code>Object</code>를 다룹니다.
    에러 채널이 <code>Object</code>를 싣기 때문입니다. <code>attempt</code>는
    라이브러리의 타입 있는 영역으로 건너가는 다리입니다. 데이터 이벤트는
    <code>Right</code>가 되고, 에러 이벤트는 <code>onThrow</code>가 만든
    <code>Left</code>가 됩니다. 실패가 <code>Left</code>가 되면 컴파일러가 그
    타입을 알기 때문에, 이벤트에 대한 <code>switch</code>에서 처리를 빠뜨릴 수
    없습니다.
  </p>
  <p>
    소스 경계에서 변환하고, 그다음부터는 값 채널에 머무르세요. Dart 에러는
    스트림을 끝내지 않으므로 소스는 구독을 유지하고 이후 이벤트도 계속
    도착합니다. <code>onErrorReturn</code>이 한 번만 복구하는 게 아니라
    <em>에러마다</em> 대체하는 것도 같은 이유입니다. 차이는 결과 타입입니다.
    <code>onErrorReturn</code>은 자리표시자를 골라 <code>T</code>를 유지하고,
    <code>attempt</code>는 <code>Either&lt;E, T&gt;</code>로 바꿔 실패에 이름을
    붙입니다.
  </p>
  <p>
    <code>attempt</code>는 <code>retryOn</code> / <code>retryOnError</code> /
    <code>FxEvents.retry</code> <strong>뒤에</strong> 두세요. 앞에 두면 안 됩니다.
    이 연산자들은 에러 채널을 보는데, 에러가 이미 값이 되어 버리면 재시도할
    대상이 남지 않기 때문입니다.
  </p>
  <p>
    <code>raiseLefts</code>는 반대 방향입니다. Dart는 <code>throw</code>로 null을
    던질 수 없으므로 non-nullable 실패에만 쓸 수 있습니다. 각 <code>Right</code>는
    풀고 각 <code>Left</code>는 다시 에러 채널에 올립니다. Dart 에러를 기대하는
    <code>Stream</code> 기반 코드에 스트림을 넘기는 경계에서 쓰면 됩니다.
    <code>attempt</code>와 <code>raiseLefts</code>를 왕복하면 실패 값은 남지만
    스택 트레이스는 사라집니다. <code>Left</code>에는 트레이스가 없기 때문입니다.
  </p>

  <h2>데모 1 · 에러는 Left가 되고, 체인은 계속 갑니다</h2>
  {{playground:0}}

  <h2>데모 2 · raiseLefts, 반대 방향</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>
    연습: retry 뒤의 <code>attempt</code>는 재시도된 실패를
    변환하고, retry 앞의 <code>attempt</code>는 에러 채널에
    재시도할 것을 남기지 않습니다.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="onErrorResume.html"><code>onErrorReturn</code> / <code>onErrorResume</code></a> — 에러 채널에서, 타입 없이 복구하기 ·
    <a href="mapEither.html"><code>mapEither</code></a> — 값 채널에 머무르기; raise는 <code>Left</code>가 됩니다 ·
    <a href="either.html"><code>Either</code></a> — 이 연산자들이 감싸는 sealed 결과 타입
  </div>
