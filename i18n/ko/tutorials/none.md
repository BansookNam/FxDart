---
slug: none
title: none — FxDart 101
description: FxDart none 튜토리얼 — 어떤 원소도 일치하지 않을 때 true. every·some과 나란한 세 번째 한정자로, 첫 일치에서 단락합니다. 동기와 비동기 모두.
heading: <code>fxNone</code>
section: 8
crumb: none
prev: atLeast.html
prevLabel: atLeast
next: predicates.html
nextLabel: predicates
---
  <p class="hero-sub">"하나도 일치하지 않는가?" — 전칭 명제로 말하고, 첫 반례에서 답합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>fxNone(f, xs)</code>는 <code>f</code>를 만족하는 원소가 하나도
    없을 때 <code>true</code>입니다. 언제든 <code>!fxSome(f, xs)</code>로
    쓸 수 있고 답도 같습니다 — 하지만 그것은 부정된 존재 명제("어떤 것이
    …인 것은 아니다")로 읽히고, 한정자 버그는 바로 부정에서 생깁니다.
    <code>!</code>가 <code>&amp;&amp;</code>의 엉뚱한 쪽으로 옮겨 가거나,
    리팩터링 중에 빠져 버립니다. <code>none</code>은 규칙을 여러분이 말하는
    그대로 표현합니다.
  </p>
  <p>
    <code><a href="every.html">every</a></code>,
    <code><a href="some.html">any</a></code>와 나란한 세 번째 한정자이며,
    셋은 서로 묶여 있습니다. <code>none(f)</code>는 <code>!any(f)</code>이고,
    <code>every((x)&nbsp;=&gt;&nbsp;!f(x))</code>이며,
    <code><a href="atLeast.html">atMost</a>(0, f)</code>입니다.
    <code>any</code>처럼 <strong>단락</strong>합니다. 첫 일치가 답
    (<code>false</code>)을 정하고, 나머지는 검사하지 않습니다. 빈 입력에는
    반례가 없으므로 <code>true</code>입니다.
  </p>
  <p>
    체인에서는 <code>fx(xs).none(f)</code>입니다.
    <code>fxNoneAsync</code>와 <code>fxAsync(…).none(f)</code>는 await하는
    술어를 받고, 답이 정해지는 일치에서 업스트림을 취소합니다. Dart 고유의
    추가 기능입니다 — FxTS에는 <code>every</code>/<code>some</code>만
    있고, Kotlin은 <code>none</code>이라고 씁니다.
    <code>SingletonRaise.none()</code>(<a href="nullable.html">nullable</a>
    빌더의 것)과는 관계가 없습니다. 그쪽은 raise
    스코프를 단락하는 멤버이므로, 두 이름은 서로를 가리지 않습니다.
  </p>

  <h2>데모 1 · 일치 없음, 빈 입력, 조기 종료</h2>
  {{playground:0}}

  <h2>데모 2 · 세 가지 표기, 그리고 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>!</code>를 없애고 규칙을 그대로 말해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="some.html"><code>any</code></a> — <code>none</code>은 그 부정 ·
    <a href="every.html"><code>every</code></a> — 전칭 한정자 ·
    <a href="atLeast.html"><code>atMost</code></a> — <code>atMost(0, f)</code>가 곧 <code>none</code>
  </div>
