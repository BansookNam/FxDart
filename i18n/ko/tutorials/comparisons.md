---
slug: comparisons
title: gt · gte · lt · lte — FxDart 101
description: FxDart 비교 함수 튜토리얼: data-first 방식의 gt, gte, lt, lte와 이들을 단항 술어로 커링하는 방법을 라이브 플레이그라운드와 함께 살펴봅니다.
heading: <code>gt</code> · <code>gte</code> · <code>lt</code> · <code>lte</code>
section: 10
crumb: gt · gte · lt · lte
prev: add.html
prevLabel: add
next: delay.html
nextLabel: delay &amp; sleep
---
  <p class="hero-sub">연산자 대신 함수 값으로 쓰는 data-first 비교 함수입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>gt</code>, <code>gte</code>, <code>lt</code>, <code>lte</code>는
    네 가지 순서 비교 연산자를 <strong>data-first</strong> 함수로 감싼 것입니다.
    <code>gt(a, b) == (a &gt; b)</code>처럼 첫 번째 인자가 왼쪽에 오며,
    연산자와 순서가 정확히 같습니다. 덕분에 중위 연산자 대신 함수를 요구하는
    API 어디에나 그대로 비교자로 넘길 수 있습니다.
  </p>
  <p>
    내부적으로는 두 값이 서로 <code>Comparable</code>해야 하고, 한 가지 예외를
    빼면 런타임 타입까지 정확히 같아야 합니다. <code>num</code>과
    <code>num</code>, <code>String</code>과 <code>String</code>은 섞일 수 있어
    <code>int</code>와 <code>double</code>을 비교할 수 있지만, 그 외에 타입이
    맞지 않으면 조용히 변환하는 대신 <code>ArgumentError</code>를 던집니다.
  </p>
  <p>
    네 함수 모두 커링되지 않습니다 — <code>gt(5)</code> 같은 부분 적용은
    없습니다. (예를 들어 <code>filter</code>에 넘길) 재사용 가능한 단항 술어가
    필요하다면 한쪽을 고정하는 짧은 클로저를 쓰면 됩니다.
    <code>(b) =&gt; gt(b, 5)</code>처럼요.
  </p>

  <h2>데모 1 · 기본 사용법과 타입 불일치 오류</h2>
  {{playground:0}}

  <h2>데모 2 · 커링해서 filter 술어로 쓰기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 나이가 18 이상인(<code>gte</code>) 성인만 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="add.html"><code>add</code></a> — 이 비교 함수들에 대응하는 산술 함수 ·
    <a href="sort.html"><code>sort</code></a> / <a href="sortBy.html"><code>sortBy</code></a> — lt/gt로 비교자 만들기 ·
    <a href="min.html"><code>min</code></a> / <a href="max.html"><code>max</code></a> — 같은 비교의 집계 버전 ·
    <a href="negate.html"><code>negate</code></a> — 커링한 비교 술어 뒤집기
  </div>
