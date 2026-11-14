---
slug: onChange
title: onChange — FxDart 101
description: FxDart onChange 튜토리얼 — 인자가 바뀔 때만 실행되도록 콜백을 감쌉니다. 콜백을 위한 uniqAdjacent이며 라이브 플레이그라운드 포함.
heading: <code>fxOnChange</code>
section: 12
crumb: onChange
prev: throttle.html
prevLabel: throttle
next: conflate.html
nextLabel: conflate
---
  <p class="hero-sub">인자가 직전 것과 다를 때만 콜백을 실행합니다 — 함수를 위한 <code>uniqAdjacent</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    타이머로 폴링하거나 매 프레임 다시 계산하는 값 — 1초에 네 번 읽는 경과
    초, 코인 개수, 진행률 — 은 바뀌는 것보다 훨씬 자주 도착합니다. 이를 막는
    코드는 언제나 같은 세 줄입니다. 마지막 값을 기억하고, 비교하고, 일찍
    반환합니다. <code>fxOnChange(f)</code>는 그 세 줄을 한 번으로 정리한
    것입니다. 첫 호출은 항상 실행되고, 그 뒤로는 인자가 마지막으로 실행된
    호출의 인자와 같지 않을 때만 <code>f</code>를 실행합니다.
  </p>
  <p>
    동등성은 기본적으로 <code>==</code>입니다. "바뀌었다"의 의미를 정하려면
    <code>equals</code>를 넘기세요 — 반올림 구간, 레코드의 한 필드, 대소문자를
    구분하지 않는 문자열 등. <code>.reset()</code>은 마지막 값을 잊으므로,
    다음 호출은 무엇을 담고 있든 실행됩니다.
    <a href="debounce.html"><code>fxDebounce</code></a>처럼 콜백에 대한
    메서드 표기도 있습니다: <code>setCoins.fxOnChange()</code>.
  </p>
  <p>
    <code><a href="uniqAdjacent.html">uniqAdjacent</a></code>의 콜백
    쌍둥이입니다. 같은 규칙을, 시퀀스에서 당겨오는 값이 아니라 함수로
    밀어 넣는 값에 적용합니다. debounce와 달리 지연을 더하지 않고, 바뀐 것은
    하나도 버리지 않습니다. fxdart 확장 기능입니다(FxTS에는 없습니다).
  </p>

  <h2>데모 1 · 폴링되는 값</h2>
  {{playground:0}}

  <h2>데모 2 · equals와 reset()</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 바뀌지 않은 코인 개수를 다시 쓰지 않게 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="uniqAdjacent.html"><code>uniqAdjacent</code></a> — 시퀀스에 적용되는 같은 규칙 ·
    <a href="debounce.html"><code>fxDebounce</code></a> — 잠잠해질 때까지 기다리기 ·
    <a href="throttle.html"><code>fxThrottle</code></a> — 구간마다 최대 한 번 ·
    <a href="memoizeLast.html"><code>fxMemoizeLast</code></a> — 같은 입력이면 재계산 건너뛰기
  </div>
