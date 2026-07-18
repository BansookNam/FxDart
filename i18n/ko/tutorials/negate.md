---
slug: negate
title: negate — FxDart 101
description: FxDart negate 튜토리얼: 어떤 술어든 논리적으로 뒤집은 술어로 바꾸는 방법을 라이브 플레이그라운드와 함께 알아봅니다.
heading: <code>negate</code>
section: 10
crumb: negate
prev: memoize.html
prevLabel: memoize
next: not.html
nextLabel: not
---
  <p class="hero-sub">전달한 술어를 논리적으로 뒤집은 술어를 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>negate(f)</code>는 임의의 <code>x</code>에 대해
    <code>!f(x)</code>를 반환하는 새 술어를 돌려줍니다. 이미 이름이 붙은 술어가
    있고(<code>isEven</code>, <code>isEmpty</code>,
    <code>matches(pattern)</code>의 결과 등) 그 반대를 함수 값으로 쓰고 싶을 때
    가장 유용합니다 — <code>filter</code>, <code>reject</code>를 비롯해
    술어를 요구하는 어디에든, 로직을 다시 정의하지 않고 넘길 수 있습니다.
  </p>
  <p>
    <a href="not.html"><code>not</code></a>과 혼동하지 마세요. <code>not</code>은
    <code>bool</code> 값 하나를 뒤집고, <code>negate</code>는
    <em>술어 함수</em> 자체를 뒤집습니다. 대략 <code>negate(f)</code>는
    <code>(x) =&gt; not(f(x))</code>인 셈입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 라이브러리 술어 뒤집기</h2>
  <p>
    <code>negate</code>는 라이브러리에 이미 있는 어떤 술어와도 조합됩니다.
    값 기반 술어인 <a href="isEmpty.html"><code>isEmpty</code></a>가 그 예입니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>negate(isVowel)</code>로 자음만 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="not.html"><code>not</code></a> — 불리언 값 하나를 뒤집기 ·
    <a href="filter.html"><code>filter</code></a> / <a href="reject.html"><code>reject</code></a> — 뒤집은 술어가 주로 쓰이는 자리 ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — negate와 조합하기 좋은 값 기반 술어 ·
    <a href="when.html"><code>when</code></a> — 술어가 참일 때만 콜백 적용하기
  </div>
