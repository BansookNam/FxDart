---
slug: uniq
title: uniq — FxDart 101
description: FxDart uniq 튜토리얼: 처음 등장한 순서를 유지하면서 중복 값을 제거하는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>uniq</code>
section: 4
crumb: uniq
prev: compact.html
prevLabel: compact
next: uniqBy.html
nextLabel: uniqBy
---
  <p class="hero-sub">중복 값을 제거하고, 각 값의 첫 등장만 남기면서 순서를 유지합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>uniq</code>는 이터러블을 한 번만 훑으면서 이미 본 값을
    <code>Set</code>에 담아 두고, 각 원소를 처음 등장할 때만 방출합니다.
    구현은 <code>uniqBy((a) =&gt; a, iterable)</code>, 즉 항등 키를 쓰는
    형태이므로, 값 전체의 동등성이 아닌 다른 기준으로 중복을 없애야 한다면
    <a href="uniqBy.html"><code>uniqBy</code></a>를 쓰면 됩니다.
  </p>
  <p>
    지연 평가되며 스트리밍 방식으로 동작합니다. <code>Set</code>은 원소를
    끌어당길 때마다 조금씩 커질 뿐, 소스 전체를 미리 버퍼링하지 않습니다.
    순서도 보존됩니다 — 살아남는 것은 마지막이 아니라 처음 등장한 값입니다.
  </p>
  <p>
    비동기 쪽에서는 동시성이 상류의 fetch 단계에 머무는 한
    <code>uniqAsync</code>를 <code>.concurrent(n)</code>과 함께 써도
    안전합니다. 먼저 <code>.map(...).concurrent(n)</code>으로 가져온 뒤,
    이미 해소되어 순서가 정해진 결과에 <code>.uniq()</code>를 적용하세요.
    데모 2가 그 예입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 상류의 동시성</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>uniq</code>로 중복 태그를 제거하되, 처음 등장한
    순서를 유지해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="uniqBy.html"><code>uniqBy</code></a> — 계산된 키 기준으로 중복 제거 ·
    <a href="difference.html"><code>difference</code></a> — 다른 이터러블에 있는 원소 제거 ·
    <a href="intersection.html"><code>intersection</code></a> — 공통 원소만 남기기 ·
    <a href="compact.html"><code>compact</code></a> — null 제거
  </div>
