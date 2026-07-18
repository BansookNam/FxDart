---
slug: throwError
title: throwError — FxDart 101
description: FxDart throwError 튜토리얼: 예외를 던지는 동작을 재사용 가능한 단항 함수로 바꾸는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>throwError</code>
section: 10
crumb: throwError
prev: unless.html
prevLabel: unless
next: throwIf.html
nextLabel: throwIf
---
  <p class="hero-sub">항상 예외를 던지는 단항 함수를 반환합니다 — 문장이 아니라 함수를 요구하는 자리를 위해서입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    Dart에서 <code>throw</code>는 문장이라 함수 값을 기대하는 자리에
    그대로 넣을 수 없습니다. <code>throwError(toError)</code>가 이 문제를
    해결합니다. 문제가 된 값으로부터 <code>Object</code>(예외나 에러)를
    만드는 함수를 넘기면, 콜백이 필요한 어디에든 전달할 수 있는
    <code>Never Function(T)</code>를 돌려받습니다. 가장 흔한 쓰임은
    <code>orElse</code> 자리입니다 —
    <a href="cases.html"><code>cases</code></a>에 넘겨서
    "아무것도 일치하지 않음"을 조용한 폴백 대신 확실한 실패로 바꿔 줍니다.
  </p>
  <p>
    반환 타입이 <code>Never</code>이므로 호출하면 언제나 예외가 발생하며,
    <code>T</code> 타입의 값을 실제로 반환하는 일은 없습니다. 에러를
    전파시키지 않고 복구하고 싶다면 호출 지점을
    <code>try</code>/<code>catch</code>로 감싸세요.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · cases의 폴백으로 사용하기</h2>
  <p>
    조용히 흘려보내는 대신, <code>throwError</code>는 일치하지 않은 값을
    눈에 띄고 잡을 수 있는 실패로 만들어 줍니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: "구현되지 않음"을 알리는 예외를 던지는 함수를 만들고 실제로 호출해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="throwIf.html"><code>throwIf</code></a> — 별도의 빌더 함수 없이 조건부로 던집니다 ·
    <a href="cases.html"><code>cases</code></a> — throwError가 orElse로 자리 잡는 곳 ·
    <a href="when.html"><code>when</code></a> / <a href="unless.html"><code>unless</code></a> — 예외를 던지지 않는 조건부 변환 ·
    <a href="find.html"><code>find</code></a> — 일치하는 값이 없으면 예외 대신 null을 반환합니다
  </div>
