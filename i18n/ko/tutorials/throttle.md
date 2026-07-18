---
slug: throttle
title: throttle — FxDart 101
description: FxDart throttle 튜토리얼: wait 구간마다 함수를 최대 한 번만 실행하는 방법, leading/trailing 에지와 cancel(), 그리고 라이브 플레이그라운드까지.
heading: <code>throttle</code>
section: 12
crumb: throttle
next: shuffle.html
nextLabel: shuffle
---
  <p class="hero-sub">wait 구간마다 함수를 최대 한 번만 실행합니다 — debounce의 "잠잠해질 때까지 기다리기"와 달리 일정한 주기로 발화합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>throttle</code>은 감싼 함수가 아무리 자주 호출되더라도
    <code>func</code>가 <code>wait</code>마다 최대 한 번만 실행되도록
    보장합니다. <a href="debounce.html"><code>debounce</code></a>와의 결정적인
    차이가 여기 있습니다. debounce는 호출이 있을 때마다 타이머를
    <em>다시 시작</em>하므로 호출이 끊이지 않으면 실행이 무한정 밀릴 수
    있지만, throttle의 구간은 한 번 시작되면 고정이라 호출이 일정한
    주기로 계속 통과합니다. 스크롤이나 리사이즈 핸들러처럼 맨 마지막
    한 번이 아니라 주기적인 갱신이 필요한 곳에 유용합니다.
  </p>
  <p>
    <code>leading</code>과 <code>trailing</code>은 둘 다 기본값이
    <code>true</code>입니다. 한 구간의 첫 호출은 즉시 발화하고(리딩 에지),
    구간이 닫히기 전에 호출이 더 들어오면 그중 <em>마지막</em> 호출이
    구간이 끝날 때 한 번 발화합니다(트레일링 에지, 가장 최근 인자로).
    둘 중 하나를 끄면 리딩만 또는 트레일링만 동작하게 만들 수 있습니다.
    <code>debounce</code>와 마찬가지로 반환되는
    <code>Throttled&lt;T&gt;</code>는 호출 가능한 클래스이며, 대기 중인
    트레일링 호출을 버리는 <code>.cancel()</code>을 제공합니다.
  </p>

  <h2>데모 1 · 리딩 + 트레일링(기본 동작)</h2>
  <p>첫 호출은 즉시 발화하고, 구간이 닫힐 때 그 구간의 마지막 호출이
    한 번 더 발화합니다:</p>
  {{playground:0}}

  <h2>데모 2 · leading/trailing 조절과 cancel()</h2>
  <p>
    <code>leading</code>을 끄면 트레일링만, <code>trailing</code>을 끄면
    리딩만 동작하고, <code>.cancel()</code>을 호출하면 대기 중인 트레일링
    호출을 버립니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>onClick</code>을 <code>throttle</code>로 감싸(wait는 100ms)
    빠르게 이어진 클릭이 세 번이 아니라 최대 두 번 — 리딩과 트레일링 —
    만 기록되게 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="debounce.html"><code>debounce</code></a> — 고정된 주기가 아니라 잠잠해지기를 기다립니다 ·
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — 타이밍 데모를 만드는 재료 ·
    <a href="shuffle.html"><code>shuffle</code></a> — 시드를 지정하는 난수 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 비동기 파이프라인의 속도 제한
  </div>
