---
slug: mapEither
title: mapEither — FxDart 101
description: FxDart mapEither 튜토리얼: 이벤트마다 Raise 스코프를 열어 raise는 Left, 반환은 Right가 되게 하기 — 비동기 쌍둥이까지 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>mapEither</code> &amp; <code>mapEitherAsync</code>
section: 14
crumb: mapEither
prev: attempt.html
prevLabel: attempt
next: separated.html
nextLabel: separated
---
  <p class="hero-sub">이벤트마다 자신의 raise 스코프에서 돌립니다. <code>r.raise</code> (그리고 <code>r.ensure</code> / <code>r.bind</code>)는 <code>Left</code>가 되고, 평범한 반환은 <code>Right</code>가 됩니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="attempt.html">attempt</a></code>는 경계
    변환입니다 — 이미 에러 채널에 있는 것을
    <code>Left</code>로 바꿉니다. <code>mapEither</code>는 그
    <em>다음</em>에, 또는 깨끗한 소스에서 쓰는 연산자입니다. 각
    이벤트가 <code><a href="raise.html">either</a></code> 빌더
    안에서 돌아가므로 <code>r.ensure</code> /
    <code>r.raise</code>로 일직선 Dart를 쓰고, 맵 전체의 결과는
    <code>Either&lt;E, R&gt;</code>입니다. 실패한 이벤트가 소스를
    취소하지 않으며, 이후 이벤트도 도착합니다.
  </p>
  <p>
    <em>던져진</em> 예외는 에러 채널에 남습니다 — 그것이
    <code>either</code> 빌더의 계약이고,
    <code>attempt</code>가 throw를 값으로 바꾸는 단 한 곳입니다.
    콜백이 raise도 하고 throw도 하면
    <code>mapEither</code> 안에서 <code>eitherCatching</code>을
    써서 <code>Either</code> 하나가 나오게 하세요.
  </p>
  <p>
    <code>mapEitherAsync</code>는 비동기 쌍둥이입니다.
    <code>asyncMap</code>처럼 한 번에 이벤트 하나.
    <code>eitherAsync</code>의 규칙이 그대로 옵니다. raise는
    await된 체인 안에서 일어나야 합니다. await되지 않은
    future에서의 raise는 스코프보다 오래 살아남아
    <code>Left</code>가 아니라 처리되지 않은 존 에러가 됩니다.
  </p>
  <p>
    소스 에러는 두 연산자 모두 손대지 않고 통과합니다. 그것도
    <code>Left</code>로 만들고 싶으면 위쪽에
    <code>attempt</code>를 두세요.
  </p>

  <h2>데모 1 · raise는 Left, 반환은 Right</h2>
  {{playground:0}}

  <h2>데모 2 · mapEitherAsync, 한 번에 하나</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>
    연습: 던져진 예외는 에러 채널에 남고, 체인은 그 뒤를
    계속 갑니다.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="attempt.html"><code>attempt</code></a> — throw를 <code>Left</code>로 바꾸는 경계 ·
    <a href="raise.html"><code>either</code> 빌더</a> — 같은 raise 스코프, 값 하나에서 ·
    <a href="separated.html"><code>rights</code> / <code>separated</code></a> — 나온 <code>Either</code>를 가르기
  </div>
