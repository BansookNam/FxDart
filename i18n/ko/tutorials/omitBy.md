---
slug: omitBy
title: omitBy — FxDart 101
description: FxDart omitBy 튜토리얼: (키, 값) 술어에 걸리는 Map 엔트리를 걸러 냅니다.
heading: <code>omitBy</code>
section: 9
crumb: omitBy
prev: pick.html
prevLabel: pick
next: pickBy.html
nextLabel: pickBy
---
  <p class="hero-sub">술어에 걸리는 엔트리를 제외한 <code>Map</code>의 복사본을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>omit</code>이 고정된 키 목록을 받는다면, <code>omitBy</code>는
    술어를 받아 엔트리마다 판단합니다. 술어는 엔트리 전체를
    <code>(K, V)</code> 레코드로 받으므로 키와 값을 모두 활용할 수
    있습니다 — <code>e.$1</code>이 키, <code>e.$2</code>가 값입니다.
    이는 라이브러리 전반에서 <code>entries(map)</code>이
    <code>Map</code>을 표현하는 방식과 같습니다.
  </p>
  <p>
    제거할 대상이 고정된 키 이름 집합이 아니라 조건으로 정의될 때 —
    "낙제 점수를 제거한다", "품절 항목을 제거한다" 같은 경우 — 쓰면
    됩니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 값 조건으로 제거하기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>omitBy</code>로 값이 <code>false</code>인 엔트리를 제거해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="pickBy.html"><code>pickBy</code></a> — 그 반대: 술어로 남깁니다 ·
    <a href="omit.html"><code>omit</code></a> — 고정된 키 목록으로 제거합니다 ·
    <a href="isMatch.html"><code>isMatch</code></a> — 엔트리용으로 바로 쓸 수 있는 깊은 비교 술어 ·
    <a href="evolve.html"><code>evolve</code></a> — 제거하는 대신 값을 변환합니다
  </div>
