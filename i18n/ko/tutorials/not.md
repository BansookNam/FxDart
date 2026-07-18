---
slug: not
title: not — FxDart 101
description: FxDart not 튜토리얼: 불리언 부정을 그대로 넘길 수 있는 함수 값으로 다루는 방법을 라이브 플레이그라운드와 함께 알아봅니다.
heading: <code>not</code>
section: 10
crumb: not
prev: negate.html
prevLabel: negate
next: when.html
nextLabel: when
---
  <p class="hero-sub">그대로 넘길 수 있는 함수 형태의 불리언 부정입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>not</code>이 하는 일은 <code>!a</code>와 똑같습니다 — 다만 그것을
    일급 함수로 제공하므로, <code>(b) =&gt; !b</code>를 직접 쓰는 대신
    <code>bool Function(bool)</code>이 필요한 자리에 그대로 넘길 수 있습니다.
    FxTS의 <code>not</code>은 타입을 가리지 않고 JavaScript의 "truthy" 값에
    동작하지만, Dart에는 암묵적 truthiness가 없으므로 Dart 포팅판은
    실제 <code>bool</code>만 받습니다.
  </p>
  <p>
    시그니처가 <code>bool -&gt; bool</code>이기 때문에, 원소 타입이 이미
    <code>bool</code>인 곳에서는 <code>not</code> 자체가 술어 역할도 합니다 —
    데모 2의 <code>some</code>/<code>every</code>를 보세요.
    다른 타입에 대한 임의의 술어를 뒤집으려면
    <a href="negate.html"><code>negate</code></a>를 쓰세요.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 불리언에 대한 술어로 쓰기</h2>
  <p>
    <code>not</code>은 그 자체가 <code>bool Function(bool)</code>이므로,
    따로 감싸지 않고 <code>some</code>/<code>every</code>에 바로 꽂아 넣을 수 있습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>not</code>으로 "완료" 플래그 목록에서 "아직 대기 중"
    플래그 목록을 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="negate.html"><code>negate</code></a> — bool 하나가 아니라 술어 함수 전체를 뒤집기 ·
    <a href="some.html"><code>some</code></a> / <a href="every.html"><code>every</code></a> — 위에서 not과 함께 쓴 함수들 ·
    <a href="when.html"><code>when</code></a> — 조건부 변환 ·
    <a href="unless.html"><code>unless</code></a> — 조건이 반대인 when의 짝
  </div>
