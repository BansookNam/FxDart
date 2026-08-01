---
slug: raise
title: either 빌더 &amp; Raise 스코프 — FxDart 101
description: FxDart raise 튜토리얼: either와 eitherAsync 빌더, 그리고 Raise 스코프의 어휘 — bind, ensure, ensureNotNull, recover, withError, raise.
heading: <code>either</code> 빌더 &amp; <code>Raise</code> 스코프
section: 13
crumb: either &amp; Raise
prev: either.html
prevLabel: Either
next: nullable.html
nextLabel: nullable
---
  <p class="hero-sub">
    블록을 <code>Raise&lt;E&gt;</code> 스코프 안에서 실행합니다: 타입 있는
    에러로 단락할 수 있는 일직선 코드입니다. raise된 <code>E</code>는
    <code>Left</code>가 되고, 정상 반환은 <code>Right</code>가 됩니다.
  </p>

  {{signature}}

  <h2>강의</h2>
  <p>
    빌더는 여러분의 블록에 스코프 <code>r</code>을 건네줍니다 — Kotlin
    Arrow의 <code>either&nbsp;{&nbsp;}</code>를 이식한 것입니다. 모든 것이
    여기에 달려 있습니다. <code>r.</code>을 입력하면 어휘 전체를 발견할 수
    있습니다:
  </p>
  <ul>
    <li><code>r.bind(either)</code> / <code>r.bindAll(eithers)</code> —
      성공 값을 풀어내거나, 실패와 함께 단락합니다.</li>
    <li><code>r.ensure(cond, () => err)</code> — 타입 있는 에러 버전의
      <code>require</code>.</li>
    <li><code>r.ensureNotNull(x, () => err)</code> — non-null을 반환하며,
      타입 승격이 일어납니다.</li>
    <li><code>r.recover(block, onRaise)</code> — 중첩 스코프에서 raise된
      에러를 처리하고 계속 진행합니다.</li>
    <li><code>r.withError(transform, block)</code> — <em>다른</em> 에러
      타입을 이 스코프에 맞게 변환합니다.</li>
    <li><code>r.raise(err)</code> — 곧바로 단락합니다.
      <code>Never</code>를 반환하므로 실행이 거기서 멈춘다는 사실을 흐름
      분석도 알고 있습니다.</li>
  </ul>
  <p>
    내부 구현은 <code>flatMap</code> 연쇄가 <em>아닙니다</em>. 실패한
    <code>bind</code>는 스코프 토큰이 달린 비공개 신호를 던지고, 빌더가
    자신의 경계에서 그것을 잡아냅니다. 그래서 이른 반환, 반복문,
    <code>if</code>가 블록 안에서 전부 그대로 동작하고, 중첩된 빌더가 서로의
    에러를 가로채는 일도 없습니다. <code>eitherAsync</code>는 비동기
    쌍둥이입니다 — 어휘는 같고 <code>await</code>도 쓸 수 있습니다(raise는
    같은 await 체인 안에서만).
  </p>

  <h2>데모 1 · ensure &amp; ensureNotNull</h2>
  {{playground:0}}

  <h2>데모 2 · bind — flatMap 피라미드를 끝내는 무기</h2>
  {{playground:1}}

  <h2>데모 3 · recover, withError &amp; raise</h2>
  {{playground:2}}

  <h2>데모 4 · eitherCatching — 예외 경계를 미리 결합한 빌더</h2>
  <p>
    실제 파싱은 두 갈래로 동시에 실패합니다. 우리가 정한 규칙은 타입 있는
    오류를 <em>raise</em>하고, 플랫폼(<code>int.parse</code>,
    <code>jsonDecode</code>)은 <em>throw</em>합니다.
    <code>eitherCatching</code>은 <code>either</code> +
    <code>catching</code>을 하나로 합친 빌더입니다 — 블록은 raise하거나
    throw할 수 있고, 두 번째 인자가 던져진 예외를 같은 타입의 오류로
    변환합니다. raise 시그널 자체는 절대 여기에 전달되지 않습니다.
    <code>recover</code>도 같은 선택적 <code>onThrow:</code> 절을 받아
    Arrow&nbsp;2.x의 3절짜리 <code>recover(block, recover, catch)</code>를
    완성합니다.
  </p>
  {{playground:4}}

  <h2>직접 해 보기</h2>
  <p>
    연습: <code>checkAge</code>가 예외를 던지는 대신 타입 있는 에러로
    실패하도록 만들어 보세요 — 파싱에는 <code>ensureNotNull</code>을, 나이
    제한에는 <code>ensure</code>를 쓰면 됩니다.
  </p>
  {{playground:3}}

  <div class="callout">
    <strong>규칙 두 가지.</strong> (1) raise 블록에서 <em>지연</em>
    파이프라인을 그대로 반환하지 마세요 — 블록 안에서
    <code>toList()</code>로 구체화하거나
    <a href="eitherPipelines.html">즉시 실행 Either 종결 연산자</a>를
    사용하세요. 지연된 raise는 <code>RaiseLeakedError</code>로 요란하게
    실패합니다. (2) raise 블록 안에서 맨몸 <code>catch</code>를 쓰지
    마세요 — 단락 신호를 항상 통과시키는
    <code>catching</code>/<code>catchingAsync</code>를 사용하세요.
  </div>

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="either.html"><code>Either</code></a> — 경계 타입 ·
    <a href="nullable.html"><code>nullable</code></a> — <code>T?</code>를 돌려주는 정보 없는 쌍둥이 ·
    <a href="accumulate.html">에러 누적</a> — 모든 실패를 모읍니다 ·
    <a href="typedErrors.html">타입 있는 에러 — 전체 가이드</a>
  </div>
