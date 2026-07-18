---
slug: add
title: add — FxDart 101
description: FxDart add 튜토리얼 - 함수 값으로 쓸 수 있는 제네릭 +, 리듀서로 활용하는 법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>add</code>
section: 10
crumb: add
prev: cases.html
prevLabel: cases
next: comparisons.html
nextLabel: gt · gte · lt · lte
---
  <p class="hero-sub">같은 타입의 두 값을 더합니다. 여기저기 넘겨 쓸 수 있는 함수 형태입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>add(a, b)</code>는 <code>+</code>를 함수 값으로 감싼 것입니다.
    <code>+</code>로 동적 디스패치하기 때문에 이 연산자를 지원하는 것이라면
    무엇이든 동작합니다 — <code>num</code>, <code>String</code> 연결,
    심지어 <code>List</code> 연결까지 — 숫자와 문자열을 모두 받는 FxTS의
    <code>add</code>와 같은 동작입니다.
  </p>
  <p>
    진가는 인라인 <code>(a, b) =&gt; a + b</code> 대신 이항
    <code>(T, T) -&gt; T</code> 함수를 요구하는 API에서 드러납니다 —
    가장 자연스러운 자리는 <code>reduce</code>/<code>fold</code>의 결합
    함수입니다. 다만 이항 함수이므로 단항 <code>map</code> 콜백으로
    쓰려면(모든 원소에 고정값을 더하는 경우) 한쪽을 직접 클로저로 묶어
    주면 됩니다: <code>(b) =&gt; add(n, b)</code>.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 리듀서로, 그리고 map용으로 클로저에 묶어서</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>fold</code>와 <code>add</code>를 사용해 모든 조각을
    하나의 문자열로 이어 붙여 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="reduce.html"><code>reduce</code></a> / <a href="fold.html"><code>fold</code></a> — add를 결합 함수로 쓰는 대표적인 자리 ·
    <a href="sum.html"><code>sum</code></a> — Iterable&lt;num&gt;을 위해 이미 준비된 합계 함수 ·
    <a href="comparisons.html"><code>gt · gte · lt · lte</code></a> — add에 대응하는 비교 함수들 ·
    <a href="apply.html"><code>apply</code></a> — 동적 인자 목록으로 임의의 함수를 호출
  </div>
