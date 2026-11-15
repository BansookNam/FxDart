---
slug: foldRaise
title: foldRaise — FxDart 101
description: FxDart foldRaise 튜토리얼 — fxEither와 fxNullable 밑에 있는 기본 연산. Raise 블록을 실행하고 값, raise된 에러, 던져진 예외라는 세 가지 결과를 접습니다.
heading: <code>fxFoldRaise</code>
section: 13
crumb: foldRaise
prev: raise.html
prevLabel: either &amp; Raise
next: nullable.html
nextLabel: nullable
---
  <p class="hero-sub">
    블록을 새 <code>Raise&lt;E&gt;</code> 스코프에서 실행하고, 무슨 일이
    일어나든 — 값이든, raise된 에러든, 던져진 예외든 — 하나의 결과 타입으로
    접습니다.
  </p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="raise.html">fxEither</a></code>는 raise 블록을
    <code>Either</code>로, <code><a href="nullable.html">fxNullable</a></code>은
    <code>T?</code>로 바꿉니다. 둘 다 <code>fxFoldRaise</code> 한 번의
    호출이며, 이것이 모든 빌더가 파생되는 단 하나의 기본 연산입니다 — Arrow의
    <code>fold</code>를 이식한 것입니다. 새 스코프 <code>r</code>로
    <code>block</code>을 실행하고, 블록이 어떻게 끝났는지에 따라 분기합니다:
  </p>
  <ul>
    <li>정상 반환 → <code>onValue(value)</code>;</li>
    <li><code>r.raise(e)</code>(<em>이</em> 스코프에서) →
      <code>onRaise(e)</code>;</li>
    <li>던져진 예외 → <code>onThrow(thrown, stackTrace)</code>를 주었다면
      그것으로, 아니면 다시 던집니다;</li>
    <li><em>다른</em> 스코프의 raise → 손대지 않고 다시 던지므로, 그것이
      속한 빌더에 도착합니다. 동적 스코핑 없이도 중첩 스코프가 올바르게
      동작하는 이유가 이것입니다.</li>
  </ul>
  <p>
    경계에서 원하는 모양이 <code>Either</code>도 <code>T?</code>도 아닐 때
    — 상태 문자열, HTTP 응답, 레코드, 직접 만든 sealed 타입 — 그리고
    그렇지 않으면 바로 다음 줄에서 <code>switch</code>하려고
    <code>Either</code>를 만들게 될 때 쓰세요. 나만의 빌더를 작성하는 방법도
    이것입니다. <code>fxEither</code>는 <code>Left</code>를 만드는
    <code>onRaise</code>와 <code>Right</code>를 만드는
    <code>onValue</code>를 준 <code>fxFoldRaise</code>일 뿐, 그 이상은
    없습니다. <code>onThrow</code>는 <code>fxEitherCatching</code>과
    <code>r.recover</code>가 넘겨주는 세 절 형태이며, raise 신호 자체는
    결코 여기에 전달되지 않습니다.
  </p>
  <p>
    <code>fxFoldRaiseAsync</code>는 비동기 쌍둥이입니다. 블록과 모든
    핸들러가 await할 수 있고, <code>fxEitherAsync</code>와 같은 규칙 —
    raise는 await 체인 안에서만 — 이 적용됩니다. 접기가 반환되면 스코프가
    닫히므로, 나중에 raise할 지연 파이프라인은 블록 안에서 구체화해야
    합니다. <code>fxFoldRaise</code>라는 이름은
    <code><a href="fold.html">fxFold</a></code>가 이미 있어서 붙었습니다.
  </p>

  <h2>데모 1 · 세 가지 결과, 하나의 결과 타입</h2>
  {{playground:0}}

  <h2>데모 2 · 나만의 빌더, 중첩 &amp; 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>
    연습: 중간의 <code>Either</code>를 건너뛰고 스코프를 곧바로 메시지로
    접어 보세요.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="raise.html"><code>fxEither</code> &amp; <code>Raise</code> 스코프</a> — 이것 위에 만든 빌더 ·
    <a href="nullable.html"><code>fxNullable</code></a> — 정보 없는 빌더, 역시 접기 한 번 ·
    <a href="either.html"><code>Either</code></a> — 이미 가진 값에 대한 <code>fold</code> ·
    <a href="typedErrors.html">타입 있는 에러 — 전체 가이드</a>
  </div>
