---
slug: attempt
title: attempt — FxDart 101
description: FxDart attempt 튜토리얼: Dart 스트림 에러를 타입 있는 Left로 값 채널에 올리고, raiseLefts로 Left를 다시 에러 채널에 내려놓기 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>attempt</code> &amp; <code>raiseLefts</code>
section: 14
crumb: attempt
prev: onErrorResume.html
prevLabel: onErrorResume
next: mapEither.html
nextLabel: mapEither
---
  <p class="hero-sub">실패를 Dart <code>Stream</code>이 가진 두 채널 사이로 옮깁니다. <code>listen(onError:)</code>가 보는 에러 채널, 그리고 <code>Either</code>를 실어 나르는 값 채널.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    이벤트 레이어 자체의 에러 도구 —
    <code><a href="onErrorResume.html">onErrorReturn</a></code>,
    <code>onErrorResume</code>,
    <code><a href="retryOn.html">retryOn</a></code>,
    <code>retryOnError</code> — 는 모두 타입 없는
    <code>Object</code>를 말합니다. 에러 채널이 그것을 나르기
    때문입니다. <code>attempt</code>가 라이브러리의 타입 있는
    절반으로 가는 다리입니다. 데이터 이벤트는 <code>Right</code>가
    되고, 에러 이벤트는 <code>onThrow</code>가 만든
    <code>Left</code>가 됩니다. 실패가 <code>Left</code>가 되면
    컴파일러가 그 타입을 알고, 이벤트 위의
    <code>switch</code>는 처리를 빠뜨릴 수 없습니다.
  </p>
  <p>
    소스 경계에서 변환하고, 그 다음부터는 값 채널에 머무르세요.
    Dart 에러는 종결이 아니므로 소스는 구독을 유지하고 이후
    이벤트도 도착합니다 — <code>onErrorReturn</code>이 한 번의
    구조가 아니라 <em>에러마다</em> 대체하는 것과 같은
    이유입니다. 차이는 결과 타입입니다.
    <code>onErrorReturn</code>은 자리표시자를 골라 <code>T</code>를
    유지하고, <code>attempt</code>는
    <code>Either&lt;E, T&gt;</code>로 바꿔 실패에 이름을 붙입니다.
  </p>
  <p>
    <code>attempt</code>는 <strong>뒤에</strong>
    둡니다. <code>retryOn</code> / <code>retryOnError</code> /
    <code>FxEvents.retry</code> 다음이고, 앞에는 두지 마세요. 그
    연산자들은 에러 채널을 보고, 에러가 이미 값이 되면 재시도할
    것이 남아 있지 않습니다.
  </p>
  <p>
    <code>raiseLefts</code>는 반대 방향이며, Dart가
    <code>throw</code> null을 할 수 없으므로 non-nullable 실패에만
    있습니다. 각 <code>Right</code>를 풀고 각 <code>Left</code>를
    다시 에러 채널에 올려, Dart 에러를 기대하는
    <code>Stream</code> 코드로 넘기는 경계입니다.
    <code>attempt</code> / <code>raiseLefts</code> 왕복은 실패
    값은 남기고 스택 트레이스는 버립니다 —
    <code>Left</code>는 트레이스를 싣지 않습니다.
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
